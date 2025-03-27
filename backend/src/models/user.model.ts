import { UUID } from "crypto";
import { z } from "zod";
import {
  MIN_STRING_LENGTH,
  validDate,
  validNonEmptyString,
  validPhoneNo,
  validUrl,
  validUuid,
} from "../utils/zod-helpers.js";

export type UserRole = "Supervisor" | "Recipient";

// Email omiited from Base User interface because it is optional for Recipients and requried for Supervisors
export interface User {
  id?: UUID;
  auth0UserId?: string;
  firstName: string;
  middleName: string;
  lastName: string;
  dateOfBirth: string;
  phoneNo?: string;
}

export interface Recipient extends User {
  email?: string;
  bio?: string;
  profilePictureUrl?: string;
  socialMediaHandles?: SocialMediaHandle[];
}

export interface Supervisor extends User {
  email: string;
}

export interface SocialMediaHandle {
  id?: UUID;
  socialMediaHandle: string;
  recipientId: UUID;
}

// ================= Zod schemas ====================
// Define User schema
export const UserSchema = z.object({
  id: validUuid().optional(),
  auth0UserId: validNonEmptyString(MIN_STRING_LENGTH, 100),
  firstName: validNonEmptyString(MIN_STRING_LENGTH, 50),
  middleName: validNonEmptyString(MIN_STRING_LENGTH, 50),
  lastName: validNonEmptyString(MIN_STRING_LENGTH, 50),
  dateOfBirth: validDate(true),
  // FIXME: This is temporary, just until we add phone signups.
  phoneNo: validPhoneNo().optional(),
});

// Define SocialMediaHandle schema
export const SocialMediaHandleSchema = z.object({
  id: validUuid().optional(),
  socialMediaHandle: validUrl(),
  recipientId: validUuid(),
});

// Define Recipient schema extending User
export const RecipientSchema = UserSchema.extend({
  email: z.string().email().optional(),
  bio: validNonEmptyString(MIN_STRING_LENGTH, 500),
  profilePictureUrl: validUrl().optional(),
  socialMediaHandles: z.array(SocialMediaHandleSchema).optional(),
});

// Define Supervisor schema extending User
export const SupervisorSchema = UserSchema.extend({
  email: z.string().email(),
});
