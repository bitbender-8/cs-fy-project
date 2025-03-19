import { faker } from "@faker-js/faker";
import { randomUUID } from "crypto";

import { query } from "./db.js";
import { Recipient } from "../models/user.model.js";

// You have to creae these manually in the auth0 dashboard, and assign them their roles
const auth0RecipientIds = [
  "auth0|67d983c50f7916d942e2514f",
  "auth0|67d983749ae3ba0e60ed1597",
  "auth0|67d9835f77a6532deb96364d",
  "auth0|67d983426b97b76f336bed56",
  "auth0|67da6cdc404de3d21ed70c88",
  "auth0|67da6d005a52ee8008cbe671",
];

// You have to creae these manually in the auth0 dashboard, and assign them their roles
const auth0SupervisorIds = [
  "auth0|67d69ed056c40acd60ab91d4",
  "auth0|67da6d1c3a675923873af94b",
  "auth0|67da6d7d5a52ee8008cbe67f",
  "auth0|67da6df15e3f387facab43fe",
];

void auth0SupervisorIds;

function generateRecipients(auth0RecipientIds: string[]): Recipient[] {
  const recipients: Recipient[] = [];

  for (const auth0UserId of auth0RecipientIds) {
    const recipient: Recipient = {
      id: randomUUID(),
      auth0UserId,
      firstName: faker.person.firstName(),
      middleName: faker.person.middleName(),
      lastName: faker.person.lastName(),
      dateOfBirth: faker.date
        .past({ years: 30, refDate: new Date() })
        .toISOString()
        .split("T")[0],
      email: Math.random() >= 0.5 ? faker.internet.email() : undefined,
      phoneNo: faker.phone.number({ style: "international" }),
      bio: faker.lorem.sentence(),
      profilePictureUrl:
        Math.random() >= 0.5 ? faker.image.avatar() : undefined,
    };

    recipients.push(recipient);
  }

  return recipients;
}

async function seedRecipients(recipients: Recipient[]): Promise<void> {
  const recipientQueryString = `
    INSERT INTO "Recipient" (
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
    ) VALUES (
      $1, $2, $3, $4, $5, $6, $7, $8, $9, $10
    )
  `;

  for (const recipient of recipients) {
    await query(recipientQueryString, [
      recipient.id,
      recipient.auth0UserId,
      recipient.firstName,
      recipient.middleName,
      recipient.lastName,
      recipient.dateOfBirth,
      recipient.email,
      recipient.phoneNo,
      recipient.bio,
      recipient.profilePictureUrl,
    ]);
  }
}

seedRecipients(generateRecipients(auth0RecipientIds));

// CONTINUE (@bitbender-8): Write seeding scripts the rest of the db tables.
