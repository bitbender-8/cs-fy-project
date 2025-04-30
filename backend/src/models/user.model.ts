import { z } from "zod";
import {
  MIN_STRING_LENGTH,
  USER_TYPES,
  validDate,
  validNonEmptyString,
  validPhoneNo,
  validUrl,
  validUuid,
} from "../utils/zod-helpers.js";

export type UserType = (typeof USER_TYPES)[number];

export const SENSITIVE_USER_FIELDS = [
  "auth0UserId",
  "dateOfBirth",
  "phoneNo",
] as const;
export type SensitiveUserFields = (typeof SENSITIVE_USER_FIELDS)[number];

/** These fields cannot be updated by the user.  */
export const LOCKED_USER_FIELDS = [
  "id",
  "phoneNo",
  "email",
  "auth0UserId",
] as const;
export type LockedUserFields = (typeof LOCKED_USER_FIELDS)[number];

export type User = z.infer<typeof UserSchema>;
export const UserSchema = z.object({
  id: validUuid(),
  auth0UserId: validNonEmptyString(MIN_STRING_LENGTH, 255),
  firstName: validNonEmptyString(MIN_STRING_LENGTH, 50),
  middleName: validNonEmptyString(MIN_STRING_LENGTH, 50),
  lastName: validNonEmptyString(MIN_STRING_LENGTH, 50),
  dateOfBirth: validDate(true),
  // FIXME: This is temporary, just until we add phone signups. Phone being optional that is. Review how compliant you are to your signup method promises.
  phoneNo: validPhoneNo().optional(),
  email: z.string().email(),
});

export type SocialMediaHandle = z.infer<typeof SocialMediaHandleSchema>;
export const SocialMediaHandleSchema = z.object({
  id: validUuid(),
  socialMediaHandle: validUrl(),
  recipientId: validUuid(),
});

export type Recipient = z.infer<typeof RecipientSchema>;
export const RecipientSchema = UserSchema.extend({
  bio: validNonEmptyString(MIN_STRING_LENGTH, 500),
  profilePictureUrl: validUrl().optional(),
  socialMediaHandles: z.array(SocialMediaHandleSchema).optional(),
});

export type Supervisor = z.infer<typeof SupervisorSchema>;
export const SupervisorSchema = UserSchema;
