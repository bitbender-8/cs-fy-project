import { auth } from "express-oauth2-jwt-bearer";
import { config } from "../config.js";

export const jwtCheck = auth({
  issuerBaseURL: config.ISSUER_BASE_URL,
  audience: config.AUDIENCE,
  authRequired: false,
});
