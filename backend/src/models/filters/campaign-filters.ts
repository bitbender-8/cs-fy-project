import { z } from "zod";

import {
  MIN_STRING_LENGTH,
  validBoolean,
  validCampaignStatus,
  validDate,
  validNonEmptyString,
  validUuid,
} from "../../utils/zod-helpers.js";

export type CampaignFilterParams = z.infer<typeof CampaignFilterSchema>;
export const CampaignFilterSchema = z
  .object({
    title: validNonEmptyString(MIN_STRING_LENGTH, 100),
    status: validCampaignStatus(),
    category: validNonEmptyString(MIN_STRING_LENGTH, 50),
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
