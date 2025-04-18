import { z } from "zod";
import {
  MIN_STRING_LENGTH,
  validDate,
  validNonEmptyString,
  validUserType,
  validUuid,
} from "../utils/zod-helpers.js";

export type Notification = z.infer<typeof NotificationSchema>;
export const NotificationSchema = z.object({
  id: validUuid().optional(),
  subject: validNonEmptyString(MIN_STRING_LENGTH, 255),
  body: validNonEmptyString(MIN_STRING_LENGTH, 500),
  isRead: z.boolean(),
  createdAt: validDate(true),
  userId: validUuid(),
  userType: validUserType(),
});
