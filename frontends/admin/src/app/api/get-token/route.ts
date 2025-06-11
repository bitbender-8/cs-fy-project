import { NextResponse } from "next/server";
import { auth0 } from "@/lib/auth0";

export async function GET() {
  const accessToken = await auth0.getAccessToken();
  return NextResponse.json({ accessToken: accessToken.token });
}