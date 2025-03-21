import { NextFunction, Request, Response } from "express";
import { AppError, ProblemDetails } from "./error.types.js";

export function errorHandler(
  err: Error,
  req: Request,
  res: Response,
  _next: NextFunction,
): void {
  void _next;

  let errorDetails: ProblemDetails = {
    title: "Internal Server Error",
    status: 500,
    detail: "Something went wrong.",
  };

  if (err instanceof AppError) {
    errorDetails = {
      title: err.errorType,
      detail: err.uiMessage,
      status: err.httpCode,
    };
  }

  res.status(errorDetails.status).json(errorDetails);
  return;
}
