"use client";

import { useState } from "react";
import {
  campaignTableColumns,
  CampaignTableType,
} from "./table-columns/campaign-table-columns";
import { DataTableCampaignList } from "./data-tables/data-table-campaign-list";
import { Button } from "@/components/ui/button";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";

type BroswseCampaignsTableHolderProps = {
  campaigns: CampaignTableType[];
};

const STATUS_OPTIONS = [
  { value: "all", label: "All Campaigns" },
  { value: "Pending_Review", label: "Pending Review" },
  { value: "Verified", label: "Verified" },
  { value: "Live", label: "Live" },
  { value: "Completed", label: "Completed" },
  { value: "Denied", label: "Denied" },
  { value: "Paused", label: "Paused" },
] as const;

type CampaignStatusFilterType = typeof STATUS_OPTIONS[number]['value'];

export default function BroswseCampaignsTableHolder({
  campaigns,
}: BroswseCampaignsTableHolderProps) {
  const [tableStatus, setTableStatus] = useState<CampaignStatusFilterType>("all");

  const campaignsToShow =
    tableStatus === "all"
      ? campaigns
      : campaigns.filter((campaign) => campaign.status === tableStatus);

  const currentStatusLabel =
    STATUS_OPTIONS.find((option) => option.value === tableStatus)?.label ||
    "Select Status";

  return (
    <>
      <div className="flex items-center mt-5 mb-6 space-x-2">
        <span className="text-sm font-medium text-muted-foreground">
          Filter by status:
        </span>
        <DropdownMenu modal={false}>
          <DropdownMenuTrigger asChild>
            <Button variant="outline" className="w-[200px] justify-start text-left font-normal bg-slate-400">
              {currentStatusLabel}
            </Button>
          </DropdownMenuTrigger>
          <DropdownMenuContent className="w-[200px]" align="start">
            {STATUS_OPTIONS.map((statusOption) => (
              <DropdownMenuItem
                key={statusOption.value}
                onSelect={() => setTableStatus(statusOption.value)}
              >
                {statusOption.label}
              </DropdownMenuItem>
            ))}
          </DropdownMenuContent>
        </DropdownMenu>
      </div>

      <div>
        <DataTableCampaignList columns={campaignTableColumns} data={campaignsToShow} />
      </div>
    </>
  );
}