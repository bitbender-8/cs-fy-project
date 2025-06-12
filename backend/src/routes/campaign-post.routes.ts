import { Router, Request, Response } from "express";

import { optionalAuth, requireAuth } from "../middleware/auth.middleware.js";
import { validateQueryParams } from "../middleware/query-param.middleware.js";
import {
  CampaignPostFilter,
  CampaignPostFilterSchema,
  SENSITIVE_CAMPAIGN_POST_FILTERS,
} from "../models/filters/campaign-post-filters.js";
import {
  excludeProperties,
  PaginatedList,
  validateUuidParam,
} from "../utils/utils.js";
import { getUserRole } from "../services/user.service.js";
import { CampaignPost } from "../models/campaign.model.js";
import { getUuidFromAuth0Id } from "../repositories/user.repo.js";
import {
  deleteCampaignPost,
  getCampaignPosts,
} from "../repositories/campaign-request.repo.js";
import { getCampaigns } from "../repositories/campaign.repo.js";
import { ProblemDetails } from "../errors/error.types.js";

export const campaignPostRouter: Router = Router();

/**
 * @route GET /campaign-posts
 * @description Retrieves a paginated list of campaign posts based on filter criteria.
 * Access to campaign posts is restricted based on user role and post visibility.
 * Supervisors can see all campaign posts.
 * Recipients can see all posts for campaigns they own, and public posts for other campaigns.
 * Unauthenticated users and other roles can only see public campaign posts.
 *
 * @param {Request} req - Express request object, expects query parameters for filtering (see `CampaignPostFilterSchema`).
 * @param {Response} res - Express response object.
 * @returns {Response} 200 - A paginated list of campaign posts.
 */
campaignPostRouter.get(
  "/",
  optionalAuth,
  validateQueryParams(CampaignPostFilterSchema),
  async (req: Request, res: Response): Promise<void> => {
    const filterParams = req.validatedParams as CampaignPostFilter;
    const publicFilterParams = {
      ...excludeProperties(filterParams, SENSITIVE_CAMPAIGN_POST_FILTERS),
      isPublic: true,
    };

    let campaignPosts: PaginatedList<CampaignPost>;

    switch (getUserRole(req.auth)) {
      case "Recipient": {
        const userUuid = await getUuidFromAuth0Id(req.auth?.payload.sub ?? "");
        const campaign = filterParams.campaignId
          ? (
              await getCampaigns({
                id: filterParams.campaignId,
                ownerRecipientId: userUuid,
              })
            ).items[0]
          : undefined;

        campaignPosts =
          campaign?.ownerRecipientId !== userUuid
            ? await getCampaignPosts(publicFilterParams)
            : await getCampaignPosts({
                ...filterParams,
              });

        break;
      }
      case "Supervisor":
        campaignPosts = await getCampaignPosts(filterParams);
        break;
      default:
        campaignPosts = await getCampaignPosts(publicFilterParams);
        break;
    }

    res.status(200).json(campaignPosts);
    return;
  },
);

/**
 * @route DELETE /campaign-posts/:id
 * @description Deletes a campaign post. This route is intended for supervisors only.
 *
 * @param {string} req.params.id - The UUID of the campaign post to delete.
 * @param {Request} req - Express request object.
 * @param {Response} res - Express response object.
 * @returns {Response} 204 - If the campaign post was successfully deleted.
 * @returns {Response} 403 - If the user is not a supervisor.
 * @returns {Response} 404 - If the campaign post is not found.
 */
campaignPostRouter.delete(
  "/:id",
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

    const campaignPostId = validateUuidParam(req.params.id);
    const deleteResult: boolean = await deleteCampaignPost(campaignPostId);

    if (!deleteResult) {
      const problemDetails: ProblemDetails = {
        title: "Not Found",
        status: 404,
        detail: `Campaign post with id '${campaignPostId}' was not found`,
      };
      res.status(problemDetails.status).json(problemDetails);
      return;
    }
    res.status(204).send();
  },
);
