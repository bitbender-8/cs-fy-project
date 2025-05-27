import { z } from "zod";

import {
  validBoolean,
  validCampaignStatus,
  validDate,
  validUuid,
} from "../../utils/zod-helpers.js";

export type CampaignFilterParams = z.infer<typeof CampaignFilterSchema>;
export const CampaignFilterSchema = z
  .object({
    title: z.string(),
    status: validCampaignStatus(),
    category: z.string(),
    minLaunchDate: validDate(true),
    maxLaunchDate: validDate(true),
    minEndDate: validDate(false),
    maxEndDate: validDate(false),
    ownerRecipientId: validUuid(),
    page: z.coerce.number().int().positive(),
    limit: z.coerce.number().int().positive(),

    // Sensitive filters
    minSubmissionDate: validDate(true),
    maxSubmissionDate: validDate(true),
    minVerificationDate: validDate(true),
    maxVerificationDate: validDate(true),
    minDenialDate: validDate(true),
    maxDenialDate: validDate(true),
    isPublic: validBoolean(),
  })
  .partial();

export const SENSITIVE_CAMPAIGN_FILTERS = [
  "minSubmissionDate",
  "maxSubmissionDate",
  "minVerificationDate",
  "maxVerificationDate",
  "minDenialDate",
  "maxDenialDate",
  "isPublic",
] as const;
export type SensitiveCampaignFilters =
  (typeof SENSITIVE_CAMPAIGN_FILTERS)[number];
