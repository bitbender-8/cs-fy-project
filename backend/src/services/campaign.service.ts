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
import { fromIntToMoneyStr } from "../utils/utils.js";
import { getCampaignPosts } from "../repositories/campaign-request.repo.js";
import {
  getCampaignDonationTotal,
  getCampaigns,
  markCampaignDonationsAsTransferred,
} from "../repositories/campaign.repo.js";
import { initiateChapaTransfer } from "./chapa.service.js";

/**
 * @typedef {object} CombinedRequestType
 * @description A type that combines all possible campaign request fields.
 * Used as an intermediate type before transforming into a specific CampaignRequest model.
 * @property {UUID} [newPostId] - The ID of a new post, if the request type is "Post Update".
 * @property {CampaignRequestType} requestType - The specific type of the campaign request.
 */
export type CombinedRequestType = {
  newPostId?: UUID;
  requestType: CampaignRequestType;
} & Omit<PostUpdateRequest, "requestType"> &
  Omit<StatusChangeRequest, "requestType"> &
  Omit<EndDateExtensionRequest, "requestType"> &
  Omit<GoalAdjustmentRequest, "requestType">;
/**
 * Transforms a generic combined request object into a specific campaign request type.
 *
 * @param {CombinedRequestType} val - The combined request object to transform.
 * @returns {Promise<CampaignRequest>} The transformed, specific campaign request object.
 * @throws {AppError} If an invalid campaign request type is encountered.
 */
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

/**
 * Validates if a transition from an old campaign status to a new campaign status is allowed.
 *
 * @param {CampaignStatus} oldStatus - The current status of the campaign.
 * @param {CampaignStatus} newStatus - The desired new status for the campaign.
 * @returns {{ isValid: boolean; message?: string }} An object indicating if the transition is valid, and an optional message if it's not.
 */
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

/**
 * Transfers the total net donations for a completed campaign to the recipient's bank account via Chapa.
 * It also marks the campaign's donations as transferred in the database.
 *
 * @param {UUID} campaignId - The UUID of the campaign for which to transfer donations.
 * @returns {Promise<string | undefined>} The transaction reference (txnRef) from Chapa upon successful transfer initiation, or undefined if there are no donations to transfer.
 * @throws {AppError} If the campaign is not found, if there's an error during transfer initiation with Chapa,
 * or if updating the donation transfer status in the database fails.
 */
export async function transferCampaignDonations(
  campaignId: UUID
): Promise<string | undefined> {
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

  const netDonation = await getCampaignDonationTotal(campaignId, true);
  if (netDonation == "0") return undefined;

  // Initiate the transfer
  const transferRef = randomUUID();

  // Attempt transfer initiation once, let errors propagate
  const transferInitResponse = await initiateChapaTransfer({
    destinationAccountNo: campaign.paymentInfo.bankAccountNo,
    chapaBankCode: campaign.paymentInfo.chapaBankCode,
    amount: netDonation,
    reference: transferRef,
  });

  if (transferInitResponse.status !== "success") {
    throw new AppError("Internal Server Error", 500, "Something went wrong", {
      internalDetails: `Error during transfer initiation. Message: ${transferInitResponse.message}`,
    });
  }

  if (!transferInitResponse.data) {
    throw new AppError("Internal Server Error", 500, "Something went wrong", {
      internalDetails:
        "Transfer initiation reported success but response object was unexpectedly undefined.",
    });
  }

  const txnRef = transferInitResponse.data as string;

  // Attempt transfer verification once, let errors propagate
  // FIXME: COMMENTED OUT CAUSE I COULDN'T GET TRANSFER VERIFICATION TO WORK. (Even if I did everything in the docs.)
  // const transferVerifyResponse = await verifyChapaTransfer(txnRef);

  // if (transferVerifyResponse.status !== "success") {
  //   throw new AppError("Internal Server Error", 500, "Something went wrong.", {
  //     internalDetails: `${transferVerifyResponse.message ?? "Unknown error during transfer verification."}. Transfer with txnRef '${txnRef}' failed verification.`,
  //   });
  // }

  // Update donation object
  if (!(await markCampaignDonationsAsTransferred(campaignId))) {
    throw new AppError(
      "Internal Server Error",
      500,
      "Failed to update donation transfer status",
      {
        internalDetails: `Donations for campaign with id '${campaignId}' were successfully transferred (txnRef: '${txnRef}'), but the database update to mark them as transferred failed.`,
      }
    );
  }

  return txnRef;
}
