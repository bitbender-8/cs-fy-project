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
