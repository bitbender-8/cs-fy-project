import { UUID } from "crypto";
import pg from "pg";

import { query } from "../db.js";
import { AppError } from "../errors/error.types.js";
import { Recipient } from "../models/user.model.js";

/**
 * Retrieves the UUID of a user (either Recipient or Supervisor) based on their Auth0 ID.
 *
 * This function queries the "Recipient" and "Supervisor" tables to find a user with the given Auth0 ID.
 * It returns the user's UUID if found, or throws an AppError if the user is not found or if a database error occurs.
 *
 * @param auth0UserId - The Auth0 ID of the user.
 * @returns The UUID of the user, or throws an AppError.
 * @throws AppError - If the user is not found or if a database error occurs.
 *
 */
export async function getUuidFromAuth0Id(auth0UserId: string): Promise<UUID> {
  const queryString = `
    SELECT "id" FROM "Recipient" WHERE "auth0UserId" = $1
    UNION
    SELECT "id" FROM "Supervisor" WHERE "auth0UserId" = $1
  `;

  const values = [auth0UserId];
  const result = await query(queryString, values);

  if (result.rows.length > 0) {
    return result.rows[0].id as UUID;
  } else {
    throw new AppError(
      "Not Found",
      404,
      "User not found.",
      "User with the provided Auth0 ID not found in the database."
    );
  }
}

export async function insertRecipient(
  recipient: Recipient
): Promise<Recipient> {
  try {
    const result = await query(
      `
        INSERT INTO "Recipient" (
          "id",
          "firstName",
          "middleName",
          "lastName",
          "dateOfBirth",
          "email",
          "phoneNo",
          "auth0UserId",
          "bio",
          "profilePictureUrl"
        ) VALUES (
          $1, $2, $3, $4, $5, $6, $7, $8, $9, $10
        ) RETURNING *
      `,
      [
        crypto.randomUUID(),
        recipient.firstName,
        recipient.middleName,
        recipient.lastName,
        recipient.dateOfBirth,
        recipient.email,
        recipient.phoneNo,
        recipient.auth0UserId,
        recipient.bio,
        recipient.profilePictureUrl,
      ]
    );

    if (!result || result.rows.length === 0) {
      throw new AppError(
        "Internal Server Error",
        500,
        "Something went wrong",
        "Recipient insertion failed."
      );
    }

    const insertedRecipient = result.rows[0] as Recipient;

    // Insert social media handles if they exist
    if (
      recipient.socialMediaHandles &&
      recipient.socialMediaHandles.length > 0
    ) {
      insertedRecipient.socialMediaHandles = [];

      for (const handle of recipient.socialMediaHandles) {
        const insertedHandle = await query(
          `
            INSERT INTO "RecipientSocialMediaHandle" (
              "id",
              "recipientId",
              "socialMediaHandle"
            ) VALUES (
              $1, $2, $3 
            ) RETURNING *
          `,
          [crypto.randomUUID(), insertedRecipient.id, handle.socialMediaHandle]
        );

        if (!insertedHandle || insertedHandle.rows.length === 0) {
          throw new AppError(
            "Internal Server Error",
            500,
            "Something went wrong",
            "Failed to insert recipient's social handles"
          );
        }

        insertedRecipient.socialMediaHandles.push(insertedHandle.rows[0]);
      }
    }

    return insertedRecipient;
  } catch (error: unknown) {
    if (!(error instanceof pg.DatabaseError)) {
      throw error;
    }

    // recipient phone no unique
    // recipient auth0userid unique
    // recipientId foreign key does not exist
    switch (error.code) {
      case "23505":
        if (error.constraint === "Recipient_phoneNo_key") {
          throw new AppError(
            "Validation Failure",
            409,
            "Phone number has already been used by another user",
            error.message
          );
        } else if (error.constraint === "Recipient_auth0UserId_key") {
          throw new AppError(
            "Validation Failure",
            409,
            "Auth0 authentication ID is already in use by another user",
            error.message
          );
        }
        throw error;
      case "23503":
        if (
          error.constraint === "RecipientSocialMediaHandle_recipientId_fkey"
        ) {
          throw new AppError(
            "Internal Server Error",
            500,
            "Something went wrong",
            `The recipient ID specified in the social media handle does not exist. Message: ${error.message}`
          );
        }
        throw error;
      default:
        throw error;
    }
  }
}
