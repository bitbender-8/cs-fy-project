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
  }
);

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
  }
);

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
  }
);
