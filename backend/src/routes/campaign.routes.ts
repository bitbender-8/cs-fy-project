import { Router, Request, Response } from "express";
import { AnyZodObject } from "zod";

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
  LOCKED_CAMPAIGN_FIELDS,
  LockedCampaignFields,
  SENSITIVE_CAMPAIGN_FIELDS,
  SensitiveCampaignFields,
} from "../models/campaign.model.js";
import { getUserRole } from "../services/user.service.js";
import { ProblemDetails } from "../errors/error.types.js";
import { getCampaigns, insertCampaign } from "../repositories/campaign.repo.js";
import { getUuidFromAuth0Id } from "../repositories/user.repo.js";
import { validateFileUpload } from "../middleware/file-upload.middleware.js";
import { validateRequestBody } from "../middleware/request-body.middleware.js";
import { optionalAuth, requireAuth } from "../middleware/auth.middleware.js";
import { validateStatusTransitions } from "../services/campaign.service.js";

type RedactedCampaign = Omit<Campaign, SensitiveCampaignFields> & {
  redactedDocumentUrls?: string[];
};

type CreatableCampaignFields =
  | Exclude<LockedCampaignFields, "paymentInfo">
  | "status";

/**
 * Schema used for validating campaign creation requests.
 *
 * The schema makes several important modifications to the base CampaignSchema:
 *
 * 1. It allows "paymentInfo" to be specified, unlike other locked fields.
 *    Payment information must be collected during campaign creation.
 *
 * 2. It excludes the "status" field to enforce that new campaigns
 *    always start with "Pending Review" status.
 *
 * 3. It transforms the list of fields to omit into the object format
 *    required by Zod's .omit() method, where each key maps to true.
 */
const campaignCreateSchema = CampaignSchema.omit(
  [
    ...LOCKED_CAMPAIGN_FIELDS.filter(
      (field): field is Exclude<LockedCampaignFields, "paymentInfo"> =>
        field !== "paymentInfo"
    ),
    "status",
  ].reduce(
    (acc, field) => ({
      ...acc,
      [field]: true,
    }),
    {} as { [key in CreatableCampaignFields]: true }
  )
);

const campaignUpdateSchema: AnyZodObject = CampaignSchema.omit(
  LOCKED_CAMPAIGN_FIELDS.reduce((acc, field) => ({ ...acc, [field]: true }), {})
);

export const campaignRouter: Router = Router();

// Used by supervisors when they respond to campaign requests or update a campaign.
// Some fields need to be set based on how other fields have changed.
// Need to do some comparisons with the original state of a campaign.
campaignRouter.put(
  "/:id",
  requireAuth,
  validateFileUpload("redactedDocuments", "Both"),
  validateRequestBody(campaignUpdateSchema),
  async (req: Request, res: Response): Promise<void> => {
    void req;
    res.status(500).json({ message: "Route not Implemented" });
    // if (getUserRole(req.auth) === "Supervisor") {
    //   const campaignId = validateUuidParam(req.params.id);
    //   const updatedCampaign: Omit<Campaign, LockedCampaignFields> = req.body;
    //   const originalCampaign: Campaign = (
    //     await getCampaigns({ id: campaignId })
    //   ).items[0];

    //   const validationResult = validateStatusTransitions(
    //     originalCampaign.status,
    //     updatedCampaign.status
    //   );

    //   if (!validationResult.isValid) {
    //     const problemDetails: ProblemDetails = {
    //       title: "Validation Failure",
    //       status: 400,
    //       detail: validationResult.message as string,
    //     };

    //     res.status(problemDetails.status).json(problemDetails);
    //     return;
    //   }

    //   if (req.files && Array.isArray(req.files) && req.files.length !== 0) {
    //     for (const file of req.files) {
    //       updatedCampaign.documents.push({
    //         campaignId,
    //         documentUrl: originalCampaign.documents.find((document) => document.)
    //         redactedDocumentUrl: `${process.env.UPLOAD_DIR}/${file.filename}`,
    //       });
    //     }
    //   }
    // } else {
    //   const problemDetails: ProblemDetails = {
    //     title: "Permission Denied",
    //     status: 403,
    //     detail: "You do not have permission to access this resource",
    //   };
    //   res.status(problemDetails.status).json(problemDetails);
    //   return;
    // }
  }
);

campaignRouter.post(
  "/",
  requireAuth,
  validateFileUpload("documents", "Both"),
  validateRequestBody(campaignCreateSchema),
  async (req: Request, res: Response): Promise<void> => {
    if (getUserRole(req.auth) === "Recipient") {
      const recipientId = await getUuidFromAuth0Id(req.auth?.payload.sub ?? "");
      const campaignData = req.body;

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
        documents: documentUrls.map((url) => ({
          documentUrl: url,
        })),
      });

      res.status(201).json(insertedCampaign);
      return;
    } else {
      const problemDetails: ProblemDetails = {
        title: "Permission Denied",
        status: 403,
        detail: "You do not have permission to access this resource",
      };
      res.status(problemDetails.status).json(problemDetails);
      return;
    }
  }
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
      SENSITIVE_CAMPAIGN_FILTERS
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
  }
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
          req.auth?.payload.sub ?? ""
        );

        const tempCampaign = (
          await getCampaigns({
            id: campaignId,
            ownerRecipientId: userIdFromJwt,
          })
        ).items[0];

        campaign = tempCampaign ? tempCampaign : await getPublicCampaign();
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
  }
);
