import { Router, Request, Response } from "express";
import { validateFileUpload } from "../middleware/file-upload.middleware.js";
import { Recipient, RecipientSchema } from "../models/user.model.js";
import { ProblemDetails } from "../errors/error.types.js";
import { verifyAuth0UserId } from "../services/user.service.js";
import { insertRecipient } from "../repositories/user.repo.js";

export const recipientRouter: Router = Router();

recipientRouter.post(
  "/",
  await validateFileUpload("profilePicture"),
  async (req: Request, res: Response) => {
    const profilePicture = req.file;

    // Validate recipient data
    if (!req.body) {
      const problemDetails: ProblemDetails = {
        title: "Validation Failure",
        status: 400,
        detail: "Recipient body cannot be empty",
      };
      res.status(problemDetails.status).json(problemDetails);
      return;
    }
    console.log(req.body);

    const parsedRecipient = RecipientSchema.safeParse(req.body);
    if (!parsedRecipient.success) {
      const problemDetails: ProblemDetails = {
        title: "Validation Failure",
        status: 400,
        detail: "One or more query params failed validation",
        fieldFailures: parsedRecipient.error.issues.map((issue) => ({
          field: issue.path.join("."),
          uiMessage: issue.message,
        })),
      };
      res.status(problemDetails.status).json(problemDetails);
      return;
    }

    // Verify the recipient's auth0 user ID
    const recipient = parsedRecipient.data as Recipient;
    const auth0User = await verifyAuth0UserId(recipient.auth0UserId as string);
    recipient.email = auth0User.email;
    recipient.profilePictureUrl = profilePicture
      ? `${process.env.UPLOAD_DIR}/${req?.file?.filename}`
      : undefined;

    // Store recipient in DB
    const insertedRecipient = await insertRecipient(recipient);
    res
      .set(
        "Location",
        `${req.protocol}://${req.get("host")}/recipients/${insertedRecipient.id}`
      )
      .status(201)
      .json(insertedRecipient);
  }
);
