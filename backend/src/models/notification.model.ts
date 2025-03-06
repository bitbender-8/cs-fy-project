import { UUID } from "crypto";

export interface Notification {
  id: UUID;
  subject: string;
  body: string;
  isRead: boolean;
  timestamp: Date | string;
}
