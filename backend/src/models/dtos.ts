import {
  Recipient,
  Supervisor,
  User,
  SensitiveUserFields,
} from "./user.model.js";

export type UserDto<T extends User> = Omit<T, SensitiveUserFields>;
export type RecipientDto = UserDto<Recipient>;
export type SupervisorDto = UserDto<Supervisor>;
