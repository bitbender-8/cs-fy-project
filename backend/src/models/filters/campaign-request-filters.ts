import { z } from "zod";
import {
  MIN_STRING_LENGTH,
  validBoolean,
  validCampaignRequestDecision,
  validCampaignRequestType,
  validDate,
  validNonEmptyString,
  validUuid,
} from "../../utils/zod-helpers.js";

export type CampaignRequestFilter = z.infer<typeof campaignRequestFilterSchema>;
export const campaignRequestFilterSchema = z
  .object({
    ownerRecipientId: validUuid(),
    campaignId: validUuid(),
    requestType: validCampaignRequestType(),
    isResolved: validBoolean(),
    resolutionType: validCampaignRequestDecision(),
    minRequestDate: validDate(true),
    maxRequestDate: validDate(true),
    minResolutionDate: validDate(true),
    maxResolutionDate: validDate(true),
    title: validNonEmptyString(MIN_STRING_LENGTH, 100),
    page: z.coerce.number().int().positive(),
    limit: z.coerce.number().int().positive(),
  })
  .partial();
