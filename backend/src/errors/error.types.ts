export type FieldVaildationFailure = {
  field: string;
  uiMessage: string;
};

/** A structured error or problem response for an api. */
export interface ProblemDetails {
  /** A short, human-readable summary of the problem. Safe to show in a UI. */
  title: ResponseErrorType;

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
    public readonly errorType: ResponseErrorType,
    public readonly httpCode: number,
    public readonly message: string,
    public readonly options?: {
      readonly cause?: Error;
      readonly internalDetails?: string | object;
    },
    public readonly code?: AppErrorCode
  ) {
    super(message, { cause: options?.cause });
  }
}

/** Error types to be used for HTTP responses. Safe to show in a UI. */
export type ResponseErrorType =
  | "Internal Server Error"
  | "Validation Failure"
  | "Payment Verification Failure"
  | "Not Found"
  | "Permission Denied"
  | "Service Unavailable"
  | "Authentication Required";

// I have only defined codes for the errors I will actually use
export type AppErrorCode = "DUPLICATE_EMAIL" | "DUPLICATE_AUTH0_USER";
