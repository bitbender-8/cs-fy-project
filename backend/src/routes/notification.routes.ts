import { Request, Response, Router } from "express";
import { requireAuth } from "../middleware/auth.middleware.js";
import { validateQueryParams } from "../middleware/query-param.middleware.js";
import {
  NotificationFilter,
  notificationFilterSchema,
} from "../models/filters/notification-filters.js";
import { getUuidFromAuth0Id } from "../repositories/user.repo.js";
import { Notification } from "../models/notification.model.js";
import { PaginatedList, validateUuidParam } from "../utils/utils.js";
import {
  deleteNotification,
  getNotifications,
  markNotificationAsRead,
} from "../repositories/notification.repo.js";
import { ProblemDetails } from "../errors/error.types.js";

export const notificationRouter: Router = Router();

/**
 * @route GET /notifications
 * @description Retrieves a paginated list of notifications for the authenticated user.
 * Users can only access their own notifications.
 *
 * @param {Request} req - Express request object, expects query parameters for filtering (see `NotificationFilterSchema`).
 * @param {Response} res - Express response object.
 * @returns {Response} 200 - A paginated list of notifications.
 * @returns {Response} 401 - If the user is not authenticated.
 */
notificationRouter.get(
  "/",
  requireAuth,
  validateQueryParams(notificationFilterSchema),
  async (req: Request, res: Response): Promise<void> => {
    const filterParams = req.validatedParams as NotificationFilter;
    const userUuid = await getUuidFromAuth0Id(req.auth?.payload.sub ?? "");
    const notifications: PaginatedList<Notification> = await getNotifications({
      ...filterParams,
      userId: userUuid,
    });

    res.status(200).json(notifications);
  },
);

/**
 * @route PATCH /notifications/:id/read
 * @description Marks a specific notification as read for the authenticated user.
 * Users can only mark their own notifications as read.
 *
 * @param {string} req.params.id - The UUID of the notification to mark as read.
 * @param {Request} req - Express request object.
 * @param {Response} res - Express response object.
 * @returns {Response} 204 - If the notification was successfully marked as read.
 * @returns {Response} 401 - If the user is not authenticated.
 * @returns {Response} 403 - If the user does not own the notification.
 * @returns {Response} 404 - If the notification is not found.
 */
notificationRouter.patch(
  "/:id/read",
  requireAuth,
  async (req: Request, res: Response): Promise<void> => {
    const userUuid = await getUuidFromAuth0Id(req.auth?.payload.sub ?? "");
    const notificationId = validateUuidParam(req.params.id);

    const notification =
      (await getNotifications({ id: notificationId })).items[0] ?? undefined;

    // Check presence
    if (!notification || Object.keys(notification).length === 0) {
      const problemDetails: ProblemDetails = {
        title: "Not Found",
        status: 404,
        detail: `Notification with id '${notificationId}' was not found`,
      };
      res.status(problemDetails.status).json(problemDetails);
      return;
    }

    // Check ownership
    if (notification.userId !== userUuid) {
      const problemDetails: ProblemDetails = {
        title: "Permission Denied",
        status: 403,
        detail: "You do not have permission to access this resource",
      };
      res.status(problemDetails.status).json(problemDetails);
      return;
    }

    await markNotificationAsRead(notificationId);
    res.status(204).send();

    return;
  },
);

/**
 * @route DELETE /notifications/:id
 * @description Deletes a specific notification.
 * Users can only delete their own notifications.
 *
 * @param {string} req.params.id - The UUID of the notification to delete.
 * @param {Request} req - Express request object.
 * @param {Response} res - Express response object.
 * @returns {Response} 204 - If the notification was successfully deleted.
 * @returns {Response} 401 - If the user is not authenticated.
 * @returns {Response} 404 - If the notification is not found.
 */
notificationRouter.delete(
  "/:id",
  requireAuth,
  async (req: Request, res: Response): Promise<void> => {
    const notificationId = validateUuidParam(req.params.id);
    const deleteResult: boolean = await deleteNotification(notificationId);

    if (!deleteResult) {
      const problemDetails: ProblemDetails = {
        title: "Not Found",
        status: 404,
        detail: `Notification with id '${notificationId}' was not found`,
      };
      res.status(problemDetails.status).json(problemDetails);
      return;
    }
    res.status(204).send();
  },
);
