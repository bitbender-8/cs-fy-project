import { Router, Request, Response } from "express";
import * as argon2 from "argon2";
import { UUID } from "crypto";

import { Recipient } from "../models/user.model.js";
import {
  createRecipient,
  getRecipientById,
} from "../repositories/recipient.repo.js";
import {
  ProblemDetails,
  UniqueKeyConstraintError,
} from "../models/error-types.js";
import { createRecipientDtoSchema } from "../models/zod-schemas.js";
import { validatedFileUpload } from "../middleware.js";
import z from "zod";
import { RecipientDto } from "../models/dtos.js";

// Helper types
const recipientRouter: Router = Router();

// TODO Add phoneNo verification using a provider like Twilio.
recipientRouter.post(
  "/",
  await validatedFileUpload("profilePicture"),
  async (req: Request, res: Response) => {
    const profilePicture = req.file;
    try {
      // Validate recipient
      const result = createRecipientDtoSchema.safeParse(req.body);
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

      // Add password and confirmation fields to data transfer object
      const recipientData: RecipientDto & {
        password: string;
        passwordConfirmation: string;
      } = {
        ...result.data,
        id: result.data?.id as UUID,
        socialMediaHandles: result.data?.socialMediaHandles?.map((handle) => ({
          ...handle, // Spread existing properties of each socialMediaHandle
          id: handle.id as UUID,
        })),
      };

      // Hash password and Compute profile pic location
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
        `${req.protocol}://${req.get("host")}/recipients/${createdRecipient.id}`,
      );
      res.status(201).json(createdRecipient);
    } catch (error) {
      console.error(error);
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
  },
);

// TODO Hide fields conditionally based on authentication of user.
recipientRouter.get("/:id", async (req: Request, res: Response) => {
  const recipientId = req.params.id;

  if (!recipientId || !z.string().uuid().safeParse(recipientId).success) {
    const errorResponse: ProblemDetails = {
      title: "Bad Request",
      status: 400,
      detail: "Recipient ID is invalid or missing.",
    };
    res.status(400).json(errorResponse);
    return;
  }

  try {
    const recipient: RecipientDto | null = await getRecipientById(
      recipientId as UUID,
    );

    if (!recipient) {
      const errorResponse: ProblemDetails = {
        title: "Not Found",
        status: 404,
        detail: "Recipient not found.",
      };
      res.status(404).json(errorResponse);
      return;
    }
    res.status(200).json(recipient);
  } catch (error) {
    console.error(error);
    const errorResponse: ProblemDetails = {
      title: "Internal Server Error",
      status: 500,
      detail: "An unexpected error occurred.",
    };
    res.status(500).json(errorResponse);
  }
});

// TODO Implement login route
// TODO Implement logout route
// TODO Implement update AUTHENTICATED recipient route
// TODO Implement delete AUTHENTICATED recipient route

export default recipientRouter;
