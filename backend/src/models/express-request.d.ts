declare module "express" {
  interface Request {
    validatedParams?: unknown;
  }
}

export {};
