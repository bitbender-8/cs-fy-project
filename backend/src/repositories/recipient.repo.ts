import pg from "pg";
import { query } from "./db.js";
import { UUID } from "crypto";

import { Recipient, SocialMediaHandle } from "../models/user.model.js";
import { UniqueKeyConstraintError } from "../models/error-types.js";
import { RecipientDto } from "../models/dtos.js";

/**
 * Throws errors, validate the schema beforehand (except for unique and fk constrinat violations).
 */
export async function createRecipient(
  recipient: Recipient,
): Promise<RecipientDto> {
  try {
    const insertionResult = await query<RecipientDto>(
      `INSERT INTO "Recipient" (
        "id",
        "firstName",
        "middleName",
        "lastName",
        "dateOfBirth",
        "email",
        "phoneNo",
        "passwordHash",
        "bio",
        "profilePictureUrl"
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
      ],
    );

    if (!insertionResult || insertionResult.rows.length === 0) {
      throw new Error("Recipient insertion failed.");
    }

    const createdRecipient = insertionResult.rows[0] as RecipientDto;

    // Insert social media handles if they exist
    if (
      recipient.socialMediaHandles &&
      recipient.socialMediaHandles.length > 0
    ) {
      createdRecipient.socialMediaHandles = [];

      for (const handle of recipient.socialMediaHandles) {
        const insertedHandle = await query(
          `INSERT INTO "RecipientSocialMediaHandle" (
              "id",
              "socialMediaHandle",
              "recipientId"
           ) VALUES ($1, $2, $3) RETURNING *
          `,
          [crypto.randomUUID(), handle.socialMediaHandle, createdRecipient.id],
        );

        if (!insertedHandle || insertedHandle.rows.length === 0) {
          throw new Error("Failed to add recipient's social handles.");
        }

        createdRecipient.socialMediaHandles.push(insertedHandle.rows[0]);
      }
    }

    return createdRecipient;
  } catch (error: unknown) {
    if (error instanceof pg.DatabaseError) {
      // Uses the default constraint names in postgres to detect constraint violations. These are described [here](http://stackoverflow.com/questions/4107915/ddg#4108266).

      if (
        error.code === "23505" &&
        error.constraint === "Recipient_phoneNo_key"
      ) {
        throw new UniqueKeyConstraintError(
          "Phone number provided has already been used by another account.",
          "phoneNo",
        );
      }
      throw error;
    } else {
      throw error;
    }
  }
}

// throws errors, validate recipientId before hand.

export async function getRecipientById(
  recipientId: UUID,
): Promise<RecipientDto | null> {
  try {
    const recipientResult = await query(
      `SELECT * FROM "Recipient" WHERE id = $1`,
      [recipientId],
    );

    if (!recipientResult || recipientResult.rows.length === 0) {
      return null;
    }

    const recipient = recipientResult.rows[0];

    const socialMediaResult = await query<SocialMediaHandle>(
      `SELECT * FROM "RecipientSocialMediaHandle" WHERE "recipientId" = $1`,
      [recipientId],
    );

    const recipientDto: RecipientDto = {
      id: recipient.id,
      firstName: recipient.firstName,
      middleName: recipient.middleName,
      lastName: recipient.lastName,
      dateOfBirth: new Date(recipient.dateOfBirth),
      email: recipient.email,
      phoneNo: recipient.phoneNo,
      profilePictureUrl: recipient.profilePictureUrl,
      bio: recipient.bio,
      socialMediaHandles: socialMediaResult.rows,
    };

    return recipientDto;
  } catch (error) {
    console.error("Error getting recipient by ID:", error);
    return null;
  }
}
