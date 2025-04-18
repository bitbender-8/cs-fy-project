import { UUID } from "crypto";
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

// Email omiited from Base User interface because it is optional for Recipients and requried for Supervisors.
export interface User {
  id?: UUID;
  auth0UserId?: string;
  firstName: string;
  middleName: string;
  lastName: string;
  dateOfBirth: Date | string;
  phoneNo?: string;
  email: string;
}

export interface Recipient extends User {
  bio?: string;
  profilePictureUrl?: string;
  socialMediaHandles?: SocialMediaHandle[];
}

// eslint-disable-next-line @typescript-eslint/no-empty-object-type
export interface Supervisor extends User {}

export interface SocialMediaHandle {
  id?: UUID;
  socialMediaHandle: string;
  recipientId: UUID;
}

// ================= Zod schemas ====================
// Define User schema
export const UserSchema = z.object({
  id: validUuid().optional(),
  auth0UserId: validNonEmptyString(MIN_STRING_LENGTH, 255),
  firstName: validNonEmptyString(MIN_STRING_LENGTH, 50),
  middleName: validNonEmptyString(MIN_STRING_LENGTH, 50),
  lastName: validNonEmptyString(MIN_STRING_LENGTH, 50),
  dateOfBirth: validDate(true),
  // FIXME: This is temporary, just until we add phone signups. Phone being optional that is.
  phoneNo: validPhoneNo().optional(),
  email: z.string().email(),
});

// Define SocialMediaHandle schema
export const SocialMediaHandleSchema = z.object({
  id: validUuid().optional(),
  socialMediaHandle: validUrl(),
  recipientId: validUuid(),
});

// Define Recipient schema extending User
export const RecipientSchema = UserSchema.extend({
  bio: validNonEmptyString(MIN_STRING_LENGTH, 500),
  profilePictureUrl: validUrl().optional(),
  socialMediaHandles: z.array(SocialMediaHandleSchema).optional(),
});

// Define Supervisor schema extending User
export const SupervisorSchema = UserSchema;
