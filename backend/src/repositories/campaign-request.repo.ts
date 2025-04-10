import { randomUUID, UUID } from "crypto";
import pg from "pg";

import {
  CampaignRequest,
  EndDateExtensionRequest,
  GoalAdjustmentRequest,
  LockedCampaignRequestFields,
  PostUpdateRequest,
  StatusChangeRequest,
} from "../models/campaign-request.model.js";
import { AppError } from "../errors/error.types.js";
import { query } from "../db.js";
import { CampaignPost } from "../models/campaign.model.js";

export async function insertCampaignRequest(
  campaignId: UUID,
  campaignRequest: Omit<CampaignRequest, LockedCampaignRequestFields>,
): Promise<CampaignRequest> {
  try {
    let tableName: string;
    let columns: string =
      '"id", "campaignId", "title", "justification", "requestDate", ';
    const values: unknown[] = [
      randomUUID(),
      campaignId,
      campaignRequest.title,
      campaignRequest.justification,
      new Date(),
    ];

    switch (campaignRequest.requestType) {
      case "Goal Adjustment":
        tableName = '"GoalAdjustmentRequest"';
        columns += '"newGoal"';
        values.push(
          (
            campaignRequest as Omit<
              GoalAdjustmentRequest,
              LockedCampaignRequestFields
            >
          ).newGoal,
        );
        break;
      case "End Date Extension":
        tableName = '"EndDateExtensionRequest"';
        columns += '"newEndDate"';
        values.push(
          (
            campaignRequest as Omit<
              EndDateExtensionRequest,
              LockedCampaignRequestFields
            >
          ).newEndDate,
        );
        break;
      case "Status Change":
        tableName = '"StatusChangeRequest"';
        columns += '"newStatus"';
        values.push(
          (
            campaignRequest as Omit<
              StatusChangeRequest,
              LockedCampaignRequestFields
            >
          ).newStatus,
        );
        break;
      case "Post Update":
        tableName = '"PostUpdateRequest"';
        columns += '"newPostId"';
        values.push(
          (
            await insertCampaignPost(
              campaignId,
              (
                campaignRequest as Omit<
                  PostUpdateRequest,
                  LockedCampaignRequestFields
                >
              ).newPost,
            )
          ).id,
        );
        break;
      default:
        throw new AppError(
          "Validation Failure",
          400,
          `Invalid campaign request type '${campaignRequest.requestType}'`,
        );
    }

    const queryString = `
      INSERT INTO ${tableName} (
        ${columns}
      )
      VALUES (
        ${values.map((_, index) => `$${index + 1}`).join(", ")}
      ) RETURNING *;
    `;

    const result = await query(queryString, values);

    if (!result || result.rows.length === 0) {
      throw new AppError("Internal Server Error", 500, "Something went wrong", {
        internalDetails: "Campaign request insertion failed",
      });
    }

    return result.rows[0] as CampaignRequest;
  } catch (error) {
    if (!(error instanceof pg.DatabaseError)) {
      throw error;
    }

    switch (error.code) {
      case "23503":
        if (
          error.constraint === "GoalAdjustmentRequest_campaignId_fkey" ||
          error.constraint === "EndDateExtensionRequest_campaignId_fkey" ||
          error.constraint === "StatusChangeRequest_campaignId_fkey" ||
          error.constraint === "PostUpdateRequest_campaignId_fkey"
        ) {
          throw new AppError(
            "Internal Server Error",
            500,
            "Something went wrong",
            {
              internalDetails:
                "The campaign ID specified for the campaign request does not exist",
              cause: error,
            },
          );
        }
        if (error.constraint === "PostUpdateRequest_newPostId_fkey") {
          throw new AppError(
            "Internal Server Error",
            500,
            "Something went wrong",
            {
              internalDetails:
                "The campaign post with specified ID does not exist",
              cause: error,
            },
          );
        }
        throw error;
      default:
        throw error;
    }
  }
}

export async function insertCampaignPost(
  campaignId: UUID,
  campaignPost: CampaignPost,
): Promise<CampaignPost> {
  try {
    const result = await query(
      `INSERT INTO "CampaignPost" (
        "id",
        "title",
        "content",
        "publicPostDate",
        "campaignId"
       ) VALUES (
        $1, $2, $3, $4, $5
       ) RETURNING *
    `,
      [
        randomUUID(),
        campaignPost.title,
        campaignPost.content,
        campaignPost.publicPostDate,
        campaignId,
      ],
    );

    if (!result || result.rows.length === 0) {
      throw new AppError("Internal Server Error", 500, "Something went wrong", {
        internalDetails: "Campaign post insertion failed",
      });
    }

    return result.rows[0] as CampaignPost;
  } catch (error) {
    if (!(error instanceof pg.DatabaseError)) {
      throw error;
    }

    switch (error.code) {
      case "23503":
        if (error.constraint === "CampaignPost_campaignId_fkey") {
          throw new AppError(
            "Internal Server Error",
            500,
            "Something went wrong",
            {
              internalDetails: `The campaign ID specified for the campaign post does not exist`,
              cause: error,
            },
          );
        }
        throw error;
      default:
        throw error;
    }
  }
}
