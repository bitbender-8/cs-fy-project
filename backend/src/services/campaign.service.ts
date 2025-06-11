import { randomUUID, UUID } from "crypto";
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
import { delay, fromIntToMoneyStr } from "../utils/utils.js";
import { getCampaignPosts } from "../repositories/campaign-request.repo.js";
import {
  getCampaignDonationTotal,
  getCampaigns,
} from "../repositories/campaign.repo.js";
import {
  ChapaResponse,
  initiateChapaTransfer,
  verifyChapaTransfer,
} from "./chapa.service.js";
import { config } from "../config.js";

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

// Returns the txnRef on success
export async function transferCampaignDonations(
  campaignId: UUID
): Promise<string> {
  const campaign = (await getCampaigns({ id: campaignId })).items[0];
  if (!campaign) {
    throw new AppError(
      "Not Found",
      404,
      `Campaign with id '${campaignId}' was not found`,
      {
        internalDetails: `Cannot find campaign with id '${campaignId}' while attempting to transfer campaign donations`,
      }
    );
  }

  const netDonation = await getCampaignDonationTotal(campaignId);

  // Initiate the transfer
  const transferRef = randomUUID();

  let isTransferInitiated = false;
  let errMessage: string | null = null;
  let transferInitResponse: ChapaResponse | null = null;

  for (let i = 0; i < config.MAX_RETRIES; i++) {
    try {
      transferInitResponse = await initiateChapaTransfer({
        destinationAccountNo: campaign.paymentInfo.bankAccountNo,
        chapaBankCode: campaign.paymentInfo.chapaBankCode,
        amount: netDonation,
        reference: transferRef,
      });

      if (transferInitResponse.status === "success") {
        isTransferInitiated = true;
        break;
      } else {
        errMessage = transferInitResponse.message;
        console.warn(
          `Transfer initiation attempt ${i + 1} failed: ${errMessage}`
        );
        await delay(config.RETRY_DELAY_MS);
      }
    } catch (error) {
      errMessage = error instanceof Error ? error.message : String(error);
      console.error(
        `Transfer initiation attempt ${i + 1} error: ${errMessage}`
      );
      await delay(config.RETRY_DELAY_MS);
    }
  }

  if (!isTransferInitiated) {
    throw new AppError(
      "Payment Failure",
      500,
      errMessage ?? "Unknown error during transfer initiation",
      {
        internalDetails: "No transaction reference received from Chapa",
      }
    );
  }

  // Verify the transfer
  if (transferInitResponse === null) {
    throw new AppError(
      "Internal Server Error",
      500,
      "Transfer initiation reported success but response object was unexpectedly undefined."
    );
  }
  const txnRef = transferInitResponse.data as string;

  let isTransferVerified = false;
  let transferVerifyResponse: ChapaResponse;

  for (let i = 0; !isTransferVerified && i < config.MAX_RETRIES; i++) {
    try {
      transferVerifyResponse = await verifyChapaTransfer(txnRef);

      if (transferVerifyResponse.status === "success") {
        isTransferVerified = true;
        break;
      } else {
        errMessage = transferVerifyResponse.message;
        console.warn(
          `Transfer verification attempt ${i + 1} failed: ${errMessage}`
        );
        await delay(config.RETRY_DELAY_MS);
      }
    } catch (error) {
      errMessage = error instanceof Error ? error.message : String(error);
      console.error(
        `Transfer verification attempt ${i + 1} error: ${errMessage}`
      );
      await delay(config.RETRY_DELAY_MS);
    }
  }

  if (!isTransferVerified) {
    // It's possible the transfer was initiated but verification consistently failed. This transaction (identified by `txnRef`) is in an uncertain state.It requires human intervention or an automated reconciliation process.
    throw new AppError(
      "Payment Failure",
      500,
      errMessage ?? "Unknown error during transfer verification.",
      {
        internalDetails: `Transfer with txnRef '${txnRef}' initiated but failed verification after multiple attempts. Manual review required.`,
      }
    );
  }

  return txnRef;
}
