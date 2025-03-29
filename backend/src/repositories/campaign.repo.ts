import { config } from "../config.js";
import { Campaign } from "../models/campaign.model.js";
import { PaginatedList } from "../utils/utils.js";
import { query } from "../db.js";
import { CampaignFilterParams } from "../models/filters/campaign-filters.js";
import { UUID } from "crypto";

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

  const campaigns: Campaign[] = (await query(queryString, values)).rows.map(
    (campaign) => {
      const { paymentMethod, phoneNo, bankAccountNo, bankName, ...rest } =
        campaign;

      return {
        ...rest,
        paymentInfo: {
          paymentMethod,
          phoneNo,
          bankAccountNo,
          bankName,
        },
      };
    }
  );

  return {
    items: campaigns ?? [],
    pageCount: totalPages === 0 ? 1 : totalPages,
    pageNo: pageNo,
  };
}
