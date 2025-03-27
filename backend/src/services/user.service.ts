import { JWTPayload } from "express-oauth2-jwt-bearer";

import { config } from "../config.js";
import { UserRole } from "../models/user.model.js";

export function getUserRoles(authToken?: { payload: JWTPayload }): UserRole[] {
  return (
    (authToken?.payload[`${config.AUTH0_NAMESPACE}/roles`] as UserRole[]) ?? []
  );
}

// Does the user with this auth0 ID exist?
export async function verifyAuth0UserId(auth0UserId?: string ):  
