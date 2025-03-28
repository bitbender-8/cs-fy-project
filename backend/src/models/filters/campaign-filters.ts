import { z } from "zod";

import {
  MIN_STRING_LENGTH,
  validCampaignStatus,
  validDate,
  validNonEmptyString,
  validUuid,
} from "../../utils/zod-helpers.js";

export type CampaignFilterParams = z.infer<typeof CampaignFilterSchema>;
export const CampaignFilterSchema = z.object({
  title: validNonEmptyString(MIN_STRING_LENGTH, 100).optional(),
  status: validCampaignStatus().optional(),
  category: validNonEmptyString(MIN_STRING_LENGTH, 50).optional(),
  minLaunchDate: validDate(true).optional(),
  maxLaunchDate: validDate(true).optional(),
  minEndDate: validDate(false).optional(),
  maxEndDate: validDate(false).optional(),
  ownerRecipientId: validUuid().optional(),
  page: z.coerce.number().int().positive().optional(),
  limit: z.coerce.number().int().positive().optional(),

  // Sensitive filters
  minSubmissionDate: validDate(true).optional(),
  maxSubmissionDate: validDate(true).optional(),
  minVerificationDate: validDate(true).optional(),
  maxVerificationDate: validDate(true).optional(),
  minDenialDate: validDate(true).optional(),
  maxDenialDate: validDate(true).optional(),
  isPublic: z.coerce.boolean().optional(),
});

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
