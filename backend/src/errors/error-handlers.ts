import { NextFunction, Request, Response } from "express";
import { AppError, ProblemDetails } from "./error.types.js";

export function errorHandler(
  err: Error,
  req: Request,
  res: Response,
  _next: NextFunction
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
      detail: err.uiMessage,
      status: err.httpCode,
    };
    console.error(`Fail: ${err.internalMessage ?? err.uiMessage}`);
  }

  console.error(err);
  res.status(problemDetails.status).json(problemDetails);
  return;
}
