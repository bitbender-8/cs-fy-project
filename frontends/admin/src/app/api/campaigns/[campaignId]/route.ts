import prisma from "@/lib/prisma";
import { NextRequest, NextResponse } from "next/server";
import { ResolutionType } from "@/generated/prisma";

type CampaignProps = { params: Promise<{ campaignId: string }> };

export async function POST(req: NextRequest, { params }: CampaignProps) {
  const { campaignId } = await params;

  const body = await req.json();

  const { requestType, requestId, action } = body;

  if (!requestType || !requestId || !["accept", "reject"].includes(action)) {
    return NextResponse.json({ error: "Invalid request" }, { status: 400 });
  }

  try {
    const requestTypeFormatted = (
      action === "accept" ? "Accepted" : "Rejected"
    ) as ResolutionType;

    switch (requestType) {
      case "endDateExtension": {
        const requestInfo = await prisma.endDateExtensionRequest.update({
          where: { id: requestId },
          data: { resolutionType: requestTypeFormatted },
        });

        if (action === "accept") {
          await prisma.campaign.update({
            where: { id: campaignId },
            data: { endDate: requestInfo.newEndDate },
          });
        }
        break;
      }

      case "goalAdjustment": {
        const requestInfo = await prisma.goalAdjustmentRequest.update({
          where: { id: requestId },
          data: { resolutionType: requestTypeFormatted },
        });

        if (action === "accept") {
          await prisma.campaign.update({
            where: { id: campaignId },
            data: { fundraisingGoal: requestInfo.newGoal },
          });
        }
        break;
      }

      case "goalAdjustment": {
        const requestInfo = await prisma.goalAdjustmentRequest.update({
          where: { id: requestId },
          data: { resolutionType: requestTypeFormatted },
        });

        if (action === "accept") {
          await prisma.campaign.update({
            where: { id: campaignId },
            data: { fundraisingGoal: requestInfo.newGoal },
          });
        }
        break;
      }

      case "postUpdate": {
        const requestInfo = await prisma.postUpdateRequest.update({
          where: { id: requestId },
          data: { resolutionType: requestTypeFormatted },
        });

        if (action === "accept") {
          await prisma.campaign.update({
            where: { id: campaignId },
            data: {
              CampaignPost: {
                connect: { id: requestInfo.newPostId },
              },
            },
          });
        }
        break;
      }

      case "statusChange": {
        const requestInfo = await prisma.statusChangeRequest.update({
          where: { id: requestId },
          data: { resolutionType: requestTypeFormatted },
        });

        if (action === "accept") {
          await prisma.campaign.update({
            where: { id: campaignId },
            data: {
              status: requestInfo.newStatus,
            },
          });
        }
        break;
      }
    }

    // todo: in front end, show only campaigns whose status is null in the request list.

    // Example response (simulate DB write)
    return NextResponse.json({
      message: `${action}d request successfully`,
      campaignId,
      requestId,
      requestType,
    });
  } catch (error) {
    console.error("API error:", error);
    return NextResponse.json(
      { error: "Internal server error" },
      { status: 500 },
    );
  }
}
