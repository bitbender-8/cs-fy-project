import prisma from "@/lib/prisma";
import { NextRequest, NextResponse } from "next/server";
import { ResolutionType } from "@/generated/prisma";
import { auth0 } from "@/lib/auth0";
import { randomUUID } from 'crypto'; // Import randomUUID

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

    const session = await auth0.getSession();
    const auth0UserId = session?.user.sub;

    const supervisor = await prisma.supervisor.findUnique({
      where: {
        auth0UserId: auth0UserId,
      },
    });

    // Fetch campaign details to get Recipient.id and title
    const campaign = await prisma.campaign.findUnique({
      where: { id: campaignId },
      include: {
        Recipient: {
          select: {
            id: true,
          },
        },
        // title is a scalar field on Campaign and will be included by default here
      },
    });

    if (!campaign) {
      return NextResponse.json(
        { error: "Campaign not found" },
        { status: 404 }
      );
    }

    // Adjusted console.error condition for clarity and safety
    if (!campaign.Recipient?.id || !supervisor?.id) {
      console.error(
        "Campaign is missing Recipient.id or supervisor.id (or supervisor not found). Cannot create notifications."
      );
      // Decide if this should be a hard error or just a warning
      // For now, let's proceed with the main action but log the issue.
    }

    switch (requestType) {
      case "endDateExtension": {
        const requestInfo = await prisma.endDateExtensionRequest.update({
          where: { id: requestId },
          data: {
            resolutionType: requestTypeFormatted,
            resolutionDate: new Date(),
          },
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
        // Note: There are two identical "goalAdjustment" cases in your original code.
        // Assuming this is a copy-paste error and one might be different or redundant.
        // I'm keeping one for this example.
        const requestInfo = await prisma.goalAdjustmentRequest.update({
          where: { id: requestId },
          data: {
            resolutionType: requestTypeFormatted,
            resolutionDate: new Date(),
          },
        });

        if (action === "accept") {
          await prisma.campaign.update({
            where: { id: campaignId },
            data: { fundraisingGoal: requestInfo.newGoal },
          });
        }
        break;
      }

      // Removed duplicate "goalAdjustment" case here for brevity. Ensure your logic is correct.

      case "postUpdate": {
        const requestInfo = await prisma.postUpdateRequest.update({
          where: { id: requestId },
          data: {
            resolutionType: requestTypeFormatted,
            resolutionDate: new Date(),
          },
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
          data: {
            resolutionType: requestTypeFormatted,
            resolutionDate: new Date(),
          },
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

    // Create notifications if Recipient.id and supervisor.id are available
    // Adjusted condition for safety: check campaign.Recipient and supervisor before accessing their ids
    if (campaign.Recipient?.id && supervisor?.id && campaign.title) {
      let subject = "";
      let notificationBody = "";
      const actionPastTense = action === "accept" ? "accepted" : "rejected";

      switch (requestType) {
        case "endDateExtension":
          subject = `End Date Extension Request ${actionPastTense}`;
          notificationBody = `Your request to extend the end date for the campaign "${campaign.title}" has been ${actionPastTense}.`;
          break;
        case "goalAdjustment":
          subject = `Goal Adjustment Request ${actionPastTense}`;
          notificationBody = `Your request to adjust the fundraising goal for the campaign "${campaign.title}" has been ${actionPastTense}.`;
          break;
        case "postUpdate":
          subject = `Post Update Request ${actionPastTense}`;
          notificationBody = `Your request to add a new post for the campaign "${campaign.title}" has been ${actionPastTense}.`;
          break;
        case "statusChange":
          subject = `Status Change Request ${actionPastTense}`;
          notificationBody = `Your request to change the status for the campaign "${campaign.title}" has been ${actionPastTense}.`;
          break;
        default:
          subject = `Campaign Update Request ${actionPastTense}`;
          notificationBody = `A request regarding the campaign "${campaign.title}" has been ${actionPastTense}.`;
      }

      const notificationsToCreate = [
        {
          id: randomUUID(), // Added generated ID
          subject,
          body: notificationBody,
          isRead: false,
          recipientId: campaign.Recipient.id, // Safe to access due to the if condition
          supervisorId: null,
        },
        {
          id: randomUUID(), // Added generated ID
          subject,
          body: notificationBody,
          isRead: false,
          recipientId: null,
          supervisorId: supervisor.id, // Safe to access due to the if condition
        },
      ];

      await prisma.notification.createMany({
        data: notificationsToCreate,
      });
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
      { status: 500 }
    );
  }
}