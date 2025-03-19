import { JWTPayload } from "express-oauth2-jwt-bearer";

import { config } from "../config.js";
import { UserRole } from "../models/user.model.js";

export function getUserRoles(authToken?: { payload: JWTPayload }): UserRole[] {
  return (
    (authToken?.payload[`${config.AUTH0_NAMESPACE}/roles`] as UserRole[]) ?? []
  );
}
