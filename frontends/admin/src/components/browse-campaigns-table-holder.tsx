"use client";

import { useState } from "react";
import {
  campaignTableColumns,
  CampaignTableType,
} from "./campaigns-table/columns";
import { DataTable } from "./data-table";

type BroswseCampaignsTableHolderProps = {
  campaigns: CampaignTableType[];
};

export default function BroswseCampaignsTableHolder({
  campaigns,
}: BroswseCampaignsTableHolderProps) {
  const [tableStatus, setTableStatus] = useState<
    "all" | "Pending_Review" | "Verified" | "Live"
  >("all");
  let campaignsToShow = campaigns;

  let pendingReviewCampaignsCount = 0;
  const pendingReviewCampaigns: CampaignTableType[] = [];

  let pendingLaunchCampaignsCount = 0;
  const pendingLaunchCampaigns: CampaignTableType[] = [];

  let liveCampaignsCount = 0;
  const liveCampaigns: CampaignTableType[] = [];

  campaigns.forEach((campaign) => {
    if (campaign.status === "Pending_Review") {
      pendingReviewCampaignsCount++;
      pendingReviewCampaigns.push(campaign);
    }
    if (campaign.status === "Verified") {
      pendingLaunchCampaignsCount++;
      pendingLaunchCampaigns.push(campaign);
    }
    if (campaign.status === "Live") {
      liveCampaignsCount++;
      liveCampaigns.push(campaign);
    }
  });

  if (tableStatus === "Pending_Review") {
    campaignsToShow = pendingReviewCampaigns;
  } else if (tableStatus === "Verified") {
    campaignsToShow = pendingLaunchCampaigns;
  } else if (tableStatus === "Live") {
    campaignsToShow = liveCampaigns;
  } else if (tableStatus === "all") {
    campaignsToShow = campaigns;
  }

  return (
    <>
      <div className="flex justify-between mt-5 space-x-11">
        <div className="relative inline-block group cursor-pointer shadow-lg">
          <div className="px-38 py-6 bg-red-500 rounded-sm opacity-20 blur-[2px] group-hover:opacity-60 group-hover:blur-none"></div>
          <span
            className={`absolute inset-0 flex items-center justify-center text-2xl text-red-500 hover:text-white font-bold ${
              tableStatus === "Pending_Review"
                ? "border-b-4 border-b-gray-400"
                : "border-none"
            }`}
            onClick={() => setTableStatus("Pending_Review")}
          >
            To Review ({pendingReviewCampaignsCount})
          </span>
        </div>

        <div className="relative inline-block group cursor-pointer shadow-lg">
          <div className="px-38 py-6 bg-[#CF754B] rounded-sm opacity-20 blur-[2px] group-hover:opacity-60 group-hover:blur-none"></div>
          <span
            className={`absolute inset-0 flex items-center justify-center text-2xl text-[#CF754B] hover:text-white font-bold ${
              tableStatus === "Verified"
                ? "border-b-4 border-b-gray-400"
                : "border-none"
            }`}
            onClick={() => setTableStatus("Verified")}
          >
            To Launch ({pendingLaunchCampaignsCount})
          </span>
        </div>

        <div className="relative inline-block group cursor-pointer shadow-lg">
          <div className="px-38 py-6 bg-primary rounded-sm opacity-20 blur-[2px] group-hover:opacity-60 group-hover:blur-none"></div>
          <span
            className={`absolute inset-0 flex items-center justify-center text-2xl text-primary hover:text-white font-bold ${
              tableStatus === "Live"
                ? "border-b-4 border-b-gray-400"
                : "border-none"
            }`}
            onClick={() => setTableStatus("Live")}
          >
            Live ({liveCampaignsCount})
          </span>
        </div>
      </div>

      <div>
        <DataTable columns={campaignTableColumns} data={campaignsToShow} />
      </div>
    </>
  );
}
