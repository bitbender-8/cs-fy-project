import { UUID } from "crypto";
import { AppError } from "../errors/error.types.js";
import {
  CampaignRequest,
  CampaignRequestType,
  EndDateExtensionRequest,
  GoalAdjustmentRequest,
  PostUpdateRequest,
  StatusChangeRequest,
} from "../models/campaign-request.model.js";
import { CampaignStatus } from "../models/campaign.model.js";
import { fromIntToMoneyStr } from "../utils/utils.js";
import { getCampaignPosts } from "../repositories/campaign-request.repo.js";

export function validateStatusTransitions(
  oldStatus: CampaignStatus,
  newStatus: CampaignStatus
): { isValid: boolean; message?: string } {
  if (oldStatus === newStatus) {
    return { isValid: true };
  }

  switch (oldStatus) {
    case "Pending Review":
      if (newStatus !== "Verified" && newStatus !== "Denied") {
        return {
          isValid: false,
          message:
            "A 'Pending Review' campaign can only transition to 'Verified' or 'Denied'",
        };
      }
      break;
    case "Verified":
      if (newStatus !== "Live" && newStatus !== "Denied") {
        return {
          isValid: false,
          message:
            "A 'Verified' campaign can only transition to 'Live' or 'Denied'",
        };
      }
      break;
    case "Denied":
      return {
        isValid: false,
        message: "A 'Denied' campaign cannot transition to any other status",
      };
    case "Live":
      if (newStatus !== "Paused" && newStatus !== "Completed") {
        return {
          isValid: false,
          message:
            "A 'Live' campaign can only transition to 'Paused' or 'Completed'",
        };
      }
      break;
    case "Paused":
      if (newStatus !== "Live" && newStatus !== "Completed") {
        return {
          isValid: false,
          message:
            "A 'Paused' campaign can only transition to 'Live' or 'Completed'",
        };
      }
      break;
    case "Completed":
      return {
        isValid: false,
        message: "A 'Completed' campaign cannot transition to any other status",
      };
    default:
      return {
        isValid: false,
        message: "Invalid old campaign status.",
      };
  }

  return { isValid: true };
}

export type CombinedRequestType = {
  newPostId?: UUID;
  requestType: CampaignRequestType;
} & Omit<PostUpdateRequest, "requestType"> &
  Omit<StatusChangeRequest, "requestType"> &
  Omit<EndDateExtensionRequest, "requestType"> &
  Omit<GoalAdjustmentRequest, "requestType">;

export async function transformCampaignRequest(
  val: CombinedRequestType
): Promise<CampaignRequest> {
  let transformedRequest: CampaignRequest;

  switch (val.requestType) {
    case "Goal Adjustment": {
      const {
        /* eslint-disable @typescript-eslint/no-unused-vars */
        newPostId,
        newPost,
        newEndDate,
        newStatus,
        /* eslint-enable @typescript-eslint/no-unused-vars */
        ...goalAdjustmentRequest
      } = {
        ...val,
        newGoal: fromIntToMoneyStr(BigInt(val.newGoal)) as string,
        requestType: "Goal Adjustment" as const,
      };

      transformedRequest = goalAdjustmentRequest;
      break;
    }
    case "End Date Extension": {
      const {
        /* eslint-disable @typescript-eslint/no-unused-vars */
        newPostId,
        newPost,
        newGoal,
        newStatus,
        /* eslint-enable @typescript-eslint/no-unused-vars */
        ...endDateExtensionRequest
      } = {
        ...val,
        requestType: "End Date Extension" as const,
      };

      transformedRequest = endDateExtensionRequest;
      break;
    }
    case "Post Update": {
      const {
        /* eslint-disable @typescript-eslint/no-unused-vars */
        newPostId,
        newGoal,
        newEndDate,
        newStatus,
        /* eslint-enable @typescript-eslint/no-unused-vars */
        ...goalAdjustmentRequest
      } = {
        ...val,
        requestType: "Post Update" as const,
        newPost: (
          await getCampaignPosts({
            id: val.newPostId,
          })
        ).items[0],
      };

      transformedRequest = goalAdjustmentRequest;
      break;
    }
    case "Status Change": {
      const {
        /* eslint-disable @typescript-eslint/no-unused-vars */
        newPostId,
        newPost,
        newGoal,
        newEndDate,
        /* eslint-enable @typescript-eslint/no-unused-vars */
        ...goalAdjustmentRequest
      } = {
        ...val,
        requestType: "Status Change" as const,
      };

      transformedRequest = goalAdjustmentRequest;
      break;
    }
    default:
      throw new AppError("Internal Server Error", 500, "Something went wrong", {
        internalDetails:
          "Invalid campaign request type encountered while transforming campaign request",
      });
  }

  return transformedRequest;
}
