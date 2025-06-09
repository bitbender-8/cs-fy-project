import { NextResponse } from "next/server";
import prisma from "@/lib/prisma";
import { Prisma } from "@/generated/prisma";

type StatusProps = { params: Promise<{ campaignId: string }> };

type CampaignType = Prisma.CampaignGetPayload<{
  select: {
    id: true;
    status: true;
    launchDate: true;
    isPublic: true;
    verificationDate: true;
  };
}>;

export async function PATCH(request: Request, { params }: StatusProps) {
  const { campaignId } = await params;
  const { status } = await request.json();

  // Fetch current campaign to check launchDate and isPublic
  const campaign = await prisma.campaign.findUnique({
    where: { id: campaignId },
    select: { launchDate: true, isPublic: true, verificationDate: true },
  });

  const updateData: CampaignType = {
    id: campaignId,
    status,
    launchDate: campaign?.launchDate ?? null,
    isPublic: campaign?.isPublic ?? false,
    verificationDate: campaign?.verificationDate ?? null,
  };

  // If status is changed to "Live" and launchDate is null, set launchDate to now
  if (status === "Live" && campaign?.launchDate == null) {
    updateData.launchDate = new Date();
  }

  // If status is not "Completed" or "Live", set isPublic to false
  // Or if status is one of the specified statuses, set isPublic to false
  const makePrivateStatuses = [
    "Pending Review",
    "Paused",
    "Verified",
    "Denied",
  ];
  if (status !== "Completed" && status !== "Live") {
    updateData.isPublic = false;
  }

  if (status === "Completed" || status === "Live") {
    updateData.isPublic = true;
  }

  if (makePrivateStatuses.includes(status)) {
    updateData.isPublic = false;
  }

  if (status === "Verified" && campaign?.verificationDate == null) {
    updateData.verificationDate = new Date();
  }

  const updated = await prisma.campaign.update({
    where: { id: campaignId },
    data: updateData,
  });

  return NextResponse.json({
    id: updated.id,
    status: updated.status,
    launchDate: updated.launchDate,
    isPublic: updated.isPublic,
  });
}
