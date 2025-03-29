import { randomUUID, UUID } from "crypto";
import pg from "pg";

import { query } from "../db.js";
import { AppError } from "../errors/error.types.js";
import {
  LockedUserFields,
  Recipient,
  SocialMediaHandle,
} from "../models/user.model.js";
import { RecipientFilterParams } from "../models/filters/recipient-filters.js";
import { excludeProperties, PaginatedList } from "../utils/utils.js";
import { config } from "../config.js";
import { buildUpdateQueryData } from "./repo-utils.js";

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

export async function getRecipients(
  filterParams: RecipientFilterParams & { id?: UUID }
): Promise<PaginatedList<Recipient>> {
  let queryString = `
    SELECT 
      "id",
      "auth0UserId",
      "firstName",
      "middleName",
      "lastName",
      "dateOfBirth",
      "email",
      "phoneNo",
      "bio",
      "profilePictureUrl"
    FROM
      "Recipient"
  `;

  const limit = filterParams.limit ?? config.PAGE_SIZE;
  const pageNo = filterParams.page || 1;
  const whereClauses: string[] = [];
  const values: unknown[] = [];
  let paramIndex = 1;

  if (filterParams.id) {
    whereClauses.push(`"id" = $${paramIndex}`);
    values.push(filterParams.id);
    paramIndex++;
  }

  if (filterParams.name) {
    whereClauses.push(`
    (
      "firstName" ILIKE '%' || $${paramIndex} || '%' OR 
      "middleName" ILIKE '%' || $${paramIndex} || '%' OR 
      "lastName" ILIKE '%' || $${paramIndex} || '%'
    )`);
    values.push(filterParams.name);
    paramIndex++;
  }

  if (filterParams.email) {
    whereClauses.push(`"email" ILIKE '%' || $${paramIndex} || '%'`);
    values.push(filterParams.email);
    paramIndex++;
  }

  if (filterParams.phoneNo) {
    whereClauses.push(`"phoneNo" ILIKE '%' || $${paramIndex} || '%'`);
    values.push(filterParams.phoneNo);
    paramIndex++;
  }

  const dateFilters = {
    dateOfBirth: ["minBirthDate", "maxBirthDate"],
  } as const;

  for (const dateField in dateFilters) {
    const [minParam, maxParam] =
      dateFilters[dateField as keyof typeof dateFilters];

    if (filterParams[minParam]) {
      whereClauses.push(`"${dateField}" >= $${paramIndex}`);
      values.push(filterParams[minParam]);
      paramIndex++;
    }
    if (filterParams[maxParam]) {
      whereClauses.push(`"${dateField}" <= $${paramIndex}`);
      values.push(filterParams[maxParam]);
      paramIndex++;
    }
  }

  const whereClause =
    whereClauses.length > 0 ? ` WHERE ${whereClauses.join(" AND ")}` : "";

  const countResult = await query(
    `SELECT COUNT(*) FROM "Recipient"${whereClause}`,
    values
  );
  const totalRecords = parseInt(countResult.rows[0].count, 10);
  const totalPages = Math.ceil(totalRecords / limit);

  queryString += whereClause;
  queryString += `
        ORDER BY
            "firstName" ASC
        LIMIT
            $${paramIndex}
        OFFSET
            ($${paramIndex + 1} - 1) * $${paramIndex}
    `;
  values.push(limit, pageNo);

  const recipients: Recipient[] = await Promise.all(
    (await query<Recipient>(queryString, values)).rows.map(
      async (recipient) => {
        return {
          ...recipient,
          socialMediaHandles: await getSocialMediaHandles(recipient.id as UUID),
        };
      }
    )
  );

  return {
    items: recipients ?? [],
    pageCount: totalPages === 0 ? 1 : totalPages,
    pageNo: pageNo,
  };
}

export async function insertRecipient(
  recipient: Recipient
): Promise<Recipient> {
  try {
    const result = await query(
      ` INSERT INTO "Recipient" (
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
        const insertedHandle = await insertSocialMediaHandle({
          recipientId: recipient.id as UUID,
          socialMediaHandle: handle.socialMediaHandle,
        });

        insertedRecipient.socialMediaHandles.push(insertedHandle);
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
            "Phone number is already in use by another recipient",
            error.message
          );
        } else if (error.constraint === "Recipient_auth0UserId_key") {
          throw new AppError(
            "Validation Failure",
            409,
            "Auth0 authentication ID is already in use by another recipient",
            error.message
          );
        } else if (error.constraint === "Recipient_email_key") {
          throw new AppError(
            "Validation Failure",
            409,
            "Email is already in use by another recipient"
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

export async function updateRecipient(
  recipientId: UUID,
  recipient: Omit<Recipient, LockedUserFields>
): Promise<Recipient> {
  try {
    const { fragments, values: updateValues } = buildUpdateQueryData(
      excludeProperties(recipient, ["socialMediaHandles", "id"])
    );

    if (fragments.length === 0) {
      throw new AppError(
        "Validation Failure",
        400,
        "Recipient body cannot be empty"
      );
    }

    const updateQuery = `
      UPDATE "Recipient"
      SET 
        ${fragments.join(", ")}
      WHERE
        "id" = $${updateValues.length + 1}
      RETURNING *
    `;

    updateValues.push(recipientId);
    const result = await query(updateQuery, updateValues);

    if (!result || result.rows.length === 0) {
      throw new AppError(
        "Not Found",
        404,
        "Recipient not found",
        "A recipient with the given ID does not exist"
      );
    }

    const updatedRecipient = result.rows[0] as Recipient;
    updatedRecipient.socialMediaHandles = [];

    if (
      recipient.socialMediaHandles &&
      recipient.socialMediaHandles.length > 0
    ) {
      for (const handle of recipient.socialMediaHandles) {
        // If the socialMediaHandle object has an id this means that the query is an update, otherwise it is an insert
        if (handle.id) {
          const updatedHandle = await updateSocialMediaHandle({
            id: handle.id,
            recipientId,
            socialMediaHandle: handle.socialMediaHandle,
          });
          updatedRecipient.socialMediaHandles.push(updatedHandle);
        } else {
          const insertedHandle = await insertSocialMediaHandle({
            recipientId,
            socialMediaHandle: handle.socialMediaHandle,
          });
          updatedRecipient.socialMediaHandles.push(insertedHandle);
        }
      }
    } else {
      updatedRecipient.socialMediaHandles =
        await getSocialMediaHandles(recipientId);
    }

    return updatedRecipient;
  } catch (error: unknown) {
    if (!(error instanceof pg.DatabaseError)) {
      throw error;
    }

    switch (error.code) {
      case "23505":
        if (error.constraint === "Recipient_phoneNo_key") {
          throw new AppError(
            "Validation Failure",
            409,
            "Phone number is already in use by another recipient",
            error.message
          );
        } else if (error.constraint === "Recipient_auth0UserId_key") {
          throw new AppError(
            "Validation Failure",
            409,
            "Auth0 authentication ID is already in use by another recipient",
            error.message
          );
        } else if (error.constraint === "Recipient_email_key") {
          throw new AppError(
            "Validation Failure",
            409,
            "Email is already in use by another recipient",
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

async function getSocialMediaHandles(
  recipientId: UUID
): Promise<SocialMediaHandle[]> {
  const result = await query(
    `SELECT * FROM "RecipientSocialMediaHandle" WHERE "recipientId" = $1`,
    [recipientId]
  );
  return result.rows as SocialMediaHandle[];
}

async function updateSocialMediaHandle(
  handle: Required<SocialMediaHandle>
): Promise<SocialMediaHandle> {
  const result = await query<SocialMediaHandle>(
    `UPDATE "RecipientSocialMediaHandle"
       SET "socialMediaHandle" = $3
       WHERE "id" = $1 AND "recipientId" = $2
       RETURNING *`,
    [handle.id, handle.recipientId, handle.socialMediaHandle]
  );

  if (!result || result.rows.length === 0) {
    throw new AppError(
      "Internal Server Error",
      500,
      "Something went wrong",
      "Failed to update recipient's social handle"
    );
  }

  return result.rows[0];
}

async function insertSocialMediaHandle(
  handle: Omit<SocialMediaHandle, "id">
): Promise<SocialMediaHandle> {
  const result = await query<SocialMediaHandle>(
    `INSERT INTO "RecipientSocialMediaHandle" (
       "id",
       "recipientId",
       "socialMediaHandle"
     ) VALUES (
       $1, $2, $3
     ) RETURNING *`,
    [randomUUID(), handle.recipientId, handle.socialMediaHandle]
  );

  if (!result || result.rows.length === 0) {
    throw new AppError(
      "Internal Server Error",
      500,
      "Something went wrong",
      "Failed to insert recipient's social handle"
    );
  }

  return result.rows[0];
}
