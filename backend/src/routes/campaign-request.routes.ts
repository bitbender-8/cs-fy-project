import { Router, Request, Response } from "express";
import { z } from "zod";

import {
  CampaignRequest,
  EndDateExtensionRequestSchema,
  GoalAdjustmentRequestSchema,
  LOCKED_CAMPAIGN_REQUEST_FIELDS,
  LockedCampaignRequestFields,
  PostUpdateRequestSchema,
  StatusChangeRequestSchema,
} from "../models/campaign-request.model.js";
import { PaginatedList, validateUuidParam } from "../utils/utils.js";
import { requireAuth } from "../middleware/auth.middleware.js";
import { validateRequestBody } from "../middleware/request-body.middleware.js";
import { getUserRole } from "../services/user.service.js";
import { ProblemDetails } from "../errors/error.types.js";
import {
  deleteCampaignPost,
  deleteCampaignRequest,
  getCampaignRequests,
  insertCampaignRequest,
  resolveCampaignRequest,
  updateCampaignPost,
} from "../repositories/campaign-request.repo.js";
import { CampaignPostSchema } from "../models/campaign.model.js";
import { getCampaigns, updateCampaign } from "../repositories/campaign.repo.js";
import { getUuidFromAuth0Id } from "../repositories/user.repo.js";
import { validateQueryParams } from "../middleware/query-param.middleware.js";
import {
  CampaignRequestFilter,
  campaignRequestFilterSchema,
} from "../models/filters/campaign-request-filters.js";
import { validCampaignRequestDecision } from "../utils/zod-helpers.js";
import { validateStatusTransitions } from "../services/campaign.service.js";
import { insertNotification } from "../repositories/notification.repo.js";
import { UUID } from "crypto";

const createCampaignRequestSchema = z.discriminatedUnion("requestType", [
  GoalAdjustmentRequestSchema.omit(
    LOCKED_CAMPAIGN_REQUEST_FIELDS.reduce(
      (acc, field) => ({
        ...acc,
        [field]: true,
      }),
      {} as { [key in LockedCampaignRequestFields]: true }
    )
  ),
  StatusChangeRequestSchema.omit(
    LOCKED_CAMPAIGN_REQUEST_FIELDS.reduce(
      (acc, field) => ({
        ...acc,
        [field]: true,
      }),
      {} as { [key in LockedCampaignRequestFields]: true }
    )
  ),
  PostUpdateRequestSchema.omit(
    LOCKED_CAMPAIGN_REQUEST_FIELDS.reduce(
      (acc, field) => ({
        ...acc,
        [field]: true,
      }),
      {} as { [key in LockedCampaignRequestFields]: true }
    )
  ).extend({
    newPost: CampaignPostSchema.omit({
      id: true,
      campaignId: true,
      publicPostDate: true,
    }),
  }),
  EndDateExtensionRequestSchema.omit(
    LOCKED_CAMPAIGN_REQUEST_FIELDS.reduce(
      (acc, field) => ({
        ...acc,
        [field]: true,
      }),
      {} as { [key in LockedCampaignRequestFields]: true }
    )
  ),
]);

export const campaignRequestRouter: Router = Router();

/**
 * @route POST /campaign-requests?campaignId={campaignId}
 * @description Creates a new campaign request. This route is intended for recipients.
 * The `campaignId` for which the request is being made must be provided as a query parameter.
 * The request body should contain the details of the campaign request, discriminated by `requestType`.
 *
 * @param {string} req.query.campaignId - The UUID of the campaign this request pertains to.
 * @param {Request} req - Express request object. Expects campaign request data in `req.body`.
 * @param {Response} res - Express response object.
 * @returns {Response} 201 - The created campaign request object.
 * @returns {Response} 403 - If the user is not a recipient or does not own the campaign.
 */
campaignRequestRouter.post(
  "/",
  requireAuth,
  validateRequestBody(createCampaignRequestSchema),
  async (req: Request, res: Response): Promise<void> => {
    if (getUserRole(req.auth) !== "Recipient") {
      const problemDetails: ProblemDetails = {
        title: "Permission Denied",
        status: 403,
        detail: "You do not have permission to access this resource",
      };
      res.status(problemDetails.status).json(problemDetails);
      return;
    }

    const campaignId = validateUuidParam(
      req.query.campaignId as string,
      "query",
      "campaignId"
    );

    // Check that the recipient owns the campaign they are trying to create campaign requests for
    const userIdFromJwt = await getUuidFromAuth0Id(req.auth?.payload.sub ?? "");
    const matchingCampaign = (
      await getCampaigns({
        id: campaignId,
        ownerRecipientId: userIdFromJwt,
      })
    ).items[0];

    if (!matchingCampaign || Object.keys(matchingCampaign).length === 0) {
      const problemDetails: ProblemDetails = {
        title: "Permission Denied",
        status: 403,
        detail: "You do not have permission to modify this campaign.",
      };
      res.status(problemDetails.status).json(problemDetails);
      return;
    }

    // Validated campaign request data from middleware
    const campaignRequest: z.infer<typeof createCampaignRequestSchema> =
      req.body;

    // Store the campaign request in DB
    const insertedCampaignRequest: CampaignRequest =
      await insertCampaignRequest(campaignId, {
        ...campaignRequest,
      });

    res
      .set(
        "Location",
        `${req.protocol}://${req.get("host")}/campaign-requests/${insertedCampaignRequest.id}`
      )
      .status(201)
      .json(insertedCampaignRequest);
    return;
  }
);

/**
 * @route GET /campaign-requests
 * @description Retrieves a paginated list of campaign requests based on filter criteria.
 * Recipients can only see requests they own.
 * Supervisors can see all campaign requests.
 *
 * @param {Request} req - Express request object, expects query parameters for filtering (see `CampaignRequestFilterSchema`).
 * @param {Response} res - Express response object.
 * @returns {Response} 200 - A paginated list of campaign requests.
 * @returns {Response} 403 - If the user role is not authorized to view any requests.
 */
campaignRequestRouter.get(
  "/",
  requireAuth,
  validateQueryParams(campaignRequestFilterSchema),
  async (req: Request, res: Response): Promise<void> => {
    const queryParams = req.validatedParams as CampaignRequestFilter;
    let campaignRequests: PaginatedList<CampaignRequest>;

    switch (getUserRole(req.auth)) {
      case "Recipient": {
        const userUuid = await getUuidFromAuth0Id(req.auth?.payload.sub ?? "");

        campaignRequests = await getCampaignRequests({
          ...queryParams,
          ownerRecipientId: userUuid,
        });
        break;
      }
      case "Supervisor": {
        campaignRequests = await getCampaignRequests(queryParams);
        break;
      }
      default: {
        const problemDetails: ProblemDetails = {
          title: "Permission Denied",
          status: 403,
          detail: "You do not have permission to access this resource",
        };
        res.status(problemDetails.status).json(problemDetails);
        return;
      }
    }

    res.status(200).json(campaignRequests);
    return;
  }
);

/**
 * @route GET /campaign-requests/:id
 * @description Retrieves a single campaign request by its ID.
 * Recipients can only retrieve requests they own.
 * Supervisors can retrieve any campaign request.
 *
 * @param {string} req.params.id - The UUID of the campaign request to retrieve.
 * @param {Request} req - Express request object.
 * @param {Response} res - Express response object.
 * @returns {Response} 200 - The campaign request object.
 * @returns {Response} 403 - If the user is not authorized to view this request.
 * @returns {Response} 404 - If the campaign request is not found.
 */
campaignRequestRouter.get(
  "/:id",
  requireAuth,
  async (req: Request, res: Response): Promise<void> => {
    const campaignRequestId = validateUuidParam(req.params.id);
    let campaignRequest: CampaignRequest;

    switch (getUserRole(req.auth)) {
      case "Recipient": {
        const userUuid = await getUuidFromAuth0Id(req.auth?.payload.sub ?? "");

        campaignRequest = (
          await getCampaignRequests({
            id: campaignRequestId,
            ownerRecipientId: userUuid,
          })
        ).items[0];
        break;
      }
      case "Supervisor": {
        campaignRequest = (
          await getCampaignRequests({
            id: campaignRequestId,
          })
        ).items[0];
        break;
      }
      default: {
        const problemDetails: ProblemDetails = {
          title: "Permission Denied",
          status: 403,
          detail: "You do not have permission to access this resource",
        };
        res.status(problemDetails.status).json(problemDetails);
        return;
      }
    }

    if (!campaignRequest || Object.keys(campaignRequest).length === 0) {
      const problemDetails: ProblemDetails = {
        title: "Not Found",
        status: 404,
        detail: "Campaign request not found",
      };
      res.status(problemDetails.status).json(problemDetails);
    } else {
      res.status(200).json(campaignRequest);
    }
    return;
  }
);

/**
 * @route PUT /campaign-requests/:id/decision/:decision
 * @description Allows a supervisor to approve or deny a campaign request.
 * This action resolves the campaign request and applies the requested changes to the underlying campaign if approved.
 * A notification is sent to the recipient upon resolution.
 *
 * @param {string} req.params.id - The UUID of the campaign request to resolve.
 * @param {string} req.params.decision - The decision, either "Approved" or "Denied".
 * @param {Request} req - Express request object.
 * @param {Response} res - Express response object.
 * @returns {Response} 204 - If the request was successfully resolved.
 * @returns {Response} 400 - If the decision is invalid, the request type is unknown, or status transition is invalid.
 * @returns {Response} 403 - If the user is not a supervisor.
 * @returns {Response} 404 - If the campaign request or associated campaign is not found, or if the request is already resolved.
 */
campaignRequestRouter.put(
  "/:id/decision/:decision",
  requireAuth,
  async (req: Request, res: Response): Promise<void> => {
    if (getUserRole(req.auth) !== "Supervisor") {
      const problemDetails: ProblemDetails = {
        title: "Permission Denied",
        status: 403,
        detail: "You do not have permission to access this resource",
      };
      res.status(problemDetails.status).json(problemDetails);
      return;
    }

    // Validate decision
    const decisionValidation = validCampaignRequestDecision().safeParse(
      req.params.decision
    );

    if (!decisionValidation.success) {
      const problemDetails: ProblemDetails = {
        title: "Validation Failure",
        status: 400,
        detail: decisionValidation.error.issues[0].message,
      };
      res.status(problemDetails.status).json(problemDetails);
      return;
    }

    const campaignRequestId = validateUuidParam(req.params.id);
    const campaignRequest = (
      await getCampaignRequests({ id: campaignRequestId })
    ).items[0];

    if (!campaignRequest || Object.keys(campaignRequest).length === 0) {
      const problemDetails: ProblemDetails = {
        title: "Not Found",
        status: 404,
        detail: `Campaign request with id ${campaignRequestId} was not found.`,
      };
      res.status(problemDetails.status).json(problemDetails);
      return;
    }

    if (campaignRequest.resolutionDate) {
      const problemDetails: ProblemDetails = {
        title: "Validation Failure",
        status: 404,
        detail: `Campaign request with id ${campaignRequestId} has already been resolved.`,
      };
      res.status(problemDetails.status).json(problemDetails);
      return;
    }

    const campaign = (await getCampaigns({ id: campaignRequest.campaignId }))
      .items[0];

    // Apply changes from campaignRequest to underlying campaign
    switch (campaignRequest.requestType) {
      case "Goal Adjustment": {
        await updateCampaign(campaign.id, {
          ...campaign,
          fundraisingGoal: campaignRequest.newGoal,
        });
        break;
      }
      case "Post Update": {
        await updateCampaignPost(campaignRequest.newPost.id, {
          publicPostDate: new Date(),
        });
        break;
      }
      case "End Date Extension": {
        await updateCampaign(campaign.id, {
          ...campaign,
          endDate: campaignRequest.newEndDate,
        });
        break;
      }
      case "Status Change": {
        const validationResult = validateStatusTransitions(
          campaign.status,
          campaignRequest.newStatus
        );

        if (!validationResult.isValid) {
          const problemDetails: ProblemDetails = {
            title: "Validation Failure",
            status: 400,
            detail: validationResult.message as string,
          };

          res.status(problemDetails.status).json(problemDetails);
          return;
        }

        // Since the transitions are already validated, we can apply changes that come with campaignRequest.newStatus blindly
        if (campaignRequest.newStatus === "Completed") {
          await updateCampaign(campaign.id, {
            ...campaign,
            status: campaignRequest.newStatus,
            endDate: new Date(),
          });
        } else if (campaignRequest.newStatus === "Verified") {
          await updateCampaign(campaign.id, {
            ...campaign,
            status: campaignRequest.newStatus,
            verificationDate: new Date(),
          });
        } else if (campaignRequest.newStatus === "Denied") {
          await updateCampaign(campaign.id, {
            ...campaign,
            status: campaignRequest.newStatus,
            denialDate: new Date(),
          });
        } else if (campaignRequest.newStatus === "Live") {
          await updateCampaign(campaign.id, {
            ...campaign,
            status: campaignRequest.newStatus,
            launchDate: new Date(),
            isPublic: true,
          });
        } else if (campaignRequest.newStatus === "Paused") {
          await updateCampaign(campaign.id, {
            ...campaign,
            status: campaignRequest.newStatus,
          });
        }
        break;
      }
    }

    // Resolve campaign request
    await resolveCampaignRequest(campaignRequestId);

    // Add notification for the recipient
    const decisionText =
      decisionValidation.data === "Accepted" ? "approved" : "denied";
    await insertNotification({
      subject: `Your campaign request has been ${decisionText}`,
      body: `Your "${campaignRequest.requestType}" request for the campaign "${campaign.title}" has been ${decisionText}.`,
      userId: campaignRequest.ownerRecipientId as UUID,
      userType: "Recipient",
    });

    res.status(204).send();
  }
);

/**
 * @route DELETE /campaign-requests/:id
 * @description Deletes a campaign request.
 * Recipients can only delete their own unresolved campaign requests.
 * Supervisors can delete any unresolved campaign request.
 * If the request type is "Post Update", the associated campaign post is also deleted.
 *
 * @param {string} req.params.id - The UUID of the campaign request to delete.
 * @param {Request} req - Express request object.
 * @param {Response} res - Express response object.
 * @returns {Response} 204 - If the campaign request was successfully deleted.
 * @returns {Response} 400 - If the user attempts to modify a resolved campaign request.
 * @returns {Response} 403 - If the user does not have permission to delete this request.
 * @returns {Response} 404 - If the campaign request is not found.
 */
campaignRequestRouter.delete(
  "/:id",
  requireAuth,
  async (req: Request, res: Response): Promise<void> => {
    const campaignRequestId = validateUuidParam(req.params.id);
    const campaignRequest = (
      await getCampaignRequests({
        id: campaignRequestId,
      })
    ).items[0];
    let deleteResult: boolean;

    switch (getUserRole(req.auth)) {
      case "Recipient": {
        const userUuid = await getUuidFromAuth0Id(req.auth?.payload.sub ?? "");

        if (campaignRequest.ownerRecipientId !== userUuid) {
          const problemDetails: ProblemDetails = {
            title: "Permission Denied",
            status: 403,
            detail: "You do not have permission to access this resource",
          };
          res.status(problemDetails.status).json(problemDetails);
          return;
        }

        if (campaignRequest.resolutionDate !== null) {
          const problemDetails: ProblemDetails = {
            title: "Validation Failure",
            status: 400,
            detail: "You cannot modify a resolved campaign request",
          };
          res.status(problemDetails.status).json(problemDetails);
          return;
        }

        deleteResult = await deleteCampaignRequest(campaignRequestId);

        if (campaignRequest.requestType === "Post Update") {
          deleteResult &&= await deleteCampaignPost(campaignRequest.newPost.id);
        }

        break;
      }
      case "Supervisor": {
        if (campaignRequest.resolutionDate !== null) {
          const problemDetails: ProblemDetails = {
            title: "Validation Failure",
            status: 400,
            detail: "You cannot modify a resolved campaign request",
          };
          res.status(problemDetails.status).json(problemDetails);
          return;
        }

        deleteResult = await deleteCampaignRequest(campaignRequestId);

        if (campaignRequest.requestType === "Post Update") {
          deleteResult &&= await deleteCampaignPost(campaignRequest.newPost.id);
        }
        break;
      }
      default: {
        const problemDetails: ProblemDetails = {
          title: "Permission Denied",
          status: 403,
          detail: "You do not have permission to access this resource",
        };
        res.status(problemDetails.status).json(problemDetails);
        return;
      }
    }

    if (!deleteResult) {
      const problemDetails: ProblemDetails = {
        title: "Not Found",
        status: 404,
        detail: `Campaign request with id '${campaignRequestId}' was not found.`,
      };
      res.status(problemDetails.status).json(problemDetails);
      return;
    }

    res.status(204).send();
  }
);
