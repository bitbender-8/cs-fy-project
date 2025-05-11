"use client";

import { Button } from "@/components/ui/button";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuLabel,
  DropdownMenuRadioGroup,
  DropdownMenuRadioItem,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import { useRouter } from "next/navigation";
import { useState } from "react";

type ChangeCampaignVisibilityDropdownMenuProps = {
  status: string;
  campaignId: string;
};

export default function ChangeCampaignVisibilityDropdownMenu({
  status,
  campaignId,
}: ChangeCampaignVisibilityDropdownMenuProps) {
  const [position, setPosition] = useState(status);
  const router = useRouter();

  const handleChange = async (newStatus: string) => {
    setPosition(newStatus);

    try {
      const res = await fetch(`/api/campaigns/${campaignId}/status`, {
        method: "PATCH",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ status: newStatus }),
      });
      if (!res.ok) throw new Error(await res.text());

      // refresh the page data so any siblings re-render with the new status
      router.refresh();
    } catch (err) {
      console.error("Failed to update status:", err);
    }
  };

  return (
    <DropdownMenu>
      <DropdownMenuTrigger asChild>
        <Button variant="default">{position.toUpperCase()}</Button>
      </DropdownMenuTrigger>
      <DropdownMenuContent className="w-56">
        <DropdownMenuLabel>Campaign Visibility Status</DropdownMenuLabel>
        <DropdownMenuSeparator />
        <DropdownMenuRadioGroup value={position} onValueChange={handleChange}>
          <DropdownMenuRadioItem value="Pending_Review">
            Pending Review
          </DropdownMenuRadioItem>
          <DropdownMenuRadioItem value="Live">Live</DropdownMenuRadioItem>
          <DropdownMenuRadioItem value="Paused">Paused</DropdownMenuRadioItem>
          <DropdownMenuRadioItem value="Verified">
            Verified
          </DropdownMenuRadioItem>
          <DropdownMenuRadioItem value="Denied">Denied</DropdownMenuRadioItem>
          <DropdownMenuRadioItem value="Completed">
            Completed
          </DropdownMenuRadioItem>
        </DropdownMenuRadioGroup>
      </DropdownMenuContent>
    </DropdownMenu>
  );
}
