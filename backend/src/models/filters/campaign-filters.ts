import { z } from "zod";

import {
  validBoolean,
  validCampaignStatus,
  validDate,
  validUrl,
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
    minEndDate: validDate(),
    maxEndDate: validDate(),
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

export type CampaignDocumentFilterParams = z.infer<
  typeof CampaignDocumentFilterSchema
>;
export const CampaignDocumentFilterSchema = z
  .object({
    campaignId: validUuid(),
    documentUrl: validUrl(),
    redactedDocumentUrl: validUrl(),
    page: z.coerce.number().int().positive(),
    limit: z.coerce.number().int().positive(),
  })
  .partial();
