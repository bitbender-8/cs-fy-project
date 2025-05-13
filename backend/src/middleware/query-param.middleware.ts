import { NextFunction, Request, Response } from "express";
import { z, ZodError, ZodSchema } from "zod";
import { ProblemDetails } from "../errors/error.types.js";

// TODO(bitbender-8): Update the other routes (completed before Apr 10) to use this middleware.
/**
 * Middleware function to validate query parameters against a Zod schema.
 *
 * @param schema - The Zod schema to validate against.
 * @returns An Express middleware function.
 */
export function validateQueryParams(schema: ZodSchema) {
  return async (
    req: Request<z.infer<typeof schema>>,
    res: Response,
    next: NextFunction,
  ) => {
    try {
      // Parse the query parameters using the provided schema
      req.validatedParams = await schema.parseAsync(req.query);
      next();
      return;
    } catch (error) {
      if (error instanceof ZodError) {
        // Handle Zod validation errors
        const problemDetails: ProblemDetails = {
          title: "Validation Failure",
          status: 400,
          detail: "One or more query parameters failed validation.",
          fieldFailures: error.issues.map((issue) => ({
            field: issue.path.join("."),
            uiMessage: issue.message,
          })),
        };
        res.status(problemDetails.status).json(problemDetails);
        return;
      }

      next(error);
      return;
    }
  };
}
