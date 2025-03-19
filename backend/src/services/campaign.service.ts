import { Campaign, SensitiveCampaignFields } from "../models/campaign.model.js";
import { PaginatedList } from "../utils/util.types.js";

export function excludeSensitiveCampaignProperties(
  campaigns: PaginatedList<Campaign>,
): PaginatedList<Omit<Campaign, SensitiveCampaignFields>> {
  return {
    items: campaigns.items.map((campaign) => {
      const {
        submissionDate,
        verificationDate,
        denialDate,
        documentUrls,
        paymentInfo,
        ...publicCampaign
      } = campaign;

      void submissionDate;
      void verificationDate;
      void denialDate;
      void documentUrls;
      void paymentInfo;

      return publicCampaign;
    }),
    pageCount: campaigns.pageCount,
    pageNo: campaigns.pageNo,
  };
}
