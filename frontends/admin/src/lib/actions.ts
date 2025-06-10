"use server";

import { revalidatePath } from "next/cache";
import prisma from "./prisma";
import { randomUUID } from "crypto";
import { auth0 } from "./auth0";

export async function submitCampaignUpdate(formData: FormData) {
  const postContent = formData.get("postContent") as string;
  const postTitle = formData.get("postTitle") as string;

  const campaignId = formData.get("campaignId") as string;
  if (!campaignId || !postTitle || !postContent) {
    return {
      success: false,
      message: "Missing required fields: title, content, or campaign ID.",
    };
  }

  try {
    const campaign = await prisma.campaign.findFirst({
      where: { id: campaignId },
    });

    if (!campaign?.id) throw new Error("Campaign ID is missing");

    const campaignPost = await prisma.campaignPost.create({
      data: {
        id: randomUUID(),
        title: postTitle,
        content: postContent,
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
    // revalidatePath(`/campaigns/${campaignId}`);
    return { success: true, message: "Campaign update posted successfully." };
  } catch (error) {
    console.error(error);
    return {
      success: false,
      message: "Failed to post campaign update. Please try again.",
    };
  }
}
interface Notification {
  id: string;
  body: string | null;
  // Add other fields if needed by the component
}

export async function getUnreadNotificationsAction(): Promise<{
  success: boolean;
  data?: Notification[];
  message?: string;
}> {
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
        createdAt: "desc", // Optional: order them
      },
    });
    return { success: true, data: notifications };
  } catch (error) {
    console.error("Error fetching notifications:", error);
    return { success: false, data: [], message: String(error) };
  }
}

export async function markNotificationsAsReadAction(
  notificationIds: string[]
): Promise<{ success: boolean; message?: string }> {
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

export async function updateSupervisorProfile(formData: FormData) {
  "use server";
  const session = await auth0.getSession();
  if (!session?.user?.sub) {
    // It's good practice to re-check auth in server actions
    return { success: false, error: "User not authenticated" };
  }

  const auth0UserId = session.user.sub;

  // Validate and sanitize your data here before updating the database
  const dataToUpdate: {
    firstName?: string;
    middleName?: string;
    lastName?: string;
    phoneNo?: string;
    // dateOfBirth?: Date; // Be careful with date parsing
  } = {};

  const firstName = formData.get("firstName") as string;
  const middleName = formData.get("middleName") as string;
  const lastName = formData.get("lastName") as string;
  const phoneNo = formData.get("phoneNo") as string;
  // const dateOfBirthString = formData.get("dateOfBirth") as string;

  if (firstName) dataToUpdate.firstName = firstName;
  if (middleName !== null && middleName !== undefined)
    dataToUpdate.middleName = middleName; // Allow empty string for optional fields
  if (lastName) dataToUpdate.lastName = lastName;
  if (phoneNo !== null && phoneNo !== undefined) dataToUpdate.phoneNo = phoneNo;
  // if (dateOfBirthString) dataToUpdate.dateOfBirth = new Date(dateOfBirthString);

  if (Object.keys(dataToUpdate).length === 0) {
    return { success: false, error: "No data provided to update." };
  }

  try {
    const updatedSupervisor = await prisma.supervisor.update({
      where: { auth0UserId },
      data: dataToUpdate,
    });
    // Revalidate the profile path to ensure fresh data is shown
    // revalidatePath("/profile"); // Next.js 13+ App Router feature
    return { success: true, supervisor: updatedSupervisor };
  } catch (error) {
    console.error("Failed to update profile:", error);
    // Be careful not to expose sensitive error details to the client
    return { success: false, error: "An unexpected error occurred." };
  }
}
