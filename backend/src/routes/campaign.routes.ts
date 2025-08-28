import { Router, Request, Response } from "express";
import { z } from "zod";

import {
  CampaignFilterSchema,
  SENSITIVE_CAMPAIGN_FILTERS,
} from "../models/filters/campaign-filters.js";
import {
  PaginatedList,
  excludeProperties,
  fromIntToMoneyStr,
  fromMoneyStrToBigInt,
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
  CampaignDonation,
} from "../models/campaign.model.js";
import { getUserRole } from "../services/user.service.js";
import { ProblemDetails } from "../errors/error.types.js";
import {
  getCampaigns,
  getCampaignDocuments,
  insertCampaign,
  updateCampaign,
  insertCampaignDonation,
} from "../repositories/campaign.repo.js";
import { getUuidFromAuth0Id } from "../repositories/user.repo.js";
import { validateFileUpload } from "../middleware/file-upload.middleware.js";
import { validateRequestBody } from "../middleware/request-body.middleware.js";
import { optionalAuth, requireAuth } from "../middleware/auth.middleware.js";
import {
  validateStatusTransitions,
} from "../services/campaign.service.js";
import { validUrl } from "../utils/zod-helpers.js";
import { UUID } from "crypto";
import { deleteFiles } from "../services/fie.service.js";
import { config } from "../config.js";
import path from "path";
import {
  ChapaPaymentVerifyData,
  verifyChapaPayment,
} from "../services/chapa.service.js";

type RedactedCampaign = Omit<Campaign, SensitiveCampaignFields> & {
  redactedDocumentUrls?: string[];
};

const createCampaignSchema = CampaignSchema.pick(
  CREATEABLE_CAMPAIGN_FIELDS.filter(
    (field) => field !== "documents" && field !== "ownerRecipientId"
  ).reduce(
    (acc, field) => ({
      ...acc,
      [field]: true,
    }),
    {} as { [key in CreateableCampaignFields]: true }
  )
);

const updateCampaignSchema = CampaignSchema.pick(
  UPDATABLE_CAMPAIGN_FIELDS.reduce(
    (acc, field) => ({
      ...acc,
      [field]: true,
    }),
    {} as { [key in UpdateableCampaignFields]: true }
  )
)
  .extend({ documentIds: z.array(validUrl()) })
  .partial();

export const campaignRouter: Router = Router();

/**
 * @route PUT /campaigns/:id
 * @description Updates a campaign. This route is intended for supervisors.
 * It handles changes to campaign data, including status transitions and document updates.
 * When a campaign's status changes, relevant fields like `verificationDate`, `denialDate`,
 * `launchDate`, `isPublic`, and `endDate` are updated accordingly.
 * If the new status is "Completed", it also triggers the transfer of donations.
 * Redacted documents can be updated or removed.
 *
 * @param {string} req.params.id - The UUID of the campaign to update.
 * @param {Request} req - Express request object. Expects campaign data in `req.body` and optional `req.files` for redacted documents.
 * @param {Response} res - Express response object.
 */
campaignRouter.put(
  "/:id",
  requireAuth,
  validateFileUpload("redactedDocuments", "Both", config.PUBLIC_UPLOAD_DIR),
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
        updatedCampaignData.status
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
      const validDocumentUrls = (
        await getCampaignDocuments({ campaignId })
      ).items.map((result) => result.documentUrl);

      const invalidDocumentIds = documentIds.filter(
        (id) => !validDocumentUrls.includes(id)
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
          redactedDocumentUrl: `${req.files[i].filename}`,
        });
      }
    } else if (documentIds && documentIds.length !== 0) {
      // DEFER(TODO): Update openapi-docs - If a file is not provided but a documentId is, that means that the redactedDocumentUrl at that path will be deleted.
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

      // If the new status is "Completed", complete the donation transfer
      // if (newStatus === "Completed") {
      //   await transferCampaignDonations(campaignId);
      // }
    }

    await updateCampaign(
      campaignId,
      excludeProperties(campaignWithUpdates, [
        "id",
        "ownerRecipientId",
        "paymentInfo",
        "totalDonated",
      ])
    );

    // Delete old redacted files *after* update to prevent data inconsistencies if update fails.
    const oldRedactedDocUrls = originalCampaign.documents
      .filter((document) => documentIds?.includes(document.documentUrl))
      .map((document) =>
        // Redacted documents are in public upload directory
        document.redactedDocumentUrl
          ? path.join(config.PUBLIC_UPLOAD_DIR, document.redactedDocumentUrl)
          : null
      )
      .filter((url) => url !== undefined && url !== null);

    await deleteFiles(oldRedactedDocUrls);
    res.status(204).send();

    return;
  }
);

/**
 * @route POST /campaigns
 * @description Creates a new campaign. This route is intended for recipients.
 * It requires supporting documents to be uploaded.
 * The campaign status will be "Pending Review" by default.
 *
 * @param {Request} req - Express request object. Expects campaign data in `req.body` and `req.files` for documents.
 * @param {Response} res - Express response object.
 * @returns {Response} 201 - The created campaign object.
 */
campaignRouter.post(
  "/",
  requireAuth,
  validateFileUpload("documents", "Both", config.PRIVATE_UPLOAD_DIR),
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
        documentUrls.push(`${file.filename}`);
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
          }) as { campaignId: UUID; documentUrl: string }
      ),
    });

    res
      .set(
        "Location",
        `${req.protocol}://${req.get("host")}/campaigns/${insertedCampaign.id}`
      )
      .status(201)
      .json(insertedCampaign);
    return;
  }
);

/**
 * @route GET /campaigns
 * @description Retrieves a paginated list of campaigns based on filter criteria.
 * Access to sensitive campaign information is restricted based on user role.
 * Supervisors can see all campaign data.
 * Recipients can see all data for their own campaigns and public data for other campaigns.
 * Unauthenticated users and other roles can only see public campaign data.
 *
 * @param {Request} req - Express request object, expects query parameters for filtering.
 * @param {Response} res - Express response object.
 */
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
          documents: campaign.documents
            .map(
              (doc) =>
                ({
                  campaignId: doc.campaignId,
                  redactedDocumentUrl: doc.redactedDocumentUrl,
                }) as CampaignDocument
            )
            .filter(
              (doc): doc is CampaignDocument =>
                doc.redactedDocumentUrl !== undefined
            ),
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

/**
 * @route GET /campaigns/:id
 * @description Retrieves a single campaign by its ID.
 * Access to sensitive campaign information is restricted based on user role.
 * Supervisors can see all campaign data.
 * Recipients can see all data for their own campaign or public data for other campaigns.
 * Unauthenticated users and other roles can only see public campaign data.
 *
 * @param {Request} req - Express request object.
 * @param {Response} res - Express response object.
 */
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

        campaign =
          tempCampaign || Object.keys(tempCampaign ?? {}).length !== 0
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
  }
);

/**
 * @route POST /campaigns/:id/verify-donation/:txnRef
 * @description Verifies a donation transaction with Chapa and records the donation.
 * This endpoint is typically called by a webhook or callback from the payment gateway
 * after a donation attempt.
 *
 * @param {string} req.params.id - The UUID of the campaign for which the donation was made.
 * @param {string} req.params.txnRef - The transaction reference from Chapa.
 * @param {Request} req - Express request object.
 * @param {Response} res - Express response object.
 */
campaignRouter.post(
  "/:id/verify-donation/:txnRef",
  async (req: Request, res: Response): Promise<void> => {
    const campaignId = validateUuidParam(req.params.id);
    const txnRef = req.params.txnRef;

    console.log(`TxnRef: ${txnRef}, CampId: ${campaignId}`);

    // Check to make sure that the campaign in the id exists.
    const campaign = (await getCampaigns({ id: campaignId })).items[0];
    if (!campaign) {
      const problemDetails: ProblemDetails = {
        title: "Not Found",
        status: 404,
        detail: `Campaign with ID ${campaignId} not found.`,
      };
      res.status(problemDetails.status).json(problemDetails);
      return;
    }

    // Verify the donation transaction with Chapa.
    const chapaPymntVerifyResult = await verifyChapaPayment(txnRef);

    if (
      chapaPymntVerifyResult.status !== "success" ||
      !chapaPymntVerifyResult.data
    ) {
      const problemDetails: ProblemDetails = {
        title: "Payment Failure",
        status: 400,
        detail: "The payment cound not be verified",
      };
      res.status(problemDetails.status).json(problemDetails);
      return;
    }

    // Save donation to db - the following is structured as such to avoid floating point calculations as they lose precision
    const paymentData = chapaPymntVerifyResult.data as ChapaPaymentVerifyData;
    const amountInCentsBigInt =
      fromMoneyStrToBigInt(paymentData.amount.toFixed(2)) ?? 1n;
    const serviceRateNumerator =
      fromMoneyStrToBigInt(config.SERVICE_RATE.toFixed(2)) ?? 1n;
    const feeInCentsBigInt =
      (amountInCentsBigInt * serviceRateNumerator) / BigInt(100);

    const donation: Omit<CampaignDonation, "id"> = {
      campaignId,
      grossAmount: paymentData.amount.toFixed(2),
      serviceFee: fromIntToMoneyStr(feeInCentsBigInt) as string,
      createdAt: new Date(paymentData.created_at),
      isTransferred: false,
      transactionRef: paymentData.tx_ref,
    };

    const { isTransferred, ...insertedDonation } =
      await insertCampaignDonation(donation);
    void isTransferred;

    res.status(201).json(insertedDonation);
    return;
  }
);
