import { auth } from "express-oauth2-jwt-bearer";
import { config } from "../config.js";
import { NextFunction, Request, Response } from "express";
import { getUuidFromAuth0Id } from "../repositories/user.repo.js";

export const optionalAuth = auth({
  issuerBaseURL: config.ISSUER_BASE_URL,
  audience: config.AUDIENCE,
  authRequired: false,
});

export const requireAuth = async (
  req: Request,
  res: Response,
  next: NextFunction,
) => {
  const authMiddleware = auth({
    issuerBaseURL: config.ISSUER_BASE_URL,
    audience: config.AUDIENCE,
  });

  authMiddleware(req, res, async (err) => {
    if (err) {
      return next(err);
    }
    // CONSIDER: Updating old code to get the user UUID from here instead.
    await getUuidFromAuth0Id(req.auth?.payload.sub ?? "");
    next();
  });
};
