import { Router, Request, Response } from "express";
import { validateFileUpload } from "../middleware/file-upload.middleware.js";
import { Recipient, RecipientSchema } from "../models/user.model.js";
import { ProblemDetails } from "../errors/error.types.js";

const recipientRouter: Router = Router();

recipientRouter.post(
  "/",
  await validateFileUpload("profilePicture"),
  async (req: Request, res: Response) => {
    const profilePicture = req.file;

    // Validate recipient data
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
    const verificationResult = verifyRecipientUserId(recipient.auth0UserId)
  }
);
