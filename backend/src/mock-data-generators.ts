import { faker } from "@faker-js/faker";
import {
  Recipient,
  SocialMediaHandle,
  Supervisor,
} from "./models/user.model.js";
import { randomUUID, UUID } from "crypto";
import { Notification } from "./models/notification.model.js";
import {
  Campaign,
  CampaignDonation,
  CampaignPost,
} from "./models/campaign.model.js";
import { CAMPAIGN_STATUSES } from "./utils/zod-helpers.js";
import {
  EndDateExtensionRequest,
  GoalAdjustmentRequest,
  PostUpdateRequest,
  StatusChangeRequest,
} from "./models/campaign-request.model.js";

export function generateRecipients(auth0RecipientIds: string[]): Recipient[] {
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
      phoneNo: faker.phone.number({ style: "international" }),
      bio: faker.lorem.sentence(),
      profilePictureUrl:
        Math.random() >= 0.5 ? faker.image.avatar() : undefined,
    };

    if (Math.random() >= 0.5) {
      recipient.email = faker.internet.email({
        firstName: recipient.firstName,
        lastName: recipient.lastName,
      });
    }

    recipients.push(recipient);
  }

  return recipients;
}

export function generateSocialHandles(
  recipients: Recipient[],
): SocialMediaHandle[] {
  const socialHandles: SocialMediaHandle[] = [];

  for (const recipient of recipients) {
    if (Math.random() >= 0.5) {
      const socialMediaDomains = [
        "twitter.com",
        "facebook.com",
        "instagram.com",
        "tiktok.com",
      ];

      let socialHandle: SocialMediaHandle;

      if (recipient.id) {
        socialHandle = {
          id: randomUUID(),
          socialMediaHandle: `https://${faker.helpers.arrayElement(socialMediaDomains)}/${recipient.firstName}-${recipient.lastName}-${faker.word.adjective()}`,
          recipientId: recipient.id,
        };

        socialHandles.push(socialHandle);
      }
    }
  }

  return socialHandles;
}

export function generateSupervisors(
  auth0SupervisorIds: string[],
): Supervisor[] {
  const supervisors: Supervisor[] = [];

  for (const auth0UserId of auth0SupervisorIds) {
    const supervisor: Supervisor = {
      id: randomUUID(),
      auth0UserId,
      firstName: faker.person.firstName(),
      middleName: faker.person.middleName(),
      lastName: faker.person.lastName(),
      dateOfBirth: faker.date
        .past({ years: 30, refDate: new Date() })
        .toISOString()
        .split("T")[0],
      email: "",
      phoneNo: faker.phone.number({ style: "international" }),
    };

    supervisor.email = faker.internet.email({
      firstName: supervisor.firstName,
      lastName: supervisor.lastName,
    });

    supervisors.push(supervisor);
  }

  return supervisors;
}

export function generateNotifications(
  recipients: Recipient[],
  supervisors: Supervisor[],
  noOfNotifications: number,
): Notification[] {
  const notifications: Notification[] = [];

  for (let i = 0; i < noOfNotifications; i++) {
    let supervisorNotification: Notification | null = null,
      recipientNotification: Notification | null = null;

    if (Math.random() >= 0.5) {
      supervisorNotification = {
        id: randomUUID(),
        subject: faker.lorem.sentence({ min: 1, max: 2 }),
        body: faker.lorem.sentence({ min: 3, max: 5 }),
        isRead: faker.datatype.boolean(),
        timestamp: faker.date
          .past({ years: 30, refDate: new Date() })
          .toISOString(),
        supervisorId: faker.helpers.arrayElement(supervisors).id as UUID,
      };
    } else {
      recipientNotification = {
        id: randomUUID(),
        subject: faker.lorem.sentence({ min: 1, max: 2 }),
        body: faker.lorem.sentence({ min: 3, max: 5 }),
        isRead: faker.datatype.boolean(),
        timestamp: faker.date
          .past({ years: 30, refDate: new Date() })
          .toISOString(),
        recipientId: faker.helpers.arrayElement(recipients).id as UUID,
      };
    }

    notifications.push(
      supervisorNotification ?? (recipientNotification as Notification),
    );
  }

  return notifications;
}

export function generateCampaigns(
  recipients: Recipient[],
  noOfCampaigns: number,
  noOfCategories: number = 5,
): Campaign[] {
  const campiagns: Campaign[] = [];
  const categories: string[] = [];
  const paymentMethods = ["TeleBirr", "CBEBirr", "Phone", "Bank transfer"];
  const bankNames = ["Commercial Bank of Ethiopia", "Awash Bank", ""];

  for (let i = 0; i < noOfCategories; i++) {
    const category = faker.lorem.words({ min: 1, max: 3 });
    categories.push(category);
  }

  for (let i = 0; i < noOfCampaigns; i++) {
    const submissionDate = faker.date
      .past({ years: 1, refDate: new Date() })
      .toISOString();
    const verificationDate = faker.date
      .future({
        years: 0.5,
        refDate: submissionDate,
      })
      .toISOString();
    const denialDate = faker.date
      .future({
        years: 0.5,
        refDate: submissionDate,
      })
      .toISOString();
    const launchDate = faker.date
      .future({
        years: 0.5,
        refDate: verificationDate,
      })
      .toISOString();
    const endDate = faker.date
      .future({ years: 0.5, refDate: launchDate })
      .toISOString();
    const documentUrls: string[] = [];
    const redactedDocumentUrls: string[] = [];

    for (let i = 0; i < faker.number.int({ min: 0, max: 10 }); i++) {
      const documentUrl = faker.internet.url();
      const redactedDocumentUrl = faker.internet.url();
      documentUrls.push(documentUrl);
      redactedDocumentUrls.push(redactedDocumentUrl);
    }

    const campaign: Campaign = {
      id: randomUUID(),
      ownerRecipientId: faker.helpers.arrayElement(recipients).id as UUID,
      title: faker.lorem.words(),
      description: faker.lorem.sentences({ min: 2, max: 4 }),
      fundraisingGoal: faker.finance.amount({ min: 0, max: 10000, dec: 2 }),
      status: faker.helpers.arrayElement(CAMPAIGN_STATUSES),
      category: faker.helpers.arrayElement(categories),
      paymentInfo: {
        paymentMethod: faker.helpers.arrayElement(paymentMethods),
        phoneNo: faker.phone.number({ style: "international" }),
        bankAccountNo: faker.finance.accountNumber(16),
        bankName: faker.helpers.arrayElement(bankNames),
      },
      submissionDate,
      verificationDate,
      denialDate,
      launchDate,
      endDate,
      documentUrls,
      redactedDocumentUrls,
    };

    campiagns.push(campaign);
  }

  return campiagns;
}

export function generateCampaignDonations(
  campaigns: Campaign[],
  avgDonationPerCampaign: number,
): CampaignDonation[] {
  const campaignDonations: CampaignDonation[] = [];

  for (const campaign of campaigns) {
    // Random variation around avg
    const donationCount = Math.round(
      avgDonationPerCampaign * (1 + (Math.random() - 0.5)),
    );

    for (let i = 0; i < donationCount; i++) {
      const grossAmount = faker.finance.amount({ min: 5, max: 10000 });
      const serviceFee = (
        parseFloat(grossAmount) *
        faker.number.float({ min: 0.01, max: 0.1, fractionDigits: 2 })
      ).toFixed(2);

      const campaignDonation: CampaignDonation = {
        id: randomUUID(),
        grossAmount: grossAmount,
        serviceFee: serviceFee,
        timestamp: faker.date.recent().toISOString(),
        transactionRef: faker.string.alphanumeric(16),
        campaignId: campaign.id,
      };

      campaignDonations.push(campaignDonation);
    }
  }

  return campaignDonations;
}

export function generateCampaignPosts(
  campaigns: Campaign[],
  avgPostPerCampaign: number,
): CampaignPost[] {
  const campaignPosts: CampaignPost[] = [];

  for (const campaign of campaigns) {
    const postCount = Math.round(
      avgPostPerCampaign * (1 + (Math.random() - 0.5)),
    );

    for (let i = 0; i < postCount; i++) {
      const campaignPost = {
        id: randomUUID(),
        title: faker.lorem.words({ min: 3, max: 5 }),
        content: faker.lorem.sentences({ min: 5, max: 7 }),
        publicPostDate:
          Math.random() >= 0.5
            ? undefined
            : faker.date.recent({ days: 400 }).toISOString(),
        campaignId: campaign.id,
      };

      campaignPosts.push(campaignPost);
    }
  }

  return campaignPosts;
}

export function generatePostUpdateRequests(
  campaigns: Campaign[],
  campaignPosts: CampaignPost[],
  noOfRequests: number,
): PostUpdateRequest[] {
  // This is because of the unique constraint on table "PostUpdateRequest", we need a way to uniquely and randomly select campaign posts.

  const availableCampaignPosts = [...campaignPosts];

  return Array.from({ length: noOfRequests }, () => {
    const campaign = faker.helpers.arrayElement(campaigns);
    const newPost = availableCampaignPosts.splice(
      Math.floor(Math.random() * availableCampaignPosts.length),
      1,
    )[0];
    const requestDate = faker.date.past();
    const resolutionDate = faker.datatype.boolean()
      ? faker.date.future({ refDate: requestDate })
      : null;

    return {
      id: randomUUID(),
      title: faker.lorem.words(),
      requestDate: requestDate.toISOString(),
      justification: faker.lorem.sentences(),
      resolutionDate: resolutionDate ? resolutionDate.toISOString() : undefined,
      campaignId: campaign.id,
      newPost: newPost,
    };
  });
}

export function generateEndDateExtensionRequests(
  campaigns: Campaign[],
  noOfRequests: number,
): EndDateExtensionRequest[] {
  return Array.from({ length: noOfRequests }, () => {
    const campaign = faker.helpers.arrayElement(campaigns);
    const requestDate = faker.date.past();
    const resolutionDate = faker.datatype.boolean()
      ? faker.date.future({ refDate: requestDate })
      : null;
    const newEndDate = faker.date.future();

    return {
      id: randomUUID(),
      title: faker.lorem.words(),
      requestDate: requestDate.toISOString(),
      justification: faker.lorem.sentences(),
      resolutionDate: resolutionDate ? resolutionDate.toISOString() : undefined,
      campaignId: campaign.id,
      newEndDate: newEndDate.toISOString(),
    };
  });
}

export function generateGoalAdjustmentRequests(
  campaigns: Campaign[],
  noOfRequests: number,
): GoalAdjustmentRequest[] {
  return Array.from({ length: noOfRequests }, () => {
    const campaign = faker.helpers.arrayElement(campaigns);
    const requestDate = faker.date.past();
    const resolutionDate = faker.datatype.boolean()
      ? faker.date.future({ refDate: requestDate })
      : null;
    const newGoal = faker.finance.amount({ min: 1000, max: 100000, dec: 0 });

    return {
      id: randomUUID(),
      title: faker.lorem.words(),
      requestDate: requestDate.toISOString(),
      justification: faker.lorem.sentences(),
      resolutionDate: resolutionDate ? resolutionDate.toISOString() : undefined,
      campaignId: campaign.id,
      newGoal: newGoal,
    };
  });
}

export function generateStatusChangeRequests(
  campaigns: Campaign[],
  noOfRequests: number,
): StatusChangeRequest[] {
  return Array.from({ length: noOfRequests }, () => {
    const campaign = faker.helpers.arrayElement(campaigns);
    const requestDate = faker.date.past();
    const resolutionDate = faker.datatype.boolean()
      ? faker.date.future({ refDate: requestDate })
      : null;
    const newStatus = faker.helpers.arrayElement(CAMPAIGN_STATUSES);

    return {
      id: randomUUID(),
      title: faker.lorem.words(),
      requestDate: requestDate.toISOString(),
      justification: faker.lorem.sentences(),
      resolutionDate: resolutionDate ? resolutionDate.toISOString() : undefined,
      campaignId: campaign.id,
      newStatus: newStatus,
    };
  });
}
