"use client";

import { useRouter } from "next/navigation";
import { Button } from "./ui/button";

type CampaignRequestAccepterAndDenierProps = {
  requestType:
    | "endDateExtension"
    | "goalAdjustment"
    | "postUpdate"
    | "statusChange";
  campaignId: string;
  requestId: string;
};

export default function CampaignRequestAccepterAndDenier({
  requestType,
  campaignId,
  requestId,
}: CampaignRequestAccepterAndDenierProps) {
  const router = useRouter();

  const handleRequestAction = async (action: "accept" | "reject") => {
    try {
      const res = await fetch(`/api/campaigns/${campaignId}`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          requestType,
          requestId,
          action,
        }),
      });

      if (!res.ok) {
        throw new Error(`Failed to ${action} request`);
      }

      const data = await res.json();
      console.log(`${action}d successfully:`, data);
      router.refresh();
    } catch (error) {
      console.error(`Error trying to ${action}:`, error);
    }
  };

  return (
    <>
      <Button variant="default" onClick={() => handleRequestAction("accept")}>
        Approve
      </Button>

      <Button
        variant="destructive"
        onClick={() => handleRequestAction("reject")}
      >
        Decline
      </Button>
    </>
  );
}
