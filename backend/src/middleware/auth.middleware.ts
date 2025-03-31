import { auth } from "express-oauth2-jwt-bearer";
import { config } from "../config.js";

export const requireAuthentication = auth({
  issuerBaseURL: config.ISSUER_BASE_URL,
  audience: config.AUDIENCE,
});
