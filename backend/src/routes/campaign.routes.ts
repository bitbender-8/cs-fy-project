import { Router, Request, Response } from "express";

import { readCampaigns } from "../repositories/campaign.repo.js";
import { getUserRoles } from "../services/user.service.js";
import { CampaignFilterSchema } from "../models/filters/campaign-filters.js";
import { ProblemDetails } from "../errors/error.types.js";
import { getUuidFromAuth0Id } from "../repositories/user.repo.js";
import { PaginatedList } from "../utils/util.types.js";
import { Campaign, SensitiveCampaignFields } from "../models/campaign.model.js";
import { excludeSensitiveCampaignProperties } from "../services/campaign.service.js";

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

  if (getUserRoles(req.auth).includes("Supervisor")) {
    // Supervisors have access to all filterParams, and campaigns
    res.status(200).json(await readCampaigns(parsedQueryParams.data));
  } else if (getUserRoles(req.auth).includes("Recipient")) {
    // Recipients have access to public campaigns, and campaigns which they own.

    const recipientIdFromParam = parsedQueryParams.data.ownerRecipientId;
    const recipientIdFromJwt = await getUuidFromAuth0Id(
      req.auth?.payload.sub ?? "",
    );

    if (!recipientIdFromJwt) {
      const problemDetails = {
        title: "Internal Server Error",
        status: 500,
        detail: "Something went wrong.",
      };
      console.error(
        "Fail: Something went wrong while retrieving the Recipient's ID.",
      );
      res.status(problemDetails.status).json(problemDetails);
      return;
    }

    // If the recipient specifies their own id in the query parameter, then are given full access to all campaigns which they own
    if (recipientIdFromParam && recipientIdFromJwt === recipientIdFromParam) {
      res.status(200).json(
        await readCampaigns({
          ...parsedQueryParams.data,
          ownerRecipientId: recipientIdFromParam,
        }),
      );
      return;
    } else {
      // Otherwise, the recipient is given access to public campiagns, and public query params.

      const campaigns: PaginatedList<Omit<Campaign, SensitiveCampaignFields>> =
        excludeSensitiveCampaignProperties(
          await readCampaigns({
            title: parsedQueryParams.data.title,
            status: parsedQueryParams.data.status,
            category: parsedQueryParams.data.category,
            minLaunchDate: parsedQueryParams.data.minLaunchDate,
            maxLaunchDate: parsedQueryParams.data.maxLaunchDate,
            minEndDate: parsedQueryParams.data.minEndDate,
            maxEndDate: parsedQueryParams.data.maxEndDate,
            isPublic: true,
            page: parsedQueryParams.data.page,
            limit: parsedQueryParams.data.limit,
          }),
        );

      res.status(200).json(campaigns);
    }
  } else {
    res.status(200).json(
      excludeSensitiveCampaignProperties(
        await readCampaigns({
          title: parsedQueryParams.data.title,
          status: parsedQueryParams.data.status,
          category: parsedQueryParams.data.category,
          minLaunchDate: parsedQueryParams.data.minLaunchDate,
          maxLaunchDate: parsedQueryParams.data.maxLaunchDate,
          minEndDate: parsedQueryParams.data.minEndDate,
          maxEndDate: parsedQueryParams.data.maxEndDate,
          isPublic: true,
          page: parsedQueryParams.data.page,
          limit: parsedQueryParams.data.limit,
        }),
      ),
    );
  }
});

campaignRouter.get(
  "/:campaignId",
  async (req: Request, res: Response): Promise<void> => {
    // REMOVE
    console.log(req, res);
  },
);
