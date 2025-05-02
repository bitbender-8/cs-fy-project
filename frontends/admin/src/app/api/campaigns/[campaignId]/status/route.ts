import { NextResponse } from "next/server";
import prisma from "@/lib/prisma";

export async function PATCH(
  request: Request,
  { params }: { params: { campaignId: string } }
) {
  params = await params;
  const { status } = await request.json();
  const updated = await prisma.campaign.update({
    where: { id: params.campaignId },
    data: { status },
  });

  return NextResponse.json({
    id: updated.id,
    status: updated.status,
  });
}
