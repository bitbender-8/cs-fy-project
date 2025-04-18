import { UUID } from "crypto";
import { config } from "../config.js";
import { NotificationFilter } from "../models/filters/notification-filters.js";
import { Notification } from "../models/notification.model.js";
import { PaginatedList } from "../utils/utils.js";
import { query } from "../db.js";
import { AppError } from "../errors/error.types.js";

export async function getNotifications(
  filterParams: NotificationFilter & { id?: UUID; userId?: UUID }
): Promise<PaginatedList<Notification>> {
  const pageNo = filterParams.page || 1;
  const limit = filterParams.limit ?? config.PAGE_SIZE;
  const whereClauses: string[] = [];
  const values: unknown[] = [];
  let paramIndex = 1;

  if (filterParams.id) {
    whereClauses.push(`"id" = $${paramIndex}`);
    values.push(filterParams.id);
    paramIndex++;
  }

  if (filterParams.minCreatedAt) {
    whereClauses.push(`"createdAt" >= $${paramIndex}`);
    values.push(filterParams.minCreatedAt);
    paramIndex++;
  }

  if (filterParams.maxCreatedAt) {
    whereClauses.push(`"createdAt" <= $${paramIndex}`);
    values.push(filterParams.maxCreatedAt);
    paramIndex++;
  }

  if (filterParams.isRead !== undefined) {
    whereClauses.push(`"isRead" = $${paramIndex}`);
    values.push(filterParams.isRead);
    paramIndex++;
  }

  if (filterParams.userId) {
    whereClauses.push(
      `("supervisorId" = $${paramIndex} OR "recipientId" = $${paramIndex})`
    );
    values.push(filterParams.userId);
    paramIndex++;
  }

  const whereClause: string =
    whereClauses.length > 0 ? ` WHERE ${whereClauses.join(" AND ")}` : "";

  const queryString = ` 
    SELECT
        "id",
        "subject",
        "body",
        "isRead",
        "createdAt",
        "recipientId",
        "supervisorId"
    FROM
        "Notification"
    ${whereClause}
    LIMIT $${paramIndex} OFFSET $${paramIndex + 1}
  `;

  const offset = (pageNo - 1) * limit;
  values.push(limit, offset);
  const result = await query(queryString, values);

  const countQueryString = `
    SELECT COUNT(*)
    FROM "Notification"
    ${whereClause}
  `;
  const countResult = await query(
    countQueryString,
    values.slice(0, values.length - 2)
  );

  const totalCount = parseInt(countResult.rows[0].count, 10);
  const pageCount = Math.ceil(totalCount / limit);

  const items = (
    result.rows as (Omit<Notification, "userId" | "userType"> & {
      recipientId: UUID | null;
      supervisorId: UUID | null;
    })[]
  ).map((item) => {
    const resolvedItem: Notification = {
      id: item.id,
      subject: item.subject,
      body: item.body,
      isRead: item.isRead,
      createdAt: item.createdAt,
      // One of them will be non-null due to DB constraint
      userId: item.recipientId ?? item.supervisorId!,
      userType: item.recipientId ? "Recipient" : "Supervisor",
    };
    return resolvedItem;
  });

  return {
    items,
    pageNo,
    pageCount,
  };
}

export async function markNotificationAsRead(
  notificationId: UUID
): Promise<Notification> {
  const result = await query<Notification>(
    `
    UPDATE "Notification"
    SET "isRead" = true
    WHERE "id" = $1
    RETURNING *
    `,
    [notificationId]
  );

  if (!result || result.rows.length === 0) {
    throw new AppError("Not Found", 404, "Notification not found", {
      internalDetails: "A notification with the given Id does not exist",
    });
  }

  return result.rows[0];
}

export async function deleteNotification(
  notificationId: UUID
): Promise<boolean> {
  const result = await query(`DELETE FROM "Notification" WHERE "id" = $1`, [
    notificationId,
  ]);

  return (result.rowCount ?? -1) > 0;
}
