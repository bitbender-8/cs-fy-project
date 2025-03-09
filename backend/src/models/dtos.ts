import { Recipient, Supervisor, User } from "./user.model.js";

type SensitiveUserFields = "passwordHash" | "loginAttempts" | "accountLockDate";
export type BaseUserDto<T extends User> = Omit<T, SensitiveUserFields>;
export type RecipientDto = BaseUserDto<Recipient>;
export type SupervisorDto = BaseUserDto<Supervisor>;
