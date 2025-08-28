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
  excludeProperties,
  fromMoneyStrToBigInt,
  PaginatedList,
} from "../utils/utils.js";
import { config } from "../config.js";
import { CampaignPostFilter } from "../models/filters/campaign-post-filters.js";
import {
  CombinedRequestType,
  transformCampaignRequest,
} from "../services/campaign.service.js";
import { buildUpdateQueryString } from "./repo-utils.js";

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
    // Used for post update request
    let insertedCampaignPost = null;

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
      case "Post Update": {
        insertedCampaignPost = await insertCampaignPost(
          campaignId,
          (
            campaignRequest as Omit<
              PostUpdateRequest,
              LockedCampaignRequestFields
            >
          ).newPost
        );
        tableName = '"PostUpdateRequest"';
        columns += '"newPostId"';

        values.push(insertedCampaignPost.id);

        break;
      }
      default:
        throw new AppError(
          "Validation Failure",
          400,
          `Invalid campaign request type '${campaignRequest.requestType}'`
        );
    }

    const queryString = `
      WITH inserted AS (
        INSERT INTO ${tableName} (
          ${columns}
        )
        VALUES (
          ${values.map((_, index) => `$${index + 1}`).join(", ")}
        )
        RETURNING *
      )
      SELECT 
        inserted.*, 
        '${campaignRequest.requestType}' AS "requestType",
        c."ownerRecipientId"
      FROM inserted
      JOIN "Campaign" c ON inserted."campaignId" = c."id";
    `;

    const result = await query(queryString, values);

    if (!result || result.rows.length === 0) {
      throw new AppError("Internal Server Error", 500, "Something went wrong", {
        internalDetails: "Campaign request insertion failed",
      });
    }

    if (campaignRequest.requestType === "Post Update") {
      return {
        ...excludeProperties<
          PostUpdateRequest & { newPostId: string },
          "newPostId"
        >(result.rows[0], ["newPostId"]),
        newPost: insertedCampaignPost,
      } as PostUpdateRequest;
    } else {
      return result.rows[0] as CampaignRequest;
    }
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
    values.push(filterParams.id);
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

  if (filterParams.resolutionType) {
    whereClauses.push(`req."resolutionType" = $${paramIndex}`);
    values.push(filterParams.resolutionType);
    paramIndex++;
  }

  if (filterParams.isResolved !== undefined) {
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
    'req."resolutionType"',
    'c."ownerRecipientId"',
  ];
  const joinClause: string = `JOIN "Campaign" c ON req."campaignId" = c."id"`;
  const whereClause =
    whereClauses.length > 0 ? ` WHERE ${whereClauses.join(" AND ")}` : "";

  switch (filterParams.requestType) {
    case "End Date Extension":
      tableName = '"EndDateExtensionRequest" req';
      columns.push('req."newEndDate"');
      columns.push(`'End Date Extension' AS "requestType"`);
      break;
    case "Goal Adjustment":
      tableName = '"GoalAdjustmentRequest" req';
      columns.push('req."newGoal"');
      columns.push(`'Goal Adjustment' AS "requestType"`);
      break;
    case "Post Update":
      tableName = '"PostUpdateRequest" req';
      columns.push('req."newPostId"');
      columns.push(`'Post Update' AS "requestType"`);
      break;
    case "Status Change":
      tableName = '"StatusChangeRequest" req';
      columns.push('req."newStatus"');
      columns.push(`'Status Change' AS "requestType"`);
      break;
    default: {
      const subQueryCols = columns
        .filter(
          (val) => val !== 'c."ownerRecipientId"' && val !== 'req."requestType"'
        )
        .join(", ");

      columns.push('"requestType"');
      columns.push('req."newStatus"');
      columns.push('req."newPostId"');
      columns.push('req."newGoal"');
      columns.push('req."newEndDate"');

      tableName = `
      ((
        SELECT
            'End Date Extension' AS "requestType",
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
            'Goal Adjustment' AS "requestType",
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
            'Post Update' AS "requestType",
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
            'Status Change' AS "requestType",
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
    ORDER BY req."requestDate" DESC
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

  const items = (result.rows as CombinedRequestType[]).map(
    transformCampaignRequest
  );

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

export async function resolveCampaignRequest(
  campaignRequestId: UUID
): Promise<CampaignRequest> {
  const campaignRequest = (await getCampaignRequests({ id: campaignRequestId }))
    .items[0];

  if (!campaignRequest) {
    throw new AppError("Not Found", 404, "Campaign request not found.", {
      internalDetails: `Campaign request with ID ${campaignRequestId} not found.`,
    });
  }

  let tableName: string;

  switch (campaignRequest.requestType) {
    case "End Date Extension":
      tableName = "EndDateExtensionRequest";
      break;
    case "Goal Adjustment":
      tableName = "GoalAdjustmentRequest";
      break;
    case "Post Update":
      tableName = "PostUpdateRequest";
      break;
    case "Status Change":
      tableName = "StatusChangeRequest";
      break;
    default:
      throw new AppError("Internal Server Error", 500, "Something went wrong", {
        internalDetails:
          "Invalid campaign request type encountered while processing results",
      });
  }

  const result = await query(
    `UPDATE "${tableName}"
       SET
        "resolutionDate" = $1
       WHERE
        "id" = $2
       RETURNING *
      `,
    [new Date(), campaignRequestId]
  );

  if (result.rows.length === 0) {
    throw new AppError("Not Found", 404, "Campaign request not found.", {
      internalDetails: `Campaign request with ID ${campaignRequestId} not found in ${tableName}.`,
    });
  }

  return result.rows[0] as CampaignRequest;
}

export async function updateCampaignPost(
  postId: UUID,
  postData: Partial<CampaignPost>
): Promise<CampaignPost> {
  const { fragments, values } = buildUpdateQueryString(
    excludeProperties(postData, ["id", "campaignId"])
  );

  if (fragments.length === 0) {
    // If no fields to update, just return the existing post.
    const getResult = await query(
      `SELECT * FROM "CampaignPost" WHERE "id" = $1`,
      [postId]
    );
    if (getResult.rows.length === 0) {
      throw new AppError("Not Found", 404, "Campaign post not found.", {
        internalDetails: `Campaign post with id ${postId} not found`,
      });
    }
    return getResult.rows[0] as CampaignPost;
  }

  const updateQuery = `
      UPDATE "CampaignPost"
      SET ${fragments.join(", ")}
      WHERE "id" = $${values.length + 1}
      RETURNING *
    `;

  const result = await query(updateQuery, [...values, postId]);

  if (result.rows.length === 0) {
    throw new AppError("Not Found", 404, "Campaign post not found.", {
      internalDetails: `Campaign post with id ${postId} not found`,
    });
  }

  return result.rows[0] as CampaignPost;
}

export async function deleteCampaignRequest(
  campaignRequestId: UUID
): Promise<boolean> {
  const deleteEndDateExtensionResult = await query(
    'DELETE FROM "EndDateExtensionRequest" WHERE "id" = $1',
    [campaignRequestId]
  );

  const deletePostUpdateResult = await query(
    'DELETE FROM "PostUpdateRequest" WHERE "id" = $1',
    [campaignRequestId]
  );

  const deleteStatusChangeResult = await query(
    'DELETE FROM "StatusChangeRequest" WHERE "id" = $1',
    [campaignRequestId]
  );

  const deleteGoalAdjustmentResult = await query(
    'DELETE FROM "GoalAdjustmentRequest" WHERE "id" = $1',
    [campaignRequestId]
  );

  return (
    (deleteEndDateExtensionResult?.rowCount ?? 0) > 0 ||
    (deletePostUpdateResult?.rowCount ?? 0) > 0 ||
    (deleteStatusChangeResult?.rowCount ?? 0) > 0 ||
    (deleteGoalAdjustmentResult?.rowCount ?? 0) > 0
  );
}

export async function deleteCampaignPost(postId: UUID): Promise<boolean> {
  const result = await query(`DELETE FROM "CampaignPost" WHERE "id" = $1`, [
    postId,
  ]);

  return (result.rowCount ?? -1) > 0;
}
