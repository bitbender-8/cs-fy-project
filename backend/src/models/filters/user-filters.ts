import { z } from "zod";
import {
  MIN_STRING_LENGTH,
  validDate,
  validNonEmptyString,
  validPhoneNo,
} from "../../utils/zod-helpers.js";

export type UserFilter = z.infer<typeof UserFilterSchema>;
export const UserFilterSchema = z
  .object({
    // DEFER(TODO): Add to openapi.yml
    auth0UserId: validNonEmptyString(MIN_STRING_LENGTH, 150),
    name: validNonEmptyString(MIN_STRING_LENGTH, 150),
    email: z.string().email().optional(),
    page: z.coerce.number().int().positive(),
    limit: z.coerce.number().int().positive(),

    // Sensitive filters
    minBirthDate: validDate(true),
    maxBirthDate: validDate(true),
    phoneNo: validPhoneNo(),
  })
  .partial();

export type SensitiveUserFilters = (typeof SENSITIVE_USER_FILTERS)[number];
export const SENSITIVE_USER_FILTERS = [
  "auth0UserId",
  "minBirthDate",
  "maxBirthDate",
  "phoneNo",
] as const;
