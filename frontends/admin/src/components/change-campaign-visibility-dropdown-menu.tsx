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
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogFooter,
} from "@/components/ui/dialog";
import { useRouter } from "next/navigation";
import { useState } from "react";

type ChangeCampaignVisibilityDropdownMenuProps = {
  status: string;
  campaignId: string;
  title: string;
};

export default function ChangeCampaignVisibilityDropdownMenu({
  status,
  campaignId,
  title,
}: ChangeCampaignVisibilityDropdownMenuProps) {
  const [position, setPosition] = useState(status);
  const [pendingStatus, setPendingStatus] = useState<string | null>(null);
    // Add a state flag to control the dropdown’s visibility:
  const [dropdownOpen, setDropdownOpen] = useState(false);
  const [dialogOpen, setDialogOpen] = useState(false);
  const router = useRouter();

  const handleChange = (newStatus: string) => {
    setPendingStatus(newStatus);
    setDropdownOpen(false);
    setDialogOpen(true);
  };

  const handleConfirm = async () => {
    if (!pendingStatus) return;
    setPosition(pendingStatus);
    setDialogOpen(false);

    try {
      const res = await fetch(`/api/campaigns/${campaignId}/status`, {
        method: "PATCH",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ status: pendingStatus }),
      });
      if (!res.ok) throw new Error(await res.text());
      router.refresh();
    } catch (err) {
      console.error("Failed to update status:", err);
    }
  };

  const handleCancel = () => {
    setDialogOpen(false);
    setPendingStatus(null);
  };

  return (
    <>
      <DropdownMenu open={dropdownOpen} onOpenChange={setDropdownOpen}>
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

      <Dialog open={dialogOpen} onOpenChange={setDialogOpen}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>
              Are you sure you want to change the campaign status for:{" "}
              <br />
              <br />
              <p className="font-bold text-xl underline">{title}</p>
            </DialogTitle>
          </DialogHeader>
          <DialogFooter>
            <Button variant="default" onClick={handleConfirm}>
              Yes
            </Button>
            <Button variant="outline" onClick={handleCancel}>
              No
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </>
  );
}
