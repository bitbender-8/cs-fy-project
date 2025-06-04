import { Router, Response, Request } from "express";
import fs from "fs/promises";
import path from "path";

import { requireAuth } from "../middleware/auth.middleware.js";
import { config } from "../config.js";
import { getUserRole } from "../services/user.service.js";
import { getUuidFromAuth0Id } from "../repositories/user.repo.js";
import {
  getCampaignDocuments,
  getCampaigns,
} from "../repositories/campaign.repo.js";
import { ProblemDetails } from "../errors/error.types.js";
import { getFiles } from "../services/fie.service.js";

export const fileRouter = Router();

const privateUploadDir = config.PRIVATE_UPLOAD_DIR;
const publicUploadDir = config.PUBLIC_UPLOAD_DIR;

// Ensure directories exist
fs.mkdir(privateUploadDir, { recursive: true }).catch(console.error);
fs.mkdir(publicUploadDir, { recursive: true }).catch(console.error);

// TODO: Add these routes to openapi.yml
fileRouter.get(
  "/campaign-documents/:filename",
  requireAuth,
  async (req: Request, res: Response): Promise<void> => {
    const { filename } = req.params;

    const filePath = path.join(privateUploadDir, filename);
    const userIdFromJwt = await getUuidFromAuth0Id(req.auth?.payload.sub ?? "");
    const document = (await getCampaignDocuments()).items.find(
      (doc) =>
        path.basename(doc.documentUrl) === filename ||
        path.basename(doc.redactedDocumentUrl ?? "") === filename
    );
    const campaign = (await getCampaigns({ id: document?.campaignId }))
      .items[0];

    if (!campaign) {
      const problemDetails: ProblemDetails = {
        title: "Validation Failure",
        status: 404,
        detail: "Could not find campaign associated with document",
      };
      res.send(problemDetails.status).json(problemDetails);
      return;
    }

    switch (getUserRole(req.auth)) {
      case "Supervisor":
        // Do nothing and allow access
        break;
      case "Recipient":
        if (campaign.ownerRecipientId !== userIdFromJwt) {
          const problemDetails: ProblemDetails = {
            title: "Permission Denied",
            status: 403,
            detail: "You do not have permission to access this resource",
          };
          res.status(problemDetails.status).json(problemDetails);
          return;
        }
        break;
      default: {
        const problemDetails: ProblemDetails = {
          title: "Permission Denied",
          status: 403,
          detail: "You do not have permission to access this resource",
        };
        res.status(problemDetails.status).json(problemDetails);
        return;
      }
    }

    const fileMap = await getFiles([filePath]);
    res.send(fileMap.get(filePath));
    return;
  }
);

fileRouter.get("/public/:filename", async (req: Request, res: Response) => {
  const { filename } = req.params;
  const filePath = path.join(publicUploadDir, filename);
  const fileMap = await getFiles([filePath]);
  res.send(fileMap.get(filePath));
  return;
});
