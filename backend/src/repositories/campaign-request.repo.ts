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
import { CampaignRequestFilter } from "../models/filters/campaign-request-filters.js";
import {
  fromIntToMoneyStr,
  fromMoneyStrToBigInt,
  PaginatedList,
} from "../utils/utils.js";
import { config } from "../config.js";
import { CampaignPostFilter } from "../models/filters/campaign-post-filters.js";

export async function insertCampaignRequest(
  campaignId: UUID,
  campaignRequest: Omit<CampaignRequest, LockedCampaignRequestFields>
): Promise<CampaignRequest> {
  try {
    let tableName: string;
    let columns: string =
      '"id", "campaignId", "title", "justification", "requestDate", "resolutionDate", ';
    const values: unknown[] = [
      randomUUID(),
      campaignId,
      campaignRequest.title,
      campaignRequest.justification,
      new Date(),
      null,
    ];

    switch (campaignRequest.requestType) {
      case "Goal Adjustment":
        tableName = '"GoalAdjustmentRequest"';
        columns += '"newGoal"';
        values.push(
          fromMoneyStrToBigInt(
            (
              campaignRequest as Omit<
                GoalAdjustmentRequest,
                LockedCampaignRequestFields
              >
            ).newGoal
          )
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
          ).newEndDate
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
          ).newStatus
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
              ).newPost
            )
          ).id
        );
        break;
      default:
        throw new AppError(
          "Validation Failure",
          400,
          `Invalid campaign request type '${campaignRequest.requestType}'`
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
            }
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
            }
          );
        }
        throw error;
      default:
        throw error;
    }
  }
}

export async function getCampaignRequests(
  filterParams: CampaignRequestFilter & { id?: UUID }
): Promise<PaginatedList<CampaignRequest>> {
  const limit = filterParams.limit ?? config.PAGE_SIZE;
  const pageNo = filterParams.page || 1;

  let paramIndex = 1;
  const whereClauses: string[] = [];
  const values: unknown[] = [];

  // Identify which filter params to applyl
  if (filterParams.id) {
    whereClauses.push(`req."id" = $${paramIndex}`);
    values.push(filterParams.campaignId);
    paramIndex++;
  }

  if (filterParams.campaignId) {
    whereClauses.push(`req."campaignId" = $${paramIndex}`);
    values.push(filterParams.campaignId);
    paramIndex++;
  }

  if (filterParams.title) {
    whereClauses.push(`req."title" ILIKE '%' || $${paramIndex} || '%'`);
    values.push(filterParams.title);
    paramIndex++;
  }

  if (filterParams.isResolved !== undefined) {
    console.log(filterParams.isResolved);
    whereClauses.push(
      `req."resolutionDate" ${filterParams.isResolved ? "IS NOT NULL" : "IS NULL"}`
    );
  }

  if (filterParams.minRequestDate) {
    whereClauses.push(`req."requestDate" >= $${paramIndex}`);
    values.push(filterParams.minRequestDate);
    paramIndex++;
  }

  if (filterParams.maxRequestDate) {
    whereClauses.push(`req."requestDate" <= $${paramIndex}`);
    values.push(filterParams.maxRequestDate);
    paramIndex++;
  }

  if (filterParams.minResolutionDate) {
    whereClauses.push(`req."resolutionDate" >= $${paramIndex}`);
    values.push(filterParams.minResolutionDate);
    paramIndex++;
  }

  if (filterParams.maxResolutionDate) {
    whereClauses.push(`req."resolutionDate" <= $${paramIndex}`);
    values.push(filterParams.maxResolutionDate);
    paramIndex++;
  }

  if (filterParams.ownerRecipientId) {
    whereClauses.push(`c."ownerRecipientId" = $${paramIndex}`);
    values.push(filterParams.ownerRecipientId);
    paramIndex++;
  }

  // The tablename used differs based on filterParams.requestType
  let tableName: string;

  // The columns to select, prepended with the alias for the table to select them from. 'req' refers to a campaign request table while 'c' refers to the Campaign table
  const columns: string[] = [
    'req."id"',
    'req."campaignId"',
    'req."title"',
    'req."justification"',
    'req."requestDate"',
    'req."resolutionDate"',
    'c."ownerRecipientId"',
  ];
  const joinClause: string = `JOIN "Campaign" c ON req."campaignId" = c."id"`;
  const whereClause =
    whereClauses.length > 0 ? ` WHERE ${whereClauses.join(" AND ")}` : "";

  switch (filterParams.requestType) {
    case "End Date Extension":
      tableName = '"EndDateExtensionRequest" req';
      columns.push('req."newEndDate"');
      break;
    case "Goal Adjustment":
      tableName = '"GoalAdjustmentRequest" req';
      columns.push('req."newGoal"');
      break;
    case "Post Update":
      tableName = '"PostUpdateRequest" req';
      columns.push('req."newPostId"');
      break;
    case "Status Change":
      tableName = '"StatusChangeRequest" req';
      columns.push('req."newStatus"');
      break;
    default: {
      const subQueryCols = columns.join(", ");
      tableName = `
      ((
        SELECT 
            ${subQueryCols},
            "newEndDate"::TIMESTAMPTZ AS "newEndDate", 
            NULL::BIGINT AS "newGoal", 
            NULL::UUID AS "newPostId", 
            NULL::"CampaignStatus" AS "newStatus" 
        FROM "EndDateExtensionRequest" req
      )
      UNION ALL
      (
        SELECT 
            ${subQueryCols},
            NULL::TIMESTAMPTZ AS "newEndDate", 
            "newGoal", 
            NULL::UUID AS "newPostId", 
            NULL::"CampaignStatus" AS "newStatus" 
        FROM "GoalAdjustmentRequest" req
      )
      UNION ALL
      (
        SELECT
            ${subQueryCols},
            NULL::TIMESTAMPTZ AS "newEndDate",
            NULL::BIGINT AS "newGoal",
            "newPostId",
            NULL::"CampaignStatus" as "newStatus"
        FROM "PostUpdateRequest" req
      )
      UNION ALL
      (
        SELECT
            ${subQueryCols},
            NULL::TIMESTAMPTZ as "newEndDate",
            NULL::BIGINT as "newGoal",
            NULL::UUID as "newPostId",
            "newStatus"
        FROM "StatusChangeRequest" req
      )) req
      `;
      break;
    }
  }

  const queryString = `
    SELECT 
      ${columns.join(", ")}
    FROM 
      ${tableName}
    ${joinClause}
    ${whereClause}
    LIMIT $${paramIndex} OFFSET $${paramIndex + 1}
  `;
  const offset = (pageNo - 1) * limit;
  values.push(limit, offset);

  const result = await query(queryString, values);

  const countQueryString = `
    SELECT COUNT(*) 
    FROM ${tableName} 
    ${joinClause} 
    ${whereClause}
  `;
  const countResult = await query(
    countQueryString,
    values.slice(0, values.length - 2)
  );

  const items = (result.rows as CampaignRequest[]).map(async (val) => {
    const campaignRequest = val as
      | CampaignRequest
      | (PostUpdateRequest & { newPostId?: UUID });

    switch (filterParams.requestType) {
      case "Goal Adjustment":
        if ("newGoal" in campaignRequest && campaignRequest.newGoal) {
          campaignRequest.newGoal = fromIntToMoneyStr(
            BigInt(campaignRequest.newGoal)
          ) as string;
        }
        break;
      case "Post Update":
        if ("newPostId" in campaignRequest && campaignRequest.newPostId) {
          campaignRequest.newPost = (
            await getCampaignPosts({
              id: campaignRequest.newPostId,
            })
          ).items[0];

          // Remove this property
          delete campaignRequest.newPostId;
        }
        break;
      default:
        // In case filterParams.requestType is empty or undefined
        if ("newGoal" in campaignRequest && campaignRequest.newGoal) {
          campaignRequest.newGoal = fromIntToMoneyStr(
            BigInt(campaignRequest.newGoal)
          ) as string;
        }
        if ("newPostId" in campaignRequest && campaignRequest.newPostId) {
          campaignRequest.newPost = (
            await getCampaignPosts({
              id: campaignRequest.newPostId,
            })
          ).items[0];
        }
    }
    return campaignRequest;
  });

  const resolvedItems = await Promise.all(items);
  const totalCount = parseInt(countResult.rows[0].count, 10);
  const pageCount = Math.ceil(totalCount / limit);

  return {
    items: resolvedItems,
    pageNo,
    pageCount,
  };
}

export async function getCampaignPosts(
  filterParams: CampaignPostFilter & { id?: UUID }
): Promise<PaginatedList<CampaignPost>> {
  const limit = filterParams.limit ?? config.PAGE_SIZE;
  const pageNo = filterParams.page || 1;
  const whereClauses: string[] = [];
  const values: unknown[] = [];
  let paramIndex = 1;

  if (filterParams.title) {
    whereClauses.push(`"title" ILIKE '%' || $${paramIndex} || '%'`);
    values.push(filterParams.title);
    paramIndex++;
  }

  if (filterParams.campaignId) {
    whereClauses.push(`"campaignId" = $${paramIndex}`);
    values.push(filterParams.campaignId);
    paramIndex++;
  }

  if (filterParams.isPublic !== undefined) {
    whereClauses.push(
      `"publicPostDate" ${filterParams.isPublic ? "IS NOT NULL" : "IS NULL"}`
    );
  }

  if (filterParams.minPublicPostDate) {
    whereClauses.push(`"publicPostDate" >= $${paramIndex}`);
    values.push(filterParams.minPublicPostDate);
    paramIndex++;
  }

  if (filterParams.maxPublicPostDate) {
    whereClauses.push(`"publicPostDate" <= $${paramIndex}`);
    values.push(filterParams.maxPublicPostDate);
    paramIndex++;
  }

  if (filterParams.id) {
    whereClauses.push(`"id" = $${paramIndex}`);
    values.push(filterParams.id);
    paramIndex++;
  }

  const whereClause =
    whereClauses.length > 0 ? `WHERE ${whereClauses.join(" AND ")}` : "";
  const offset = (pageNo - 1) * limit;

  const queryString = `
    SELECT "id", "title", "content", "publicPostDate", "campaignId"
    FROM "CampaignPost"
    ${whereClause}
    LIMIT $${paramIndex} OFFSET $${paramIndex + 1}
  `;

  values.push(limit, offset);

  const countQueryString = `
    SELECT COUNT(*) FROM "CampaignPost" ${whereClause}
  `;

  const result = await query(queryString, values);
  const countResult = await query(
    countQueryString,
    values.slice(0, values.length - 2)
  );

  const items = result.rows as CampaignPost[];
  const totalCount = parseInt(countResult.rows[0].count, 10);
  const pageCount = Math.ceil(totalCount / limit);

  return {
    items,
    pageNo,
    pageCount,
  };
}

export async function insertCampaignPost(
  campaignId: UUID,
  campaignPost: CampaignPost
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
      ]
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
            }
          );
        }
        throw error;
      default:
        throw error;
    }
  }
}
