import { UUID } from "crypto";

// Email ommitted from this interface because it is optional for Recipients and required for Supervisors.
export interface User {
  id?: UUID;
  firstName: string;
  middleName: string;
  lastName: string;
  dateOfBirth: Date | string;
  phoneNo: string;
  passwordHash?: string;
  loginAttempts?: number;
  accountLockDate?: Date | string;
}

export interface Recipient extends User {
  email?: string;
  bio?: string;
  profilePictureUrl?: string;
  socialMediaHandles?: SocialMediaHandle[];
}

export interface SocialMediaHandle {
  id?: UUID;
  socialMediaHandle: string;
}

export interface Supervisor extends User {
  email: string;
}
