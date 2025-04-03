import { z } from "zod";
import {
  MIN_STRING_LENGTH,
  validDate,
  validNonEmptyString,
  validPhoneNo,
} from "../../utils/zod-helpers.js";

export type UserFilterParams = z.infer<typeof UserFilterSchema>;
export const UserFilterSchema = z.object({
  name: validNonEmptyString(MIN_STRING_LENGTH, 150).optional(),
  email: z.string().email().optional(),
  page: z.coerce.number().int().positive().optional(),
  limit: z.coerce.number().int().positive().optional(),

  // Sensitive filters
  minBirthDate: validDate(true).optional(),
  maxBirthDate: validDate(true).optional(),
  phoneNo: validPhoneNo().optional(),
});

export type SensitiveUserFilters = (typeof SENSITIVE_USER_FILTERS)[number];
export const SENSITIVE_USER_FILTERS = [
  "minBirthDate",
  "maxBirthDate",
  "phoneNo",
] as const;
