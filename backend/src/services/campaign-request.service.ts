import { UUID } from "crypto";
import { CampaignRequest } from "../models/campaign-request.model.js";
import { getCampaigns } from "../repositories/campaign.repo.js";

export async function isCampaignRequestOwner(
  campaignRequest: CampaignRequest,
  recipientId: UUID
): Promise<boolean> {
  const campaign = await getCampaigns({ id: campaignRequest.campaignId });
  if (recipientId === campaign.items[0].ownerRecipientId) {
    return true;
  }
  return false;
}
