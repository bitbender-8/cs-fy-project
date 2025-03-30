import { auth } from "express-oauth2-jwt-bearer";
import { config } from "../config.js";
import { Request, Response, NextFunction } from "express";
import { ProblemDetails } from "../errors/error.types.js";

export const jwtCheck = auth({
  issuerBaseURL: config.ISSUER_BASE_URL,
  audience: config.AUDIENCE,
  authRequired: false,
});

/**
 * Verifies user authentication.
 *
 * Throws an {@link AppError} with a 401 Unauthenticated status if the provided authToken is missing,
 * indicating that the user is not authenticated.
 */
export function requireAuthentication(
  req: Request,
  res: Response,
  next: NextFunction
): void {
  if (!req.auth) {
    const problemDetails: ProblemDetails = {
      title: "Authentication Required",
      status: 403,
      detail: "You must be authenticated to access this resource.",
    };
    res.status(problemDetails.status).json(problemDetails);
    return;
  }
  next();
}
