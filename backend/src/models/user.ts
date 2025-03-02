import { UUID } from "crypto";

export interface User {
  id: UUID;
  firstName: string;
  middleName: string;
  lastName: string;
  dateOfBirth: string;
  email: string;
  phoneNo: string;
  passwordHash: string;
  loginAttempts: number;
  accountLockDate: Date;
}

export interface Recipient extends User {
  bio: string;
  profilePictureUrl: string;
  socialMediaHandles: RecipientSocialMediaHandle[];
}

export interface RecipientSocialMediaHandle {
  id: UUID;
  socialMediaHandle: string;
}

export interface Supervisor extends User {}
