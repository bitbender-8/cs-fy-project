import { z } from "zod";

import {
  MIN_STRING_LENGTH,
  validCampaignStatus,
  validNonEmptyString,
  validUuid,
} from "../../utils/zod-helpers.js";

export const CampaignFilterSchema = z.object({
  title: validNonEmptyString(MIN_STRING_LENGTH, 100).optional(),
  status: validCampaignStatus().optional(),
  category: validNonEmptyString(MIN_STRING_LENGTH, 50).optional(),
  minLaunchDate: z.coerce.date().optional(),
  maxLaunchDate: z.coerce.date().optional(),
  minEndDate: z.coerce.date().optional(),
  maxEndDate: z.coerce.date().optional(),
  ownerRecipientId: validUuid().optional(),
  page: z.coerce.number().int().positive().optional(),
  limit: z.coerce.number().int().positive().optional(),

  // Non-public query params
  minSubmissionDate: z.coerce.date().optional(),
  maxSubmissionDate: z.coerce.date().optional(),
  minVerificationDate: z.coerce.date().optional(),
  maxVerificationDate: z.coerce.date().optional(),
  minDenialDate: z.coerce.date().optional(),
  maxDenialDate: z.coerce.date().optional(),
  isPublic: z.coerce.boolean().optional(),
});

export type CampaignFilterParams = z.infer<typeof CampaignFilterSchema>;
export type SensitiveCampaignFilters =
  | "minSubmissionDate"
  | "maxSubmissionDate"
  | "minVerificationDate"
  | "maxVerificationDate"
  | "minDenialDate"
  | "maxDenialDate";
