import { NextResponse } from "next/server";
import prisma from "@/lib/prisma";

type StatusProps = { params: Promise<{ campaignId: string }> };

export async function PATCH(request: Request, { params }: StatusProps) {
  const { campaignId } = await params;
  const { status } = await request.json();
  const updated = await prisma.campaign.update({
    where: { id: campaignId },
    data: { status },
  });

  return NextResponse.json({
    id: updated.id,
    status: updated.status,
  });
}
