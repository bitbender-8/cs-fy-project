export type FieldVaildationFailure = {
  field: string;
  uiMessage: string;
};

/** A structured error or problem response for an api. */
export interface ProblemDetails {
  /** A short, human-readable summary of the problem. Safe to show in a UI. */
  title: AppErrorType;

  /** The HTTP status code for the problem. */
  status: number;

  /** A detailed explanation of the problem. Safe to show in a UI. */
  detail: string;

  fieldFailures?: FieldVaildationFailure[];
}

/**
 * Application-specific error with additional details for UI display.
 */
export class AppError extends Error {
  constructor(
    public readonly errorType: AppErrorType,
    public httpCode: number,
    public message: string,
    public options?: {
      cause?: Error;
      internalDetails?: string | object;
    }
  ) {
    super(message, { cause: options?.cause });
  }
}

/** Application-wide error types. Safe to show in a UI. */
export type AppErrorType =
  | "Internal Server Error"
  | "Validation Failure"
  | "Not Found"
  | "Permission Denied"
  | "Service Unavailable"
  | "Authentication Required";
