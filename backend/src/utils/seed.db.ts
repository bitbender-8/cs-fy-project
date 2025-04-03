import { query } from "../db.js";
import {
  Recipient,
  SocialMediaHandle,
  Supervisor,
} from "../models/user.model.js";
import { Notification } from "../models/notification.model.js";
import {
  Campaign,
  CampaignDonation,
  CampaignPost,
} from "../models/campaign.model.js";
import { fromMoneyStrToBigInt } from "./utils.js";
import {
  EndDateExtensionRequest,
  GoalAdjustmentRequest,
  PostUpdateRequest,
  StatusChangeRequest,
} from "../models/campaign-request.model.js";
import {
  generateCampaignDonations,
  generateCampaignPosts,
  generateCampaigns,
  generateEndDateExtensionRequests,
  generateGoalAdjustmentRequests,
  generateNotifications,
  generatePostUpdateRequests,
  generateRecipients,
  generateSocialHandles,
  generateStatusChangeRequests,
  generateSupervisors,
} from "./mock-generators.js";
import { exit } from "process";

// You have to creae these manually in the auth0 dashboard, and assign them their roles
const auth0RecipientIds = process.env.AUTH0_TEST_RECIPIENTS?.split(";");
const auth0SupervisorIds = process.env.AUTH0_TEST_SUPERVISORS?.split(";");

if (!auth0RecipientIds || !auth0SupervisorIds) {
  console.error("Failed to load auth0 test users.");
  process.exit(1);
}

if (auth0RecipientIds.length === 0) {
  console.error("Auth0 recipient IDs not provided.");
  process.exit(1);
}

if (auth0SupervisorIds.length === 0) {
  console.error("Auth0 supervisor IDs not provided.");
  process.exit(1);
}

async function seedRecipients(recipients: Recipient[]): Promise<void> {
  const queryString = `
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
    await query(queryString, [
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

async function seedSocialHandles(
  socialHandles: SocialMediaHandle[],
): Promise<void> {
  const queryString = `
    INSERT INTO "RecipientSocialMediaHandle" (
      "id",
      "recipientId",
      "socialMediaHandle"
    ) VALUES (
      $1, $2, $3
    )
  `;

  for (const socialHandle of socialHandles) {
    await query(queryString, [
      socialHandle.id,
      socialHandle.recipientId,
      socialHandle.socialMediaHandle,
    ]);
  }
}

async function seedSupervisors(supervisors: Supervisor[]): Promise<void> {
  const queryString = `
    INSERT INTO "Supervisor" (
      "id",
      "firstName",
      "middleName",
      "lastName",
      "dateOfBirth",
      "email",
      "phoneNo",
      "auth0UserId"
    ) VALUES (
      $1, $2, $3, $4, $5, $6, $7, $8
    )
  `;

  for (const supervisor of supervisors) {
    await query(queryString, [
      supervisor.id,
      supervisor.firstName,
      supervisor.middleName,
      supervisor.lastName,
      supervisor.dateOfBirth,
      supervisor.email,
      supervisor.phoneNo,
      supervisor.auth0UserId,
    ]);
  }
}

async function seedNotifications(notifications: Notification[]): Promise<void> {
  const queryString = `
    INSERT INTO "Notification" (
      "id",
      "subject",
      "body",
      "isRead",
      "createdAt",
      "recipientId",
      "supervisorId"
    ) VALUES (
      $1, $2, $3, $4, $5, $6, $7
    )
  `;

  for (const notification of notifications) {
    if ("supervisorId" in notification) {
      await query(queryString, [
        notification.id,
        notification.subject,
        notification.body,
        notification.isRead,
        notification.createdAt,
        null,
        notification.supervisorId,
      ]);
    } else {
      await query(queryString, [
        notification.id,
        notification.subject,
        notification.body,
        notification.isRead,
        notification.createdAt,
        notification.recipientId,
        null,
      ]);
    }
  }
}

async function seedCampaigns(campaigns: Campaign[]): Promise<void> {
  const queryString = `
    INSERT INTO "Campaign" (
      "id",
      "ownerRecipientId",
      "title",
      "description",
      "fundraisingGoal",
      "status",
      "category",
      "paymentMethod",
      "phoneNo",
      "bankAccountNo",
      "bankName",
      "submissionDate",
      "verificationDate",
      "denialDate",
      "launchDate",
      "endDate",
      "isPublic"
    ) VALUES (
       $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17
    )
  `;

  const docUrlQueryString = `
    INSERT INTO "CampaignDocuments" (
      "documentUrl",
      "redactedDocumentUrl",
      "campaignId"
    ) VALUES (
      $1, $2, $3
    )
  `;

  for (const campaign of campaigns) {
    await query(queryString, [
      campaign.id,
      campaign.ownerRecipientId,
      campaign.title,
      campaign.description,
      fromMoneyStrToBigInt(campaign.fundraisingGoal),
      campaign.status,
      campaign.category,
      campaign.paymentInfo?.paymentMethod,
      campaign.paymentInfo?.phoneNo,
      campaign.paymentInfo?.bankAccountNo,
      campaign.paymentInfo?.bankName,
      campaign.submissionDate,
      campaign.verificationDate,
      campaign.denialDate,
      campaign.launchDate,
      campaign.endDate,
      campaign.isPublic,
    ]);

    if (campaign.documents) {
      for (const document of campaign.documents) {
        await query(docUrlQueryString, [
          document.documentUrl,
          document.redactedDocumentUrl,
          campaign.id,
        ]);
      }
    }
  }
}

async function seedCampaignDonations(
  donations: CampaignDonation[],
): Promise<void> {
  const queryString = `
    INSERT INTO "CampaignDonation" (
      "id",
      "grossAmount",
      "serviceFee",
      "createdAt",
      "transactionRef",
      "campaignId"
    ) VALUES (
      $1, $2, $3, $4, $5, $6
    )
  `;

  for (const donation of donations) {
    await query(queryString, [
      donation.id,
      fromMoneyStrToBigInt(donation.grossAmount),
      fromMoneyStrToBigInt(donation.serviceFee),
      donation.createdAt,
      donation.transactionRef,
      donation.campaignId,
    ]);
  }
}

async function seedCampaignPosts(campaignPosts: CampaignPost[]): Promise<void> {
  const queryString = `
    INSERT INTO "CampaignPost" (
      "id",
      "title",
      "content",
      "publicPostDate",
      "campaignId"
    ) VALUES (
      $1, $2, $3, $4, $5
    )
  `;

  for (const post of campaignPosts) {
    await query(queryString, [
      post.id,
      post.title,
      post.content,
      post.publicPostDate ?? null,
      post.campaignId,
    ]);
  }
}

async function seedPostUpdateRequests(
  requests: PostUpdateRequest[],
): Promise<void> {
  const queryString = `
    INSERT INTO "PostUpdateRequest" (
      "id", 
      "title", 
      "requestDate",
      "justification", 
      "resolutionDate", 
      "campaignId", 
      "newPostId"
    ) VALUES ($1, $2, $3, $4, $5, $6, $7)
  `;

  for (const request of requests) {
    await query(queryString, [
      request.id,
      request.title,
      request.requestDate,
      request.justification,
      request.resolutionDate ?? null,
      request.campaignId,
      request.newPost.id,
    ]);
  }
}

async function seedEndDateExtensionRequests(
  requests: EndDateExtensionRequest[],
): Promise<void> {
  const queryString = `
    INSERT INTO "EndDateExtensionRequest" (
      "id", 
      "title", 
      "requestDate",
      "justification", 
      "resolutionDate", 
      "newEndDate", 
      "campaignId"
    ) VALUES ($1, $2, $3, $4, $5, $6, $7)
  `;

  for (const request of requests) {
    await query(queryString, [
      request.id,
      request.title,
      request.requestDate,
      request.justification,
      request.resolutionDate ?? null,
      request.newEndDate,
      request.campaignId,
    ]);
  }
}

async function seedGoalAdjustmentRequests(
  requests: GoalAdjustmentRequest[],
): Promise<void> {
  const queryString = `
    INSERT INTO "GoalAdjustmentRequest" (
      "id", 
      "title", 
      "requestDate",
      "justification", 
      "resolutionDate", 
      "newGoal", 
      "campaignId"
    ) VALUES ($1, $2, $3, $4, $5, $6, $7)
  `;

  for (const request of requests) {
    await query(queryString, [
      request.id,
      request.title,
      request.requestDate,
      request.justification,
      request.resolutionDate ?? null,
      typeof request.newGoal === "string"
        ? fromMoneyStrToBigInt(request.newGoal)
        : request.newGoal,
      request.campaignId,
    ]);
  }
}

async function seedStatusChangeRequests(
  requests: StatusChangeRequest[],
): Promise<void> {
  const queryString = `
    INSERT INTO "StatusChangeRequest" (
      "id", 
      "title", 
      "requestDate", 
      "justification", 
      "resolutionDate", 
      "newStatus", 
      "campaignId"
    ) VALUES ($1, $2, $3, $4, $5, $6, $7)
  `;

  for (const request of requests) {
    await query(queryString, [
      request.id,
      request.title,
      request.requestDate,
      request.justification,
      request.resolutionDate ?? null,
      request.newStatus,
      request.campaignId,
    ]);
  }
}

async function seedDatabase({
  clearTables,
  auth0RecipientIds,
  auth0SupervisorIds,
  avgDonationPerCampaign,
  avgPostPerCampaign,
  noOfRequestsPerRequestType,
  noOfNotifications,
  noOfCampaigns,
  noOfCampaignCategories = 5, // Default value for optional parameter
}: {
  clearTables: boolean;
  auth0RecipientIds: string[];
  auth0SupervisorIds: string[];
  avgDonationPerCampaign: number;
  avgPostPerCampaign: number;
  noOfRequestsPerRequestType: number;
  noOfNotifications: number;
  noOfCampaigns: number;
  noOfCampaignCategories?: number;
}): Promise<void> {
  // Clear tables if necessary
  if (clearTables) {
    await query(`
    DO $$
    DECLARE
        rec RECORD;
    BEGIN
        -- Loop through all tables in the public schema
        FOR rec IN
            SELECT tablename
            FROM pg_tables
            WHERE schemaname = 'public'
        LOOP
            EXECUTE 'TRUNCATE TABLE public.' || quote_ident(rec.tablename) || ' CASCADE;';
        END LOOP;
    END $$;
    `);
  }

  // Generate data
  const recipients = generateRecipients(auth0RecipientIds);
  const socialHandles = generateSocialHandles(recipients);
  const supervisors = generateSupervisors(auth0SupervisorIds);
  const notifications = generateNotifications(
    recipients,
    supervisors,
    noOfNotifications,
  );
  const campaigns = generateCampaigns(
    recipients,
    noOfCampaigns,
    noOfCampaignCategories,
  );
  const campaignDonations = generateCampaignDonations(
    campaigns,
    avgDonationPerCampaign,
  );
  const campaignPosts = generateCampaignPosts(campaigns, avgPostPerCampaign);
  const postUpdateRequests = generatePostUpdateRequests(
    campaigns,
    campaignPosts,
    noOfRequestsPerRequestType,
  );
  const endDateExtensionRequests = generateEndDateExtensionRequests(
    campaigns,
    noOfRequestsPerRequestType,
  );
  const goalAdjustmentRequests = generateGoalAdjustmentRequests(
    campaigns,
    noOfRequestsPerRequestType,
  );
  const statusChangeRequests = generateStatusChangeRequests(
    campaigns,
    noOfRequestsPerRequestType,
  );

  // Seed database
  console.log("Seeding database...");
  seedRecipients(recipients)
    .then(() => seedSocialHandles(socialHandles))
    .then(() => seedSupervisors(supervisors))
    .then(() => seedNotifications(notifications))
    .then(() => seedCampaigns(campaigns))
    .then(() => seedCampaignDonations(campaignDonations))
    .then(() => seedCampaignPosts(campaignPosts))
    .then(() => seedPostUpdateRequests(postUpdateRequests))
    .then(() => seedEndDateExtensionRequests(endDateExtensionRequests))
    .then(() => seedGoalAdjustmentRequests(goalAdjustmentRequests))
    .then(() => seedStatusChangeRequests(statusChangeRequests))
    .then(() => {
      console.log("Database seeding completed.");
      exit(0);
    })
    .catch((error) => console.error("Error seeding database: ", error));
}

seedDatabase({
  clearTables: true,
  auth0RecipientIds,
  auth0SupervisorIds,
  avgDonationPerCampaign: 5,
  avgPostPerCampaign: 4,
  noOfRequestsPerRequestType: 4,
  noOfNotifications: 15,
  noOfCampaigns: 25,
  noOfCampaignCategories: 6,
});
