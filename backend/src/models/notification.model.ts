import { UUID } from "crypto";
import { z } from "zod";
import {
  MIN_STRING_LENGTH,
  validDate,
  validNonEmptyString,
  validUuid,
} from "../utils/zod-helpers.js";

export type Notification =
  | {
      id: UUID;
      subject: string;
      body: string;
      isRead: boolean;
      createdAt: Date | string;
      recipientId: UUID;
    }
  | {
      id: UUID;
      subject: string;
      body: string;
      isRead: boolean;
      createdAt: Date | string;
      supervisorId: UUID;
    };

// ================= Zod schemas ====================
export const NotificationSchema = z.object({
  id: validUuid().optional(),
  subject: validNonEmptyString(MIN_STRING_LENGTH, 255),
  body: validNonEmptyString(MIN_STRING_LENGTH, 500),
  isRead: z.boolean(),
  createdAt: validDate(true),
  userId: validUuid(),
});
