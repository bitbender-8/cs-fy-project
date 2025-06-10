import pg from "pg";

import { config } from "../config.js";
import {
  Campaign,
  CampaignDocument,
  CampaignDonation,
  CreateableCampaignFields,
  PaymentInfo,
} from "../models/campaign.model.js";
import {
  excludeProperties,
  fromIntToMoneyStr,
  fromMoneyStrToBigInt,
  PaginatedList,
} from "../utils/utils.js";
import { query } from "../db.js";
import {
  CampaignDocumentFilterParams,
  CampaignFilterParams,
} from "../models/filters/campaign-filters.js";
import { randomUUID, UUID } from "crypto";
import { AppError } from "../errors/error.types.js";
import { buildUpdateQueryString } from "./repo-utils.js";

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
            "chapaBankCode",
            "chapaBankName",
            "bankAccountNo",
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
            "launchDate" DESC
        LIMIT
            $${paramIndex}
        OFFSET
            ($${paramIndex + 1} - 1) * $${paramIndex}
    `;
  values.push(limit, pageNo);

  const campaigns: Campaign[] = await Promise.all(
    (await query(queryString, values)).rows.map(async (campaign) => {
      const {
        chapaBankCode,
        chapaBankName,
        bankAccountNo,
        fundraisingGoal,
        ...rest
      } = campaign;

      return {
        ...rest,
        fundraisingGoal: fromIntToMoneyStr(BigInt(fundraisingGoal)),
        documents: (await getCampaignDocuments({ campaignId: campaign.id }))
          .items,
        totalDonated: await getCampaignDonationTotal(campaign.id),
        paymentInfo: {
          chapaBankCode,
          chapaBankName,
          bankAccountNo,
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
  campaign: Pick<Campaign, CreateableCampaignFields>
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
          "chapaBankCode",
          "chapaBankName",
          "bankAccountNo",
          "submissionDate",
          "endDate",
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
        fromMoneyStrToBigInt(campaign.fundraisingGoal),
        "Pending Review",
        campaign.category,
        campaign.paymentInfo.chapaBankCode,
        campaign.paymentInfo.chapaBankName,
        campaign.paymentInfo.bankAccountNo,
        new Date(),
        campaign.endDate,
        false,
        ownerRecipientId,
      ]
    );

    if (!result || result.rows.length === 0) {
      throw new AppError("Internal Server Error", 500, "Something went wrong", {
        internalDetails: "Campaign insertion failed",
      });
    }

    const { chapaBankCode, chapaBankName, bankAccountNo, ...insertedCampaign } =
      result.rows[0] as Omit<Campaign, "paymentInfo"> & PaymentInfo;

    // Insert document urls if they exist
    if (campaign.documents && campaign.documents.length > 0) {
      insertedCampaign.documents = [];

      for (const document of campaign.documents) {
        const insertedDocument = await insertCampaignDocument({
          ...document,
          campaignId: insertedCampaign.id,
        });

        insertedCampaign.documents.push(insertedDocument);
      }
    }

    return {
      ...insertedCampaign,
      paymentInfo: {
        chapaBankCode,
        chapaBankName,
        bankAccountNo,
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

export async function updateCampaign(
  campaignId: UUID,
  campaignData: Omit<Campaign, "paymentInfo" | "ownerRecipientId" | "id">
): Promise<Campaign> {
  // No need for special try-catch wrapper because there are no columns with special constraints..
  const { fragments, values: updateValues } = buildUpdateQueryString(
    excludeProperties(campaignData, ["documents", "fundraisingGoal"])
  );

  if (campaignData.fundraisingGoal !== undefined) {
    fragments.push(`"fundraisingGoal" = $${updateValues.length + 1}`);
    updateValues.push(fromMoneyStrToBigInt(campaignData.fundraisingGoal));
  }

  if (fragments.length === 0) {
    throw new AppError(
      "Validation Failure",
      400,
      "Campaign body cannot be empty"
    );
  }

  const updateQuery = `
      UPDATE "Campaign"
      SET
        ${fragments.join(", ")}
      WHERE
        "id" = $${updateValues.length + 1}
      RETURNING *
    `;

  updateValues.push(campaignId);
  const result = await query(updateQuery, updateValues);

  if (!result || result.rows.length === 0) {
    throw new AppError("Not Found", 404, "Campaign not found", {
      internalDetails: "A campaign with the given Id does not exist",
    });
  }

  const updatedCampaign = result.rows[0] as Campaign;
  updatedCampaign.documents = [];

  if (campaignData.documents && campaignData.documents.length > 0) {
    // Only redactedDocumentUrls can be updated. documentUrls can't because they are the ID of the document object.
    for (const document of campaignData.documents) {
      await updateCampaignDocument({
        documentUrl: document.documentUrl,
        redactedDocumentUrl: document.redactedDocumentUrl,
      });
    }
  }

  updatedCampaign.documents.concat(
    (await getCampaignDocuments({ campaignId })).items
  );

  return updatedCampaign;
}

export async function insertCampaignDocument(
  document: CampaignDocument
): Promise<CampaignDocument> {
  try {
    const result = await query<CampaignDocument>(
      `INSERT INTO 
        "CampaignDocuments" (
          "documentUrl",
          "redactedDocumentUrl",
          "campaignId"
        ) VALUES (
         $1, $2, $3
        ) RETURNING *
      `,
      [
        document.documentUrl,
        document.redactedDocumentUrl ?? null,
        document.campaignId,
      ]
    );

    if (!result || result.rows.length === 0) {
      throw new AppError("Internal Server Error", 500, "Something went wrong", {
        internalDetails: `Failed to insert document url of the campaign with id ${document.campaignId}`,
      });
    }

    return result.rows[0];
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

export async function getCampaignDocuments(
  filterParams: CampaignDocumentFilterParams = {}
): Promise<PaginatedList<CampaignDocument>> {
  const limit = filterParams.limit ?? config.PAGE_SIZE;
  const pageNo = filterParams.page ?? 1;

  const whereClauses: string[] = [];
  const values: unknown[] = [];
  let paramIndex = 1;

  if (filterParams.campaignId) {
    whereClauses.push(`"campaignId" = $${paramIndex++}`);
    values.push(filterParams.campaignId);
  }

  if (filterParams.documentUrl) {
    whereClauses.push(`"documentUrl" = $${paramIndex++}`);
    values.push(filterParams.documentUrl);
  }

  if (filterParams.redactedDocumentUrl) {
    whereClauses.push(`"redactedDocumentUrl" = $${paramIndex++}`);
    values.push(filterParams.redactedDocumentUrl);
  }

  const whereClause =
    whereClauses.length > 0 ? ` WHERE ${whereClauses.join(" AND ")}` : "";

  const countQuery = `SELECT COUNT(*) FROM "CampaignDocuments"${whereClause}`;
  const countResult = await query(countQuery, values);
  const totalRecords = parseInt(countResult.rows[0].count, 10);
  const totalPages = Math.max(Math.ceil(totalRecords / limit), 1);

  const queryString = `
    SELECT
      "campaignId",
      "documentUrl",
      "redactedDocumentUrl"
    FROM
      "CampaignDocuments"
    ${whereClause}
    ORDER BY
      "documentUrl" ASC
    LIMIT $${paramIndex}
    OFFSET $${paramIndex + 1}
  `;

  values.push(limit, (pageNo - 1) * limit);

  const result = await query(queryString, values);
  const documents: CampaignDocument[] = result.rows;

  return {
    items: documents,
    pageCount: totalPages,
    pageNo: pageNo,
  };
}

// Updates only the redactedDocumentUrl
export async function updateCampaignDocument(
  document: Omit<CampaignDocument, "campaignId">
): Promise<CampaignDocument> {
  try {
    const result = await query<CampaignDocument>(
      `UPDATE "CampaignDocuments"
       SET
        "redactedDocumentUrl" = $2
       WHERE
        "documentUrl" = $1
       RETURNING *
      `,
      [document.documentUrl, document.redactedDocumentUrl]
    );

    if (!result || result.rows.length === 0) {
      throw new AppError("Internal Server Error", 500, "Something went wrong", {
        internalDetails: "Failed to update campaign's redacted document",
      });
    }

    return result.rows[0];
  } catch (error) {
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

export async function getCampaignDonationTotal(
  campaignId: UUID
): Promise<string> {
  const result = await query(
    `SELECT SUM("grossAmount" - "serviceFee") AS "netDonations" 
     FROM "CampaignDonation"
     WHERE "campaignId" = $1`,
    [campaignId]
  );

  if (!result || result.rows.length === 0 || !result.rows[0].netDonations) {
    return "0";
  }

  return fromIntToMoneyStr(BigInt(result.rows[0].netDonations)) ?? "0";
}

export async function insertCampaignDonation(
  donation: Omit<CampaignDonation, "id">
): Promise<CampaignDonation> {
  try {
    const result = await query(
      `INSERT INTO "CampaignDonation" (
        "id,
        "grossAmount",
        "serviceFee",
        "createdAt"
        "transactionRef"
        "campaignId"
      ) VALUES (
        $1, $2, $3, $4, $5, $6
      ) RETURNING *`,
      [
        randomUUID(),
        donation.grossAmount,
        donation.serviceFee,
        donation.createdAt ?? new Date(),
        donation.transactionRef,
        donation.campaignId,
      ]
    );

    if (!result || result.rows.length === 0) {
      throw new AppError("Internal Server Error", 500, "Something went wrong", {
        internalDetails: `Failed to insert campaign donation of the campaign with id ${donation.campaignId}`,
      });
    }

    return result.rows[0];
  } catch (error) {
    if (!(error instanceof pg.DatabaseError)) {
      throw error;
    }

    switch (error.code) {
      case "23503":
        if (error.constraint === "CampaignDonation_campaignId_fkey") {
          throw new AppError(
            "Internal Server Error",
            500,
            "Something went wrong",
            {
              internalDetails: `The campaign ID specified for the campaign donation does not exist.`,
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
