import { Router, Request, Response } from "express";
import { AnyZodObject } from "zod";

import { requireAuth } from "../middleware/auth.middleware.js";
import { validateUuidParam } from "../utils/utils.js";
import { getUserRole } from "../services/user.service.js";
import { ProblemDetails } from "../errors/error.types.js";
import {
  getSupervisors,
  getUuidFromAuth0Id,
  updateSupervisor,
} from "../repositories/user.repo.js";
import {
  LOCKED_USER_FIELDS,
  LockedUserFields,
  Supervisor,
  SupervisorSchema,
} from "../models/user.model.js";
import { validateRequestBody } from "../middleware/request-body.middleware.js";

export const supervisorRouter: Router = Router();

/**
 * @const updateableSupervisorSchema
 * @description Zod schema for validating supervisor update requests.
 * It omits fields that are locked and cannot be updated directly by the user,
 * such as `id`, `auth0UserId`, `email`, and `phoneNumber`.
 * Email and phone number updates would require corresponding changes in Auth0,
 * which are not handled by this schema directly.
 */
const updateableSupervisorSchema: AnyZodObject = SupervisorSchema.omit(
  LOCKED_USER_FIELDS.reduce((acc, field) => ({ ...acc, [field]: true }), {}), // Add {} as initial value
);

/**
 * @route PUT /supervisors/:id
 * @description Updates an existing supervisor profile.
 * Only authenticated supervisors can update their own profiles.
 *
 * @param {string} req.params.id - The UUID of the supervisor to update.
 * @param {Request} req - Express request object. Expects supervisor update data in `req.body` (conforming to `updateableSupervisorSchema`).
 * @param {Response} res - Express response object.
 * @returns {Response} 204 - If the supervisor was successfully updated.
 * @returns {Response} 401 - If the user is not authenticated.
 * @returns {Response} 403 - If the user is not a supervisor or does not own the profile being updated.
 * @returns {Response} 404 - If the supervisor with the given ID is not found.
 */
supervisorRouter.put(
  "/:id",
  requireAuth,
  validateRequestBody(updateableSupervisorSchema),
  async (req: Request, res: Response): Promise<void> => {
    if (getUserRole(req.auth) !== "Supervisor") {
      const problemDetails: ProblemDetails = {
        title: "Permission Denied",
        status: 403,
        detail: "You do not have permission to access this resource",
      };
      res.status(problemDetails.status).json(problemDetails);
      return;
    }

    const supervisorId = validateUuidParam(req.params.id);
    const checkSupervisor = (await getSupervisors({ id: supervisorId }))
      .items[0];
    if (!checkSupervisor || Object.keys(checkSupervisor).length === 0) {
      const problemDetails: ProblemDetails = {
        title: "Not Found",
        status: 404,
        detail: `Supervisor with id ${supervisorId} was not found.`,
      };
      res.status(problemDetails.status).json(problemDetails);
      return;
    }

    const supervisor: Omit<Supervisor, LockedUserFields> = req.body;
    const supervisorIdFromJwt = await getUuidFromAuth0Id(
      req.auth?.payload.sub ?? "",
    );

    // Check that the authenticated supervisor owns the data they are trying to modify
    if (supervisorId !== supervisorIdFromJwt) {
      const problemDetails: ProblemDetails = {
        title: "Permission Denied",
        status: 403,
        detail: "You do not have permission to update this supervisor",
      };
      res.status(problemDetails.status).json(problemDetails);
      return;
    }

    await updateSupervisor(supervisorId, supervisor);
    res.status(204).send();
    return;
  },
);

/**
 * @route GET /supervisors/:id
 * @description Retrieves a single supervisor by their ID.
 * Only authenticated supervisors can access supervisor profiles.
 *
 * @param {string} req.params.id - The UUID of the supervisor to retrieve.
 * @param {Request} req - Express request object.
 * @param {Response} res - Express response object.
 * @returns {Response} 200 - The supervisor object.
 * @returns {Response} 403 - If the user is not a supervisor.
 */
supervisorRouter.get(
  "/:id",
  requireAuth,
  async (req: Request, res: Response): Promise<void> => {
    if (getUserRole(req.auth) !== "Supervisor") {
      // Everyone else has no access
      const problemDetails: ProblemDetails = {
        title: "Permission Denied",
        status: 403,
        detail: "You do not have permission to access this resource",
      };
      res.status(problemDetails.status).json(problemDetails);
      return;
    }
    // Supervisors: Full access

    const supervisorId = validateUuidParam(req.params.id);
    const supervisor: Supervisor = (await getSupervisors({ id: supervisorId }))
      .items[0];
    res.status(200).json(supervisor);
  },
);
