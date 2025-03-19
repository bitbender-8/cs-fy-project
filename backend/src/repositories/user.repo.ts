import { UUID } from "crypto";
import { query } from "./db.js";

export async function getUuidFromAuth0Id(
  auth0Id: string
): Promise<UUID | null> {
  const recipientQueryString = `
        SELECT
            "id"
        FROM
            "Recipient"
        WHERE
            "auth0UserId" = $1
    `;

  const supervisorQueryString = `
        SELECT
            "id"
        FROM
            "Supervisor"
        WHERE
            "auth0UserId" = $1
    `;
  const values = [auth0Id];
  const supervisorId: UUID = (await query(supervisorQueryString, values))
    .rows[0];
  const recipientId: UUID = (await query(recipientQueryString, values)).rows[0];

  return supervisorId ?? recipientId ?? null;
}
