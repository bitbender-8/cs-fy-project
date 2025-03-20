import { UUID } from "crypto";
import { z } from "zod";

import {
  CampaignPost,
  CampaignPostSchema,
  CampaignStatus,
} from "./campaign.model.js";
import {
  MIN_STRING_LENGTH,
  validCampaignStatus,
  validDate,
  validMoneyAmount,
  validNonEmptyString,
  validUuid,
} from "../utils/zod-helpers.js";

interface CampaignRequest {
  id?: UUID;
  title: string;
  requestDate: Date | string;
  justification: string;
  resolutionDate?: Date | string;
  campaignId: UUID;
}

export interface GoalAdjustmentRequest extends CampaignRequest {
  newGoal: string | bigint;
}

export interface StatusChangeRequest extends CampaignRequest {
  newStatus: CampaignStatus;
}

export interface PostUpdateRequest extends CampaignRequest {
  newPost: CampaignPost;
}

export interface EndDateExtensionRequest extends CampaignRequest {
  newEndDate: Date | string;
}

// ================= Zod schemas ====================

const CampaignRequestSchema = z.object({
  id: validUuid().optional(),
  title: validNonEmptyString(MIN_STRING_LENGTH, 100),
  requestDate: validDate(true),
  justification: validNonEmptyString(MIN_STRING_LENGTH, 500),
  resolutionDate: validDate(true),
  campaignId: validUuid(),
});

export const GoalAdjustmentRequestSchema = CampaignRequestSchema.extend({
  newGoal: validMoneyAmount(),
});

export const StatusChangeRequestSchema = CampaignRequestSchema.extend({
  newStatus: validCampaignStatus(),
});

export const PostUpdateRequestSchema = CampaignRequestSchema.extend({
  newPost: CampaignPostSchema,
});

export const EndDateExtensionRequestSchema = CampaignRequestSchema.extend({
  newEndDate: validDate(false),
});
