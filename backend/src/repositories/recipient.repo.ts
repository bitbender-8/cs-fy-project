import { DatabaseError } from "pg";
import { Recipient } from "../models/user.model.js";
import { query } from "./db.js";
import {
  ConstraintViolationError,
  UniqueKeyConstraintError,
} from "../models/error-types.js";

// Throws errors, validate the schema beforehand.
export async function createRecipient(
  recipient: Recipient
): Promise<Recipient> {
  try {
    const insertionResult = await query(
      `INSERT INTO "Recipient" (
        id,
        firstName,
        middleName,
        lastName,
        dateOfBirth,
        email,
        phoneNo,
        passwordHash,
        bio,
        profilePictureUrl,
      )
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10) 
      RETURNING *
      `,
      [
        crypto.randomUUID(),
        recipient.firstName,
        recipient.middleName,
        recipient.lastName,
        recipient.dateOfBirth,
        recipient.email,
        recipient.phoneNo,
        recipient.passwordHash,
        recipient.bio,
        recipient.profilePictureUrl,
      ]
    );

    if (!insertionResult || insertionResult.rows.length === 0) {
      throw new Error("Recipient insertion failed.");
    }

    const createdRecipient = insertionResult.rows[0] as Recipient;

    // Insert social media handles if they exist
    if (
      recipient.socialMediaHandles &&
      recipient.socialMediaHandles.length > 0
    ) {
      createdRecipient.socialMediaHandles = [];

      for (const handle of recipient.socialMediaHandles) {
        const insertedHandle = await query(
          `INSERT INTO "RecipientSocialMediaHandles" (
              id,
              socialMediaHandle,
              recipientId
           ) VALUES ($1, $2, $3) RETURNING *
          `,
          [crypto.randomUUID(), handle.socialMediaHandle, createdRecipient.id]
        );

        if (!insertedHandle || insertedHandle.rows.length === 0) {
          throw new Error("Failed to add recipient's social handles.");
        }

        createdRecipient.socialMediaHandles.push(insertedHandle.rows[0]);
      }
    }

    return createdRecipient;
  } catch (error: unknown) {
    if (error instanceof DatabaseError) {
      switch (error.code) {
        case "23505": // Unique constraint violation
          if (error.constraint === "recipientPhoneNoUK") {
            throw new UniqueKeyConstraintError(
              "Phone number provided has already been used by another account.",
              "phoneNo"
            );
          } else {
            throw new Error(error.message);
          }
        case "23503": // Foreign key constraint violation
          throw new Error(error.message);
        default:
          throw new Error(error.message);
      }
    } else if (error instanceof ConstraintViolationError) {
      throw error;
    } else {
      throw new Error("An unexpected error occurred.");
    }
  }
}
