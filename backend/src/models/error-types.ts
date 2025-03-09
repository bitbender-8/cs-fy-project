export interface ProblemDetails {
  title: string;
  status?: number;
  detail?: string;
  [key: string]: unknown;
}

interface UIMessage {
  uiMessage: string;
}

export class ConstraintViolationError extends Error implements UIMessage {
  constructor(
    message: string,
    public uiMessage: string,
    public field: string,
  ) {
    super(message);
  }
}

export class ForeignKeyConstraintError extends ConstraintViolationError {
  constructor(uiMessage: string, field: string, relatedTable: string) {
    super(
      `Foreign key constraint violation on field '${field}' referencing table '${relatedTable}'.`,
      uiMessage,
      field,
    );
  }
}

export class UniqueKeyConstraintError extends ConstraintViolationError {
  constructor(uiMessage: string, field: string) {
    super(
      `Unique key constraint violation on field '${field}'.`,
      uiMessage,
      field,
    );
  }
}
