import { Request, Response, NextFunction } from "express";
import { ZodError, ZodSchema } from "zod";

import { ProblemDetails } from "../errors/error.types.js";

/**
 * Middleware to validate the request body against a Zod schema.
 *
 * @param schema - The Zod schema to validate the request body against.
 * @returns - An Express middleware function.
 */
export function validateRequestBody(schema: ZodSchema) {
  return async (req: Request, res: Response, next: NextFunction) => {
    try {
      if (!req.body || Object.keys(req.body).length === 0) {
        const problemDetails: ProblemDetails = {
          title: "Validation Failure",
          status: 400,
          detail: "Request body cannot be empty",
        };
        res.status(problemDetails.status).json(problemDetails);
        return;
      }

      req.body = await schema.parseAsync(req.body);
      next();
    } catch (error) {
      if (error instanceof ZodError) {
        const problemDetails: ProblemDetails = {
          title: "Validation Failure",
          status: 400,
          detail: "One or more request body fields failed validation",
          fieldFailures: error.issues.map((issue) => ({
            field: issue.path.join("."),
            uiMessage: issue.message,
          })),
        };
        res.status(problemDetails.status).json(problemDetails);
        return;
      }

      next(error);
    }
  };
}
