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

// A user can't update their email or phone number. This is because we have to update the auth0 entry as well. We will add it later if we have to. This Removes non-updateable fields from the recipient schema
const updateableSupervisorSchema: AnyZodObject = SupervisorSchema.omit(
  LOCKED_USER_FIELDS.reduce((acc, field) => ({ ...acc, [field]: true }), {}) // Add {} as initial value
);

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
      req.auth?.payload.sub ?? ""
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
  }
);

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
  }
);
