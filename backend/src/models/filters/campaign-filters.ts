import { z } from "zod";

import {
  MIN_STRING_LENGTH,
  validCampaignStatus,
  validNonEmptyString,
  validUuid,
} from "../../utils/zod-helpers.js";

export const CampaignFilterSchema = z.object({
  /** Campaign title to search for */
  title: validNonEmptyString(MIN_STRING_LENGTH, 100).optional(),
  /** Campaign status (must be one of the predefined values) */
  status: validCampaignStatus().optional(),
  /** Campaign category */
  category: validNonEmptyString(MIN_STRING_LENGTH, 50).optional(),
  /** Minimum launch date (inclusive) */
  minLaunchDate: z.coerce.date().optional(),
  /** Maximum launch date (inclusive) */
  maxLaunchDate: z.coerce.date().optional(),
  /** Minimum submission date (available for Supervisors and Recipients) */
  minSubmissionDate: z.coerce.date().optional(),
  /** Maximum submission date (available for Supervisors and Recipients) */
  maxSubmissionDate: z.coerce.date().optional(),
  /** Minimum verification date (available for Supervisors and Recipients) */
  minVerificationDate: z.coerce.date().optional(),
  /** Maximum verification date (available for Supervisors and Recipients) */
  maxVerificationDate: z.coerce.date().optional(),
  /** Minimum denial date (available for Supervisors and Recipients) */
  minDenialDate: z.coerce.date().optional(),
  /** Maximum denial date (available for Supervisors and Recipients) */
  maxDenialDate: z.coerce.date().optional(),
  /** Minimum campaign end date (inclusive) */
  minEndDate: z.coerce.date().optional(),
  /** Maximum campaign end date (inclusive) */
  maxEndDate: z.coerce.date().optional(),
  /** Public campaigns */
  isPublic: z.coerce.boolean().optional(),
  /** The ID of the recipient which owns the campaign */
  ownerRecipientId: validUuid().optional(),
  /** Page number for pagination (must be a positive integer) */
  page: z.coerce.number().int().positive().optional(),
  /** Maximum number of items per page (must be a positive integer) */
  limit: z.coerce.number().int().positive().optional(),
});

export type CampaignFilterParams = z.infer<typeof CampaignFilterSchema>;
export type SensitiveCampaignFilters =
  | "minSubmissionDate"
  | "maxSubmissionDate"
  | "minVerificationDate"
  | "maxVerificationDate"
  | "minDenialDate"
  | "maxDenialDate";
