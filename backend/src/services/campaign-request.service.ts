import { UUID } from "crypto";
import { CampaignRequest } from "../models/campaign-request.model.js";
import { getCampaigns } from "../repositories/campaign.repo.js";

/**
 * Checks if a given recipient is the owner of the campaign associated with a campaign request.
 * @param {CampaignRequest} campaignRequest - The campaign request object.
 * @param {UUID} recipientId - The UUID of the recipient to check.
 * @returns {Promise<boolean>} True if the recipient owns the campaign, false otherwise.
 */
export async function isCampaignRequestOwner(
  campaignRequest: CampaignRequest,
  recipientId: UUID,
): Promise<boolean> {
  const campaign = await getCampaigns({ id: campaignRequest.campaignId });
  if (recipientId === campaign.items[0].ownerRecipientId) {
    return true;
  }
  return false;
}
