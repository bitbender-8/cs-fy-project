import { Recipient } from "./user.model.js";

export interface RecipientDto
  extends Omit<
    Recipient,
    | "id"
    | "passwordHash"
    | "loginAttempts"
    | "accountLockDate"
    | "profilePictureUrl"
    | "dateOfBirth"
  > {
  password: string;
  passwordConfirmation: string;
  dateOfBirth: string;
}
