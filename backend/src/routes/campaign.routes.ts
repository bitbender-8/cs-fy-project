import { Router, Request, Response } from "express";

import { getCampaigns } from "../repositories/campaign.repo.js";
import { getUserRole } from "../services/user.service.js";
import {
  CampaignFilterSchema,
  SENSITIVE_CAMPAIGN_FILTERS,
} from "../models/filters/campaign-filters.js";
import { ProblemDetails } from "../errors/error.types.js";
import { getUuidFromAuth0Id } from "../repositories/user.repo.js";
import { PaginatedList, validateUuidParam } from "../utils/utils.js";
import {
  Campaign,
  SENSITIVE_CAMPAIGN_FIELDS,
  SensitiveCampaignFields,
} from "../models/campaign.model.js";
import { excludeProperties } from "../utils/utils.js";

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

  // Create filter params with sensitive filters omitted
  const queryParams = parsedQueryParams.data;
  const publicQueryParams = excludeProperties(
    queryParams,
    SENSITIVE_CAMPAIGN_FILTERS
  );

  let campaigns:
    | PaginatedList<Campaign>
    | PaginatedList<Omit<Campaign, SensitiveCampaignFields>>;
  const recipientIdFromParam = queryParams.ownerRecipientId;
  const userIdFromJwt = await getUuidFromAuth0Id(req.auth?.payload.sub ?? "");

  switch (getUserRole(req.auth)) {
    case "Supervisor":
      // Supervisor: full access
      campaigns = await getCampaigns(queryParams);
      break;
    case "Recipient":
      if (recipientIdFromParam && userIdFromJwt === recipientIdFromParam) {
        // Recipient: own campaigns, full access
        campaigns = await getCampaigns({
          ...queryParams,
          ownerRecipientId: recipientIdFromParam,
        });
      } else {
        // Recipient: public campaigns, partial access
        const result = await getCampaigns({
          ...publicQueryParams,
          isPublic: true,
        });

        campaigns = {
          ...result,
          items: result.items.map((campaign) =>
            excludeProperties(campaign, SENSITIVE_CAMPAIGN_FIELDS)
          ),
        };
      }
      break;

    default: {
      // Public campaigns
      const result = await getCampaigns({
        ...publicQueryParams,
        isPublic: true,
      });

      campaigns = {
        ...result,
        items: result.items.map((campaign) =>
          excludeProperties(campaign, SENSITIVE_CAMPAIGN_FIELDS)
        ),
      };
    }
  }

  res.status(200).json(campaigns);
  return;
});

campaignRouter.get(
  "/:id",
  async (req: Request, res: Response): Promise<void> => {
    const campaignId = validateUuidParam(req.params.id);
    let campaign: Campaign | Omit<Campaign, SensitiveCampaignFields>;

    switch (getUserRole(req.auth)) {
      case "Supervisor":
        // Supervisor: full access
        campaign = (await getCampaigns({ id: campaignId })).items[0];
        break;
      case "Recipient": {
        const recipientIdFromJwt = await getUuidFromAuth0Id(
          req.auth?.payload.sub ?? ""
        );
        const tempCampaign = (
          await getCampaigns({
            id: campaignId,
            ownerRecipientId: recipientIdFromJwt,
          })
        ).items[0];

        if (tempCampaign) {
          // Recipient: Own campaign
          campaign = tempCampaign;
        } else {
          // Recipient: Public campaigns
          campaign = excludeProperties(
            (await getCampaigns({ id: campaignId, isPublic: true })).items[0],
            SENSITIVE_CAMPAIGN_FIELDS
          );
        }
        break;
      }
      default:
        // Public campaigns
        campaign = excludeProperties(
          (await getCampaigns({ id: campaignId, isPublic: true })).items[0],
          SENSITIVE_CAMPAIGN_FIELDS
        );
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
