import { Request, Response, NextFunction } from "express";
import { AnyZodObject, ZodError } from "zod";

import { ProblemDetails } from "../errors/error.types.js";

/**
 * Middleware to validate the request body against a Zod schema.
 *
 * This middleware parses the request body using the provided Zod schema.
 * If the body is valid, it replaces the original req.body with the parsed result
 * and calls the next middleware or route handler.
 * If the body is invalid, it sends a 400 Validation Failure response with details.
 *
 * @param {AnyZodObject} schema - The Zod schema to validate the request body against.
 * @returns {Function} - An Express middleware function.
 */
export function validateRequestBody(schema: AnyZodObject) {
  return async (req: Request, res: Response, next: NextFunction) => {
    try {
      if (!req.body) {
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
