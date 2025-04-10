import { NextFunction, Request, Response } from "express";
import { AppError, ProblemDetails } from "./error.types.js";
import {
  InvalidTokenError,
  UnauthorizedError,
} from "express-oauth2-jwt-bearer";

export function errorHandler(
  err: Error,
  req: Request,
  res: Response,
  _next: NextFunction,
): void {
  void _next;

  let problemDetails: ProblemDetails = {
    title: "Internal Server Error",
    status: 500,
    detail: "Something went wrong.",
  };

  if (err instanceof AppError) {
    problemDetails = {
      title: err.errorType,
      status: err.httpCode,
      detail: err.message,
    };
    console.error(
      `Fail: ${err.options?.internalDetails ?? err.message}
       Cause: ${err.options?.cause?.message}`.replace(/^\s+/gm, ""),
    );
    res.status(problemDetails.status).json(problemDetails);
    return;
  }

  if (err instanceof UnauthorizedError) {
    if (
      err instanceof InvalidTokenError &&
      err.message === "Failed to fetch authorization server metadata"
    ) {
      const problemDetails: ProblemDetails = {
        title: "Internal Server Error",
        status: 503,
        detail: "Failed to contact authorization servers. Try again later",
      };
      res.status(problemDetails.status).json(problemDetails);
      return;
    }
    const problemDetails: ProblemDetails = {
      title: "Authentication Required",
      status: 401,
      detail: "You must be authenticated to access this resource.",
    };
    res.status(problemDetails.status).json(problemDetails);
    return;
  }

  console.error(err);
  res.status(problemDetails.status).json(problemDetails);
  return;
}
