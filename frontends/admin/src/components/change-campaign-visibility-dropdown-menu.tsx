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
import { toast } from "sonner";

type ChangeCampaignVisibilityDropdownMenuProps = {
  status: string;
  campaignId: string;
  title: string;
};

// 1) A map of all the allowed transitions
const STATUS_TRANSITIONS: Record<string, string[]> = {
  Pending_Review: ["Verified", "Denied"],
  Verified:       ["Live",     "Denied"],
  Live:           ["Paused",   "Completed"],
  Paused:         ["Live",     "Completed"],
  Completed:      [],
  Denied:         [],
};

// (optional) A nice human‐readable label for each enum key
const STATUS_LABELS: Record<string, string> = {
  Pending_Review: "Pending Review",
  Verified:       "Verified",
  Denied:         "Denied",
  Live:           "Live",
  Paused:         "Paused",
  Completed:      "Completed",
};

export default function ChangeCampaignVisibilityDropdownMenu({
  status,
  campaignId,
  title,
}: ChangeCampaignVisibilityDropdownMenuProps) {
  // position is the “current” status on screen
  const [position, setPosition] = useState(status);
  const [pendingStatus, setPendingStatus] = useState<string | null>(null);
  const [dropdownOpen, setDropdownOpen] = useState(false);
  const [dialogOpen, setDialogOpen] = useState(false);
  const router = useRouter();

  // look up only the valid “next” statuses
  const allowedStatuses = STATUS_TRANSITIONS[position] || [];

  const handleChange = (newStatus: string) => {
    setPendingStatus(newStatus);
    setDropdownOpen(false);
    setDialogOpen(true);
  };

  const handleConfirm = async () => {
    if (!pendingStatus) return;
    setPosition(pendingStatus);
    setDialogOpen(false);

    // … your PUT logic stays the same …
    try {
      const { accessToken } = await fetch("/api/get-token").then((r) => r.json());
      const res = await fetch(`http://localhost:4000/campaigns/${campaignId}`, {
        method: "PUT",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${accessToken}`,
        },
        body: JSON.stringify({ status: pendingStatus }),
      });
      if (!res.ok) throw new Error(await res.text());
      toast("Status Updated", {
        description: `Campaign status changed to "${STATUS_LABELS[pendingStatus]}".`,
      });
      router.refresh();
    } catch (err: unknown) {
      toast("Failed to update status");
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
        <DropdownMenuTrigger
          asChild
          // if there’s nowhere to go, disable the whole thing
          disabled={allowedStatuses.length === 0}
        >
          <Button variant="default">
            {STATUS_LABELS[position] || position}
          </Button>
        </DropdownMenuTrigger>

        {allowedStatuses.length > 0 && (
          <DropdownMenuContent className="w-56">
            <DropdownMenuLabel>Change Campaign Status</DropdownMenuLabel>
            <DropdownMenuSeparator />

            <DropdownMenuRadioGroup
              value={position}
              onValueChange={handleChange}
            >
              {allowedStatuses.map((s) => (
                <DropdownMenuRadioItem key={s} value={s}>
                  {STATUS_LABELS[s]}
                </DropdownMenuRadioItem>
              ))}
            </DropdownMenuRadioGroup>
          </DropdownMenuContent>
        )}
      </DropdownMenu>

      <Dialog open={dialogOpen} onOpenChange={setDialogOpen}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>
              Are you sure you want to change the campaign status for:<br />
              <br />
              <span className="font-bold text-xl underline">{title}</span>
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
