import { Router, Request, Response } from "express";
import { UUID } from "crypto";

import { readCampaigns } from "../repositories/campaign.repo.js";
import { getUserRoles } from "../services/user.service.js";
import { CampaignFilterSchema } from "../models/filters/campaign-filters.js";
import { ProblemDetails } from "../errors/error.types.js";
import { getUuidFromAuth0Id } from "../repositories/user.repo.js";
import { PaginatedList } from "../utils/util.types.js";
import { Campaign } from "../models/campaign.model.js";
import { excludeSensitiveCampaignProperties } from "../services/campaign.service.js";
import { validUuid } from "../utils/zod-helpers.js";

export const campaignRouter: Router = Router();

campaignRouter.get("/", async (req: Request, res: Response): Promise<void> => {
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

  // Omit sensitive query params
  const {
    /* eslint-disable @typescript-eslint/no-unused-vars */
    minSubmissionDate,
    maxSubmissionDate,
    minVerificationDate,
    maxVerificationDate,
    minDenialDate,
    maxDenialDate,
    isPublic,
    /* eslint-enable @typescript-eslint/no-unused-vars */
    ...publicQueryParams
  } = parsedQueryParams.data;

  const userRoles = getUserRoles(req.auth);
  let campaigns: PaginatedList<Campaign>;

  if (userRoles.includes("Supervisor")) {
    // REMOVE
    console.log("User is a supervisor.");

    // Supervisor: full access
    campaigns = await readCampaigns(parsedQueryParams.data);
  } else if (userRoles.includes("Recipient")) {
    // REMOVE
    console.log("User is a recipient.");

    const recipientIdFromParam = parsedQueryParams.data.ownerRecipientId;
    const recipientIdFromJwt = await getUuidFromAuth0Id(
      req.auth?.payload.sub ?? ""
    );

    if (recipientIdFromParam && recipientIdFromJwt === recipientIdFromParam) {
      // Recipient: own campaigns
      campaigns = await readCampaigns({
        ...parsedQueryParams.data,
        ownerRecipientId: recipientIdFromParam,
      });
    } else {
      // Recipient: public campaigns
      campaigns = excludeSensitiveCampaignProperties(
        await readCampaigns({
          ...publicQueryParams,
          isPublic: true,
        })
      );
    }
  } else {
    // REMOVE
    console.log("User is anonymous.");

    // Public campaigns
    campaigns = excludeSensitiveCampaignProperties(
      await readCampaigns({
        ...publicQueryParams,
        isPublic: true,
      })
    );
  }

  res.status(200).json(campaigns);
  return;
});

campaignRouter.get(
  "/:campaignId",
  async (req: Request, res: Response): Promise<void> => {
    const parsedPathParams = validUuid().safeParse(req.params.campaignId);
    if (!parsedPathParams.success) {
      const problemDetails: ProblemDetails = {
        title: "Validation Failure",
        status: 400,
        detail: parsedPathParams.error.issues[0].message,
      };
      res.status(problemDetails.status).json(problemDetails);
      return;
    }

    const campaignId = parsedPathParams.data as UUID;
    const userRoles = getUserRoles(req.auth);
    let campaign: Campaign;

    if (userRoles.includes("Supervisor")) {
      // REMOVE
      console.log("User is a supervisor.");

      // Supervisor: full access
      campaign = (await readCampaigns({ id: campaignId })).items[0];
    } else if (userRoles.includes("Recipient")) {
      // REMOVE
      console.log("User is a recipient.");

      const recipientIdFromJwt = await getUuidFromAuth0Id(
        req.auth?.payload.sub ?? ""
      );

      const tempCampaign = (
        await readCampaigns({
          id: campaignId,
          ownerRecipientId: recipientIdFromJwt,
        })
      ).items[0];

      if (tempCampaign) {
        // Recipient: Own campaign
        campaign = tempCampaign;
      } else {
        // Recipient: Public campaigns
        campaign = excludeSensitiveCampaignProperties(
          await readCampaigns({ id: campaignId, isPublic: true })
        ).items[0];
      }
    } else {
      // REMOVE
      console.log("User is anonymous.");

      // Public campaigns
      campaign = excludeSensitiveCampaignProperties(
        await readCampaigns({ id: campaignId, isPublic: true })
      ).items[0];
    }

    if (campaign) {
      res.status(200).json(campaign);
    } else {
      res.status(404).json({
        title: "Not Found",
        status: 404,
        detail: "Campaign not found.",
      });
    }

    return;
  }
);
