import { PaginatedList } from "../utils/util.types.js";
import { Campaign, SensitiveCampaignFields } from "../models/campaign.model.js";

export function excludeSensitiveCampaignProperties(
  campaigns: PaginatedList<Campaign>
): PaginatedList<Omit<Campaign, SensitiveCampaignFields>> {
  return {
    items: campaigns.items.map((campaign) => {
      const {
        id,
        ownerRecipientId,
        title,
        description,
        fundraisingGoal,
        status,
        category,
        launchDate,
        endDate,
        redactedDocumentUrls,
      } = campaign;

      return {
        id,
        ownerRecipientId,
        title,
        description,
        fundraisingGoal,
        status,
        category,
        launchDate,
        endDate,
        redactedDocumentUrls,
      };
    }),
    pageCount: campaigns.pageCount,
    pageNo: campaigns.pageNo,
  };
}
