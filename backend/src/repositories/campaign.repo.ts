import pg from "pg";

import { config } from "../config.js";
import { Campaign, PaymentInfo } from "../models/campaign.model.js";
import { PaginatedList } from "../utils/utils.js";
import { query } from "../db.js";
import { CampaignFilterParams } from "../models/filters/campaign-filters.js";
import { randomUUID, UUID } from "crypto";
import { AppError } from "../errors/error.types.js";

/** Validate filter params before passing */
export async function getCampaigns(
  filterParams: CampaignFilterParams & { id?: UUID }
): Promise<PaginatedList<Campaign>> {
  let queryString = `
        SELECT
            "id",
            "title",
            "description",
            "fundraisingGoal",
            "status",
            "category",
            "paymentMethod",
            "phoneNo",
            "bankAccountNo",
            "bankName",
            "submissionDate",
            "verificationDate",
            "denialDate",
            "launchDate",
            "endDate",
            "isPublic",
            "ownerRecipientId"
        FROM
            "Campaign"
    `;

  const limit = filterParams.limit ?? config.PAGE_SIZE;
  const pageNo = filterParams.page || 1;
  const whereClauses: string[] = [];
  const values: unknown[] = [];
  let paramIndex = 1;

  if (filterParams.id) {
    whereClauses.push(`"id" = $${paramIndex}`);
    values.push(filterParams.id);
    paramIndex++;
  }

  if (filterParams.title) {
    whereClauses.push(`"title" ILIKE '%' || $${paramIndex} || '%'`);
    values.push(filterParams.title);
    paramIndex++;
  }

  if (filterParams.status) {
    whereClauses.push(`"status" = $${paramIndex}`);
    values.push(filterParams.status);
    paramIndex++;
  }

  if (filterParams.category) {
    whereClauses.push(`"category" ILIKE '%' || $${paramIndex} || '%'`);
    values.push(filterParams.category);
    paramIndex++;
  }

  if (filterParams.ownerRecipientId) {
    whereClauses.push(`"ownerRecipientId" = $${paramIndex} `);
    values.push(filterParams.ownerRecipientId);
    paramIndex++;
  }

  if (filterParams.isPublic) {
    whereClauses.push(`"isPublic" = TRUE `);
  }

  const dateFilters = {
    launchDate: ["minLaunchDate", "maxLaunchDate"],
    submissionDate: ["minSubmissionDate", "maxSubmissionDate"],
    verificationDate: ["minVerificationDate", "maxVerificationDate"],
    denialDate: ["minDenialDate", "maxDenialDate"],
    endDate: ["minEndDate", "maxEndDate"],
  } as const;

  for (const dateField in dateFilters) {
    const [minParam, maxParam] =
      dateFilters[dateField as keyof typeof dateFilters];

    if (filterParams[minParam]) {
      whereClauses.push(`"${dateField}" >= $${paramIndex}`);
      values.push(filterParams[minParam]);
      paramIndex++;
    }
    if (filterParams[maxParam]) {
      whereClauses.push(`"${dateField}" <= $${paramIndex}`);
      values.push(filterParams[maxParam]);
      paramIndex++;
    }
  }

  const whereClause =
    whereClauses.length > 0 ? ` WHERE ${whereClauses.join(" AND ")}` : "";

  const countResult = await query(
    `SELECT COUNT(*) FROM "Campaign"${whereClause}`,
    values
  );
  const totalRecords = parseInt(countResult.rows[0].count, 10);
  const totalPages = Math.ceil(totalRecords / limit);

  queryString += whereClause;
  queryString += `
        ORDER BY
            "title" ASC
        LIMIT
            $${paramIndex}
        OFFSET
            ($${paramIndex + 1} - 1) * $${paramIndex}
    `;
  values.push(limit, pageNo);

  const campaigns: Campaign[] = await Promise.all(
    (await query(queryString, values)).rows.map(async (campaign) => {
      const { paymentMethod, phoneNo, bankAccountNo, bankName, ...rest } =
        campaign;

      return {
        ...rest,
        documents: await getDocumentUrls(campaign.id),
        paymentInfo: {
          paymentMethod,
          phoneNo,
          bankAccountNo,
          bankName,
        },
      };
    })
  );

  return {
    items: campaigns ?? [],
    pageCount: totalPages === 0 ? 1 : totalPages,
    pageNo: pageNo,
  };
}

export async function insertCampaign(
  ownerRecipientId: UUID,
  campaign: Campaign
): Promise<Campaign> {
  try {
    const result = await query(
      ` INSERT INTO "Campaign" (
          "id",
          "title",
          "description",
          "fundraisingGoal",
          "status",
          "category",
          "paymentMethod",
          "phoneNo",
          "bankAccountNo",
          "bankName",
          "submissionDate",
          "isPublic",
          "ownerRecipientId"
        ) VALUES (
            $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13
        ) RETURNING * 
      `,
      [
        randomUUID(),
        campaign.title,
        campaign.description,
        campaign.fundraisingGoal,
        "Pending Review",
        campaign.category,
        campaign.paymentInfo.paymentMethod,
        campaign.paymentInfo.phoneNo,
        campaign.paymentInfo.bankAccountNo,
        campaign.paymentInfo.bankName,
        new Date(),
        false,
        ownerRecipientId,
      ]
    );

    if (!result || result.rows.length === 0) {
      throw new AppError("Internal Server Error", 500, "Something went wrong", {
        internalDetails: "Campaign insertion failed",
      });
    }

    const {
      paymentMethod,
      phoneNo,
      bankAccountNo,
      bankName,
      ...insertedCampaign
    } = result.rows[0] as Omit<Campaign, "paymentInfo"> & PaymentInfo;

    // Insert document urls if they exist
    if (campaign.documents && campaign.documents.length > 0) {
      insertedCampaign.documents = [];

      for (const document of campaign.documents) {
        const insertedDocument = (
          await insertDocumentUrl({
            ...document,
            campaignId: insertedCampaign.id,
          })
        ).document;

        insertedCampaign.documents.push(insertedDocument);
      }
    }

    return {
      ...insertedCampaign,
      paymentInfo: {
        paymentMethod,
        phoneNo,
        bankAccountNo,
        bankName,
      },
    };
  } catch (error) {
    if (!(error instanceof pg.DatabaseError)) {
      throw error;
    }

    switch (error.code) {
      case "23503":
        if (error.constraint === "Campaign_recipientId_fkey") {
          throw new AppError(
            "Internal Server Error",
            500,
            "Something went wrong",
            {
              internalDetails:
                "The recipient ID specified for the campaign does not exist.",
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

async function insertDocumentUrl(document: {
  campaignId: UUID;
  documentUrl: string;
  redactedDocumentUrl?: string;
}): Promise<{
  document: {
    campaignId: UUID;
    documentUrl: string;
    redactedDocumentUrl?: string;
  };
}> {
  try {
    const result = await query(
      `
      INSERT INTO 
        "CampaignDocuments" (
          "documentUrl",
          "redactedDocumentUrl",
          "campaignId"
        ) VALUES (
         $1, $2, $3
        ) RETURNING *`,
      [
        document.documentUrl,
        document.redactedDocumentUrl ?? null,
        document.campaignId,
      ]
    );

    if (!result || result.rows.length === 0) {
      throw new AppError("Internal Server Error", 500, "Something went wrong", {
        internalDetails: `Failed to insert document urls of the campaign with id ${document.campaignId}`,
      });
    }

    return {
      document: {
        campaignId: result.rows[0].campaignId,
        documentUrl: result.rows[0].documentUrl,
        redactedDocumentUrl: result.rows[0].redactedDocumentUrl,
      },
    };
  } catch (error) {
    // There is no need to handle the case where the document url is not unique, because every document url has a name that contains a randomly generated uuid.
    if (!(error instanceof pg.DatabaseError)) {
      throw error;
    }

    switch (error.code) {
      case "23503":
        if (error.constraint === "CampaignDocuments_campaignId_fkey") {
          throw new AppError(
            "Internal Server Error",
            500,
            "Something went wrong",
            {
              internalDetails: `The campaign ID specified for the document url does not exist.`,
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

async function getDocumentUrls(campaignId: UUID): Promise<
  {
    campaignId: UUID;
    documentUrl: string;
    redactedDocumentUrl: string;
  }[]
> {
  const result = await query(
    `
    SELECT 
      "campaignId",
      "documentUrl",
      "redactedDocumentUrl"
    FROM
      "CampaignDocuments"
    WHERE
      "campaignId" = $1
    `,
    [campaignId]
  );

  if (!result || result.rows.length === 0) {
    return [];
  }

  return result.rows;
}
