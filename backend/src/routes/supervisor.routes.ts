import { Router, Request, Response } from "express";
import { validateUuidParam } from "../utils/utils.js";
import { Supervisor } from "../models/user.model.js";
import { getUserRole, verifyAuthentication } from "../services/user.service.js";
import { getSupervisors } from "../repositories/user.repo.js";
import { ProblemDetails } from "../errors/error.types.js";

export const supervisorRouter: Router = Router();

supervisorRouter.get(
  "/:id",
  async (req: Request, res: Response): Promise<void> => {
    verifyAuthentication(req.auth);

    const supervisorId = validateUuidParam(req.params.id);
    let supervisor: Supervisor;

    if (getUserRole(req.auth) === "Supervisor") {
      // Supervisors: Full access
      supervisor = (await getSupervisors({ id: supervisorId })).items[0];
      res.status(200).json(supervisor);
    } else {
      // Everyone else has no access
      const problemDetails: ProblemDetails = {
        title: "Permission Denied",
        status: 403,
        detail: "You do not have permission to access this resource",
      };
      res.status(problemDetails.status).json(problemDetails);
      return;
    }
  }
);
