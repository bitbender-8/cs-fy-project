import { UUID } from "crypto";
import { query } from "../db.js";
import { AppError } from "../errors/error.types.js";

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
