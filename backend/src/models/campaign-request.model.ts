import { z } from "zod";

import { CampaignPostSchema } from "./campaign.model.js";
import {
  REQUEST_RESOLUTION_TYPES,
  CAMPAIGN_REQUEST_TYPES,
  MIN_STRING_LENGTH,
  validCampaignStatus,
  validDate,
  validMoneyAmount,
  validNonEmptyString,
  validUuid,
  validCampaignResolution,
} from "../utils/zod-helpers.js";

// TODO(bitbender-8): Update the class diagram, add the requestType property as an enum, and the ownerRecipientId as a UUID. No change needed for the er diagram and relational schema.
export type CampaignRequestType = (typeof CAMPAIGN_REQUEST_TYPES)[number];
export type ResolutionType = (typeof REQUEST_RESOLUTION_TYPES)[number];

const CampaignRequestSchema = z.object({
  id: validUuid(),
  campaignId: validUuid(),
  ownerRecipientId: validUuid().optional(),
  title: validNonEmptyString(MIN_STRING_LENGTH, 100),
  requestDate: validDate(true),
  justification: validNonEmptyString(MIN_STRING_LENGTH, 500),
  resolutionDate: validDate(true).optional(),
  resolutionType: validCampaignResolution(),
});

export type GoalAdjustmentRequest = z.infer<typeof GoalAdjustmentRequestSchema>;
export const GoalAdjustmentRequestSchema = CampaignRequestSchema.extend({
  requestType: z.literal("Goal Adjustment"),
  newGoal: validMoneyAmount(),
});

export type StatusChangeRequest = z.infer<typeof StatusChangeRequestSchema>;
export const StatusChangeRequestSchema = CampaignRequestSchema.extend({
  requestType: z.literal("Status Change"),
  newStatus: validCampaignStatus(),
});

export type PostUpdateRequest = z.infer<typeof PostUpdateRequestSchema>;
export const PostUpdateRequestSchema = CampaignRequestSchema.extend({
  requestType: z.literal("Post Update"),
  newPost: CampaignPostSchema,
});

export type EndDateExtensionRequest = z.infer<
  typeof EndDateExtensionRequestSchema
>;
export const EndDateExtensionRequestSchema = CampaignRequestSchema.extend({
  requestType: z.literal("End Date Extension"),
  newEndDate: validDate(false),
});

export type CampaignRequest = z.infer<typeof CampaignRequestUnionSchema>;
export const CampaignRequestUnionSchema = z.discriminatedUnion("requestType", [
  GoalAdjustmentRequestSchema,
  StatusChangeRequestSchema,
  PostUpdateRequestSchema,
  EndDateExtensionRequestSchema,
]);

export const LOCKED_CAMPAIGN_REQUEST_FIELDS = [
  "id",
  "resolutionDate",
  "requestDate",
  "resolutionType",
  "campaignId",
] as const;
export type LockedCampaignRequestFields =
  (typeof LOCKED_CAMPAIGN_REQUEST_FIELDS)[number];
