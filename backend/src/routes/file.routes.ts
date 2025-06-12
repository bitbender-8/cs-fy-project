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

/**
 * @route GET /files/campaign-documents/:filename
 * @description Serves a private campaign document file.
 * Access is restricted:
 * - Supervisors can access any campaign document.
 * - Recipients can only access documents belonging to campaigns they own.
 * The filename is expected to be the name of the file as stored on the server (e.g., a UUID with an extension).
 *
 * @param {string} req.params.filename - The name of the file to retrieve from the private upload directory.
 * @param {Request} req - Express request object.
 * @param {Response} res - Express response object.
 * @returns {Response} 200 - The requested file.
 * @returns {Response} 403 - If the user does not have permission to access the file.
 * @returns {Response} 404 - If the campaign associated with the document is not found, or the file itself is not found.
 */
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

/**
 * @route GET /files/public/:filename
 * @description Serves a public file (e.g., profile pictures, redacted campaign documents).
 * This route does not require authentication.
 * The filename is expected to be the name of the file as stored on the server.
 *
 * @param {string} req.params.filename - The name of the file to retrieve from the public upload directory.
 * @param {Request} req - Express request object.
 * @param {Response} res - Express response object.
 * @returns {Response} 200 - The requested file.
 * @returns {Response} 404 - If the file is not found (implicitly, as `getFiles` would return an empty map entry).
 */
fileRouter.get("/public/:filename", async (req: Request, res: Response) => {
  const { filename } = req.params;
  const filePath = path.join(publicUploadDir, filename);
  const fileMap = await getFiles([filePath]);
  res.send(fileMap.get(filePath));
  return;
});
