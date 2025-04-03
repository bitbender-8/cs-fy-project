import { CampaignStatus } from "../models/campaign.model.js";

export function validateStatusTransitions(
  oldStatus: CampaignStatus,
  newStatus: CampaignStatus,
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
