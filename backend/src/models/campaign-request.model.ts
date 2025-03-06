import { UUID } from "crypto";
import { CampaignPost, CampaignStatus } from "./campaign.model.js";

export interface CampaignRequest {
  id: UUID;
  title: string;
  requestDate: Date;
  justification: string;
  isResolved: boolean;
  campaignId: UUID;
}

export interface GoalAdjustmentRequest extends CampaignRequest {
  newGoal: string;
}

export interface StatusChangeRequest extends CampaignRequest {
  newStatus: CampaignStatus;
}

export interface PostUpdateRequest extends CampaignRequest {
  newPost: CampaignPost;
}

export interface EndDateExtensionRequest extends CampaignRequest {
  newEndDate: Date;
}
