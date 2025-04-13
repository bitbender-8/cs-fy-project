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
  getCampaignRequests,
  insertCampaignRequest,
} from "../repositories/campaign-request.repo.js";
import { CampaignPostSchema } from "../models/campaign.model.js";
import { getCampaigns } from "../repositories/campaign.repo.js";
import { getUuidFromAuth0Id } from "../repositories/user.repo.js";
import { validateQueryParams } from "../middleware/query-param.middleware.js";
import {
  CampaignRequestFilter,
  campaignRequestFilterSchema,
} from "../models/filters/campaign-request-filters.js";

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
