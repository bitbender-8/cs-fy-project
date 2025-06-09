"use server";

import { revalidatePath } from "next/cache";
import prisma from "./prisma";
import { randomUUID } from "crypto";

export async function submitCampaignUpdate(formData: FormData) {
  const updateContent = formData.get("updateContent") as string;

  const campaignId = formData.get("campaignId") as string;
  if (!updateContent) return;

  try {
    const campaign = await prisma.campaign.findFirst({
      where: { id: campaignId },
    });

    if (!campaign?.id) throw new Error("Campaign ID is missing");

    const campaignPost = await prisma.campaignPost.create({
      data: {
        id: randomUUID(),
        title: "Update for: " + campaign.title,
        content: updateContent,
        campaignId: campaign.id,
        publicPostDate: new Date(),
      },
    });

    await prisma.campaign.update({
      where: { id: campaignId },
      data: {
        CampaignPost: {
          connect: {
            id: campaignPost.id,
          },
        },
      },
    });
  } catch (error) {
    console.error(error);
    throw new Error("Error posting campaign update.");
  }
  revalidatePath(`/campaigns/${campaignId}`);
}
interface Notification {
  id: string;
  body: string | null;
  // Add other fields if needed by the component
}

export async function getUnreadNotificationsAction(): Promise<{ success: boolean; data?: Notification[]; message?: string }> {
  try {
    const notifications = await prisma.notification.findMany({
      select: {
        id: true,
        body: true,
      },
      where: {
        isRead: false,
      },
      orderBy: {
        createdAt: 'desc', // Optional: order them
      }
    });
    return { success: true, data: notifications };
  } catch (error) {
    console.error("Error fetching notifications:", error);
    return { success: false, data: [], message: String(error) };
  }
}

export async function markNotificationsAsReadAction(notificationIds: string[]): Promise<{ success: boolean; message?: string }> {
  if (!notificationIds || notificationIds.length === 0) {
    return { success: true, message: "No notifications to mark as read." }; // Not an error, just nothing to do
  }
  try {
    await prisma.notification.updateMany({
      where: {
        id: {
          in: notificationIds,
        },
        isRead: false, // Only update those that are currently unread
      },
      data: {
        isRead: true,
      },
    });
    // Revalidate the path or specific tags if you want other parts of the UI
    // that depend on this data to update.
    // For example, if this component is on '/dashboard':
    // revalidatePath('/dashboard');
    return { success: true, message: "Notifications marked as read." };
  } catch (error) {
    console.error("Error marking notifications as read:", error);
    return { success: false, message: String(error) };
  }
}