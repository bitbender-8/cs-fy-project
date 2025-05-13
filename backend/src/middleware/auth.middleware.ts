import { auth } from "express-oauth2-jwt-bearer";
import { config } from "../config.js";

export const optionalAuth = auth({
  issuerBaseURL: config.ISSUER_BASE_URL,
  audience: config.AUDIENCE,
  authRequired: false,
});

export const requireAuth = auth({
  issuerBaseURL: config.ISSUER_BASE_URL,
  audience: config.AUDIENCE,
});
