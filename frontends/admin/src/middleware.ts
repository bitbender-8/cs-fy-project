import { NextResponse, type NextRequest } from "next/server";
import { jwtDecode } from "jwt-decode";

import { auth0 } from "./lib/auth0";

export async function middleware(request: NextRequest) {
  const authRes = await auth0.middleware(request);

  if (request.nextUrl.pathname.startsWith("/auth")) {
    return authRes;
  }

  const session = await auth0.getSession(request);

  if (!session) {
    // user is not authenticated, redirect to login page
    return NextResponse.redirect(
      new URL("/auth/login", request.nextUrl.origin),
    );
  }

  // This is it, check your console.log()
  const roleKey = `${process.env.AUTH0_NAMESPACE}/roles`;
  const accessToken = await auth0.getAccessToken();
  const decodedAccessToken = jwtDecode<{ [key: string]: string[] }>(
    accessToken.token,
  );
  const role = decodedAccessToken[roleKey];
  if (role[0] !== "Supervisor") {
    return NextResponse.redirect(
      new URL("/auth/logout", request.nextUrl.origin),
    );
  }

  // the headers from the auth middleware should always be returned
  return authRes;
}

export const config = {
  matcher: [
    /*
     * Match all request paths except for the ones starting with:
     * - _next/static (static files)
     * - _next/image (image optimization files)
     * - favicon.ico, sitemap.xml, robots.txt (metadata files)
     */
    "/((?!_next/static|_next/image|favicon.ico|sitemap.xml|robots.txt).*)",
  ],
};
