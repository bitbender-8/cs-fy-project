import { Router, Request, Response } from "express";
import { RecipientDto } from "../models/dtos.js";
import multer, { Multer } from "multer";
import { Recipient } from "../models/user.model.js";
import { createRecipient } from "../repositories/recipient.repo.js";
import * as argon2 from "argon2";
import {
  ProblemDetails,
  UniqueKeyConstraintError,
} from "../models/error-types.js";
import { recipientDtoSchema } from "../models/zod-schemas.js";

const recipientRouter: Router = Router();
const uploads: Multer = multer({ dest: process.env.UPLOAD_DIR });

// TODO Implement login route
// TODO Implement logout route

// TODO Implement create recipient route
recipientRouter.post(
  "/",
  uploads.single("profilePicture"),
  async (req: Request, res: Response) => {
    const profilePicture = req.file;
    try {
      // Validate recipient
      const result = recipientDtoSchema.safeParse(req.body);
      if (!result.success) {
        const errorResponse: ProblemDetails = {
          title: "Validation Error",
          status: 400,
          detail: "One or more recipient details are invalid",
          fieldErrors: result.error.issues.map((issue) => ({
            field: issue.path.join("."),
            message: issue.message,
          })),
        };
        res.status(400).json(errorResponse);
        return;
      }

      // Hash password and Compute profile pic location
      const recipientData: RecipientDto = result.data;
      const newRecipient: Recipient = {
        ...recipientData,
        dateOfBirth: new Date(recipientData.dateOfBirth),
        profilePictureUrl: profilePicture
          ? `${process.env.UPLOAD_DIR}/${req?.file?.filename}`
          : undefined,
        passwordHash: await argon2.hash(recipientData.password),
      };

      // Create recipient and respond appropriately
      const createdRecipient = await createRecipient(newRecipient);
      res.set(
        "Location",
        `${req.protocol}://${req.get("host")}/recipients/${createdRecipient.id}`
      );
      res.status(201).json(createdRecipient);
    } catch (error) {
      if (error instanceof UniqueKeyConstraintError) {
        const errorResponse: ProblemDetails = {
          title: "Validation Error",
          status: 409,
          detail: error.uiMessage,
        };
        res.status(409).json(errorResponse);
      } else {
        const errorResponse: ProblemDetails = {
          title: "Internal Server Error",
          status: 500,
          detail: "An unexpected error occurred.",
        };
        res.status(500).json(errorResponse);
      }
    }
  }
);

// TODO Implement get recipient profile route
// TODO Implement update AUTHENTICATED recipient route
// TODO Implement delete AUTHENTICATED recipient route

export default recipientRouter;
