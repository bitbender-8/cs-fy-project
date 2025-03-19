import { config } from "../config.js";
import { Campaign } from "../models/campaign.model.js";
import { PaginatedList } from "../utils/util.types.js";
import { query } from "./db.js";
import { CampaignFilterParams } from "../models/filters/campaign-filters.js";

/** Validate filter params before passing */
export async function readCampaigns(
  filterParams: CampaignFilterParams
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
            "ownerRecipientId"
        FROM
            "Campaign"
    `;

  const limit = filterParams.limit ?? config.PAGE_SIZE;
  const pageNo = filterParams.page || 1;
  const whereClauses: string[] = [];
  const values: unknown[] = [];
  let paramIndex = 1;

  if (filterParams.isPublic) {
    whereClauses.push(`"launchDate" IS NOT NULL`);
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

  const dateFilters = {
    launchDate: {
      minParam: "minLaunchDate",
      maxParam: "maxLaunchDate",
    },
    submissionDate: {
      minParam: "minSubmissionDate",
      maxParam: "maxSubmissionDate",
    },
    verificationDate: {
      minParam: "minVerificationDate",
      maxParam: "maxVerificationDate",
    },
    denialDate: {
      minParam: "minDenialDate",
      maxParam: "maxDenialDate",
    },
    endDate: {
      minParam: "minEndDate",
      maxParam: "maxEndDate",
    },
  } as const;

  for (const dateField in dateFilters) {
    const filter = dateFilters[dateField as keyof typeof dateFilters];

    if (filterParams[filter.minParam]) {
      whereClauses.push(`"${dateField}" >= $${paramIndex}`);
      values.push(filterParams[filter.minParam]);
      paramIndex++;
    }
    if (filterParams[filter.maxParam]) {
      whereClauses.push(`"${dateField}" <= $${paramIndex}`);
      values.push(filterParams[filter.maxParam]);
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
            "submissionDate" DESC
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
    pageCount: totalPages ?? 0,
    pageNo: pageNo ?? 1,
  };
}
