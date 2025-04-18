import { Router, Request, Response } from "express";
import { z } from "zod";

import {
  CampaignFilterSchema,
  SENSITIVE_CAMPAIGN_FILTERS,
} from "../models/filters/campaign-filters.js";
import {
  PaginatedList,
  excludeProperties,
  validateUuidParam,
} from "../utils/utils.js";
import {
  Campaign,
  CampaignSchema,
  UPDATABLE_CAMPAIGN_FIELDS,
  UpdateableCampaignFields,
  SENSITIVE_CAMPAIGN_FIELDS,
  SensitiveCampaignFields,
  CREATEABLE_CAMPAIGN_FIELDS,
  CreateableCampaignFields,
  CampaignDocument,
} from "../models/campaign.model.js";
import { getUserRole } from "../services/user.service.js";
import { ProblemDetails } from "../errors/error.types.js";
import {
  getCampaigns,
  getCampaignDocuments,
  insertCampaign,
  updateCampaign,
} from "../repositories/campaign.repo.js";
import { getUuidFromAuth0Id } from "../repositories/user.repo.js";
import { validateFileUpload } from "../middleware/file-upload.middleware.js";
import { validateRequestBody } from "../middleware/request-body.middleware.js";
import { optionalAuth, requireAuth } from "../middleware/auth.middleware.js";
import { validateStatusTransitions } from "../services/campaign.service.js";
import { validUrl } from "../utils/zod-helpers.js";
import { UUID } from "crypto";
import { deleteFiles } from "../services/fie.service.js";

type RedactedCampaign = Omit<Campaign, SensitiveCampaignFields> & {
  redactedDocumentUrls?: string[];
};

const createCampaignSchema = CampaignSchema.pick(
  CREATEABLE_CAMPAIGN_FIELDS.reduce(
    (acc, field) => ({
      ...acc,
      [field]: true,
    }),
    {} as { [key in CreateableCampaignFields]: true },
  ),
);

const updateCampaignSchema = CampaignSchema.pick(
  UPDATABLE_CAMPAIGN_FIELDS.reduce(
    (acc, field) => ({
      ...acc,
      [field]: true,
    }),
    {} as { [key in UpdateableCampaignFields]: true },
  ),
)
  .extend({ documentIds: z.array(validUrl()) })
  .partial();

export const campaignRouter: Router = Router();

// Used by supervisors when they respond to campaign requests or update a campaign.
// Some fields need to be set based on how other fields have changed.
// Need to do some comparisons with the original state of a campaign.
// Based on the way the status changed certain date fields and other properties need to be updated. (verificationDate, isPublic, etc.).
campaignRouter.put(
  "/:id",
  requireAuth,
  validateFileUpload("redactedDocuments", "Both"),
  validateRequestBody(updateCampaignSchema),
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

    const campaignId = validateUuidParam(req.params.id);
    const updatedCampaignData: z.infer<typeof updateCampaignSchema> & {
      documents: CampaignDocument[];
    } = req.body;
    const documentIds = updatedCampaignData.documentIds;
    const originalCampaign: Campaign = (await getCampaigns({ id: campaignId }))
      .items[0];

    if (!originalCampaign || Object.keys(originalCampaign).length === 0) {
      const problemDetails: ProblemDetails = {
        title: "Not Found",
        status: 404,
        detail: `Campaign with id '${campaignId}' was not found`,
      };
      res.status(problemDetails.status).json(problemDetails);
      return;
    }

    // Validate campaign status transitions
    if (updatedCampaignData.status) {
      const validationResult = validateStatusTransitions(
        originalCampaign.status,
        updatedCampaignData.status,
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
    }

    // Handle updated files
    if (req.files && Array.isArray(req.files) && req.files.length !== 0) {
      // Files must each have a corresponding documentId
      if (!documentIds || documentIds.length !== req.files.length) {
        const problemDetails: ProblemDetails = {
          title: "Validation Failure",
          status: 400,
          detail:
            "The number of uploaded files does not match the number of provided document IDs.",
        };
        res.status(problemDetails.status).json(problemDetails);
        return;
      }

      // Validating each documentId to make sure that it exists and belongs to this campaign
      const validDocumentUrls = (await getCampaignDocuments(campaignId)).map(
        (result) => result.documentUrl,
      );
      const invalidDocumentIds = documentIds.filter(
        (id) => !validDocumentUrls.includes(id),
      );

      if (invalidDocumentIds.length > 0) {
        const problemDetails: ProblemDetails = {
          title: "Validation Failure",
          status: 400,
          detail: `The following document IDs are invalid or do not belong to this campaign: ${invalidDocumentIds.join(", ")}`,
        };
        res.status(problemDetails.status).json(problemDetails);
        return;
      }

      // The documentIds and their corresponding updated documentUrls must match
      updatedCampaignData.documents = [];

      for (let i = 0; i < req.files.length; i++) {
        updatedCampaignData.documents.push({
          campaignId: originalCampaign.id,
          documentUrl: documentIds[i],
          redactedDocumentUrl: `${process.env.UPLOAD_DIR}/${req.files[i].filename}`,
        });
      }
    } else if (documentIds && documentIds.length !== 0) {
      // TODO (bitbender-8): Update openapi-docs - If a file is not provided but a documentId is, that means that the redactedDocumentUrl at that path will be deleted.
      updatedCampaignData.documents = [];
      for (let i = 0; i < documentIds.length; i++) {
        updatedCampaignData.documents.push({
          campaignId: originalCampaign.id,
          documentUrl: documentIds[i],
          redactedDocumentUrl: undefined,
        });
      }
    }

    let campaignWithUpdates: Campaign = {
      ...originalCampaign,
      ...excludeProperties(updatedCampaignData, ["documentIds"]),
    };

    const newStatus = updatedCampaignData.status;
    if (newStatus) {
      const oldStatus = originalCampaign.status;

      // Use state transition to set fields
      switch (oldStatus) {
        case "Pending Review":
          if (newStatus === "Verified") {
            campaignWithUpdates = {
              ...campaignWithUpdates,
              verificationDate: new Date(),
            };
          } else if (newStatus === "Denied") {
            campaignWithUpdates = {
              ...campaignWithUpdates,
              denialDate: new Date(),
            };
          }
          break;
        case "Verified":
          if (newStatus === "Live") {
            campaignWithUpdates = {
              ...campaignWithUpdates,
              launchDate: new Date(),
              isPublic: true,
            };
          } else if (newStatus === "Denied") {
            campaignWithUpdates = {
              ...campaignWithUpdates,
              denialDate: new Date(),
            };
          }
          break;
        case "Live":
          if (newStatus === "Completed") {
            campaignWithUpdates = {
              ...campaignWithUpdates,
              endDate: new Date(),
            };
          }
          break;
        case "Paused":
          if (newStatus === "Completed") {
            campaignWithUpdates = {
              ...campaignWithUpdates,
              endDate: new Date(),
            };
          }
          break;
        default:
          campaignWithUpdates = {
            ...campaignWithUpdates,
          };
          break;
      }
    }

    await updateCampaign(
      campaignId,
      excludeProperties(campaignWithUpdates, [
        "id",
        "ownerRecipientId",
        "paymentInfo",
      ]),
    );

    // Delete old redacted files *after* update to prevent data inconsistencies if update fails.
    const oldRedactedDocUrls = originalCampaign.documents
      .filter((document) => documentIds?.includes(document.documentUrl))
      .map((document) => document.redactedDocumentUrl)
      .filter((url) => url !== undefined && url !== null);

    await deleteFiles(oldRedactedDocUrls);
    res.status(204).send();

    return;
  },
);

campaignRouter.post(
  "/",
  requireAuth,
  validateFileUpload("documents", "Both"),
  validateRequestBody(createCampaignSchema),
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

    const recipientId = await getUuidFromAuth0Id(req.auth?.payload.sub ?? "");
    const campaignData: z.infer<typeof createCampaignSchema> = req.body;

    const documentUrls: string[] = [];
    if (req.files && Array.isArray(req.files) && req.files.length !== 0) {
      for (const file of req.files) {
        documentUrls.push(`${process.env.UPLOAD_DIR}/${file.filename}`);
      }
    } else {
      const problemDetails: ProblemDetails = {
        title: "Validation Failure",
        status: 400,
        detail: "Supporting documents for campaign are required",
      };
      res.status(problemDetails.status).json(problemDetails);
      return;
    }

    const insertedCampaign = await insertCampaign(recipientId, {
      ...campaignData,
      documents: documentUrls.map(
        (url) =>
          ({
            documentUrl: url,
            // Suppressing errors since insertCampaign handles campaignId creation on its own
          }) as { campaignId: UUID; documentUrl: string },
      ),
    });

    res
      .set(
        "Location",
        `${req.protocol}://${req.get("host")}/campaigns/${insertedCampaign.id}`,
      )
      .status(201)
      .json(insertedCampaign);
    return;
  },
);

campaignRouter.get(
  "/",
  optionalAuth,
  async (req: Request, res: Response): Promise<void> => {
    const parsedQueryParams = CampaignFilterSchema.safeParse(req.query);

    if (!parsedQueryParams.success) {
      const problemDetails: ProblemDetails = {
        title: "Validation Failure",
        status: 400,
        detail: "One or more query params failed validation",
        fieldFailures: parsedQueryParams.error.issues.map((issue) => ({
          field: issue.path.join("."),
          uiMessage: issue.message,
        })),
      };
      res.status(problemDetails.status).json(problemDetails);
      return;
    }

    // Create filter params with sensitive filters omitted
    const queryParams = parsedQueryParams.data;
    const publicQueryParams = excludeProperties(
      queryParams,
      SENSITIVE_CAMPAIGN_FILTERS,
    );

    let campaigns: PaginatedList<RedactedCampaign> | PaginatedList<Campaign>;
    const userRole = getUserRole(req.auth);
    const userIdFromJwt =
      userRole === "Recipient"
        ? await getUuidFromAuth0Id(req.auth?.payload.sub ?? "")
        : null;

    const getPublicCampaigns = async (): Promise<
      PaginatedList<RedactedCampaign>
    > => {
      const result = await getCampaigns({
        ...publicQueryParams,
        isPublic: true,
      });
      return {
        ...result,
        items: result.items.map((campaign) => ({
          ...excludeProperties(campaign, SENSITIVE_CAMPAIGN_FIELDS),
          redactedDocumentUrls: campaign.documents
            .map((doc) => doc.redactedDocumentUrl)
            .filter((url): url is string => url !== undefined),
        })),
      };
    };

    switch (userRole) {
      case "Supervisor":
        campaigns = await getCampaigns(queryParams);
        break;

      case "Recipient":
        if (
          queryParams.ownerRecipientId &&
          userIdFromJwt === queryParams.ownerRecipientId
        ) {
          campaigns = await getCampaigns({
            ...queryParams,
            ownerRecipientId: queryParams.ownerRecipientId,
          });
        } else {
          campaigns = await getPublicCampaigns();
        }
        break;
      default:
        campaigns = await getPublicCampaigns();
    }

    res.status(200).json(campaigns);
    return;
  },
);

campaignRouter.get(
  "/:id",
  optionalAuth,
  async (req: Request, res: Response): Promise<void> => {
    const campaignId = validateUuidParam(req.params.id);
    let campaign: Campaign | RedactedCampaign;

    // Helper function to get public campaign
    const getPublicCampaign = async (): Promise<RedactedCampaign> => {
      const result = (await getCampaigns({ id: campaignId, isPublic: true }))
        .items[0];
      return {
        ...excludeProperties(result, SENSITIVE_CAMPAIGN_FIELDS),
        redactedDocumentUrls: result.documents
          .map((doc) => doc.redactedDocumentUrl)
          .filter((url): url is string => url !== undefined),
      };
    };

    switch (getUserRole(req.auth)) {
      case "Supervisor":
        // Supervisor: full access
        campaign = (await getCampaigns({ id: campaignId })).items[0];
        break;
      case "Recipient": {
        const userIdFromJwt = await getUuidFromAuth0Id(
          req.auth?.payload.sub ?? "",
        );

        const tempCampaign = (
          await getCampaigns({
            id: campaignId,
            ownerRecipientId: userIdFromJwt,
          })
        ).items[0];

        campaign =
          tempCampaign || Object.keys(tempCampaign).length !== 0
            ? tempCampaign
            : await getPublicCampaign();
        break;
      }
      default:
        // Public campaigns
        campaign = await getPublicCampaign();
    }

    if (!campaign || Object.keys(campaign).length === 0) {
      const problemDetails: ProblemDetails = {
        title: "Not Found",
        status: 404,
        detail: "Campaign not found",
      };
      res.status(problemDetails.status).json(problemDetails);
    } else {
      res.status(200).json(campaign);
    }

    return;
  },
);
