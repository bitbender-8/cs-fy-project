import { z } from "zod";
import { validBoolean, validDate } from "../../utils/zod-helpers.js";

export type NotificationFilter = z.infer<typeof notificationFilterSchema>;
export const notificationFilterSchema = z
  .object({
    isRead: validBoolean(),
    minCreatedAt: validDate(true),
    maxCreatedAt: validDate(true),
    page: z.coerce.number().int().positive(),
    limit: z.coerce.number().int().positive(),
  })
  .partial();
