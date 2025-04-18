import { z } from "zod";
import {
  MIN_STRING_LENGTH,
  validBoolean,
  validDate,
  validNonEmptyString,
  validUuid,
} from "../../utils/zod-helpers.js";

export type CampaignPostFilter = z.infer<typeof CampaignPostFilterSchema>;
export const CampaignPostFilterSchema = z
  .object({
    title: validNonEmptyString(MIN_STRING_LENGTH, 100),
    campaignId: validUuid(),
    isPublic: validBoolean(),
    minPublicPostDate: validDate(true),
    maxPublicPostDate: validDate(true),
    page: z.coerce.number().int().positive(),
    limit: z.coerce.number().int().positive(),
  })
  .partial();

export const SENSITIVE_CAMPAIGN_POST_FILTERS = ["isPublic"] as const;
export type SensitiveCampaignPostFilters =
  (typeof SENSITIVE_CAMPAIGN_POST_FILTERS)[number];
