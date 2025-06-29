import { faker } from "@faker-js/faker";
import {
  Recipient,
  SocialMediaHandle,
  Supervisor,
} from "../models/user.model.js";
import { randomUUID, UUID } from "crypto";
import { Notification } from "../models/notification.model.js";
import {
  Campaign,
  CampaignDonation,
  CampaignPost,
} from "../models/campaign.model.js";
import { CAMPAIGN_STATUSES, REQUEST_RESOLUTION_TYPES } from "./zod-helpers.js";
import {
  EndDateExtensionRequest,
  GoalAdjustmentRequest,
  PostUpdateRequest,
  StatusChangeRequest,
} from "../models/campaign-request.model.js";

const BankNamesAndCodes: { name: string; code: number }[] = [
  { name: "Abay Bank", code: 130 },
  { name: "Addis International Bank", code: 772 },
  { name: "Ahadu Bank", code: 207 },
  { name: "Awash Bank", code: 656 },
  { name: "Bank of Abyssinia", code: 347 },
  { name: "Berhan Bank", code: 571 },
  { name: "Commercial Bank of Ethiopia (CBE)", code: 946 },
  { name: "Dashen Bank", code: 880 },
  { name: "Enat Bank", code: 1 },
  { name: "Global Bank Ethiopia", code: 301 },
  { name: "Hibret Bank", code: 534 },
  { name: "Lion International Bank", code: 315 },
  { name: "Nib International Bank", code: 979 },
  { name: "Wegagen Bank", code: 472 },
];

export function generateRecipients(auth0RecipientIds: string[]): Recipient[] {
  const recipients: Recipient[] = [];

  for (const auth0UserId of auth0RecipientIds) {
    const recipient: Recipient = {
      id: randomUUID(),
      auth0UserId,
      firstName: faker.person.firstName(),
      middleName: faker.person.middleName(),
      lastName: faker.person.lastName(),
      dateOfBirth: faker.date.past({ years: 30, refDate: new Date() }),
      email: "",
      phoneNo: faker.phone.number({ style: "international" }),
      bio: faker.lorem.sentence(),
      profilePictureUrl:
        Math.random() >= 0.5 ? faker.image.avatar() : undefined,
    };

    recipient.email = faker.internet.email({
      firstName: recipient.firstName,
      lastName: recipient.lastName,
    });

    recipients.push(recipient);
  }

  return recipients;
}

export function generateSocialHandles(
  recipients: Recipient[]
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
  auth0SupervisorIds: string[]
): Supervisor[] {
  const supervisors: Supervisor[] = [];

  for (const auth0UserId of auth0SupervisorIds) {
    const supervisor: Supervisor = {
      id: randomUUID(),
      auth0UserId,
      firstName: faker.person.firstName(),
      middleName: faker.person.middleName(),
      lastName: faker.person.lastName(),
      dateOfBirth: faker.date.past({ years: 30, refDate: new Date() }),
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
  noOfNotifications: number
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
        createdAt: faker.date.past({ years: 30, refDate: new Date() }),
        userType: "Supervisor",
        userId: faker.helpers.arrayElement(supervisors).id as UUID,
      };
    } else {
      recipientNotification = {
        id: randomUUID(),
        subject: faker.lorem.sentence({ min: 1, max: 2 }),
        body: faker.lorem.sentence({ min: 3, max: 5 }),
        isRead: faker.datatype.boolean(),
        createdAt: faker.date.past({ years: 30, refDate: new Date() }),
        userType: "Recipient",
        userId: faker.helpers.arrayElement(recipients).id as UUID,
      };
    }

    notifications.push(
      supervisorNotification ?? (recipientNotification as Notification)
    );
  }

  return notifications;
}

export function generateCampaigns(
  recipients: Recipient[],
  noOfCampaigns: number
): Campaign[] {
  const campiagns: Campaign[] = [];
  const categories: string[] = [
    "Charity",
    "Education",
    "Health",
    "Animal Welfare",
    "Community",
    "Youth",
  ];

  for (let i = 0; i < noOfCampaigns; i++) {
    const campaignId = randomUUID();
    const submissionDate = faker.date.past({ years: 1, refDate: new Date() });

    const verificationDate = faker.date.future({
      years: 0.5,
      refDate: submissionDate,
    });

    const denialDate = faker.date.future({
      years: 0.5,
      refDate: submissionDate,
    });

    const launchDate = faker.date.future({
      years: 0.5,
      refDate: verificationDate,
    });

    const endDate = faker.date.future({ years: 0.5, refDate: launchDate });

    const documents: {
      campaignId: UUID;
      documentUrl: string;
      redactedDocumentUrl: string;
    }[] = [];

    for (let i = 0; i < faker.number.int({ min: 0, max: 5 }); i++) {
      const documentUrl = faker.internet.url();
      const redactedDocumentUrl = faker.internet.url();
      documents.push({ campaignId, documentUrl, redactedDocumentUrl });
    }

    const selectedBank =
      BankNamesAndCodes[
        faker.number.int({ min: 0, max: BankNamesAndCodes.length - 1 })
      ];

    const campaign: Campaign = {
      id: campaignId,
      ownerRecipientId: faker.helpers.arrayElement(recipients).id as UUID,
      title: faker.lorem.words(),
      description: faker.lorem.sentences({ min: 2, max: 4 }),
      fundraisingGoal: faker.finance.amount({ min: 500, max: 10000, dec: 2 }),
      status: faker.helpers.arrayElement(CAMPAIGN_STATUSES),
      category: faker.helpers.arrayElement(categories),
      paymentInfo: {
        chapaBankCode: selectedBank.code,
        chapaBankName: selectedBank.name,
        bankAccountNo: faker.finance.accountNumber(16),
      },
      // this is a synthesized field, so it is ignored by the seed function
      totalDonated: "0",
      isPublic: faker.datatype.boolean(),
      submissionDate,
      verificationDate,
      denialDate,
      launchDate,
      endDate,
      documents: [],
    };

    campaign.documents = [...documents];
    campiagns.push(campaign);
  }

  return campiagns;
}
export function generateCampaignDonations(
  campaigns: Campaign[],
  avgDonationAmountForCampaign: number = 50
): CampaignDonation[] {
  const campaignDonations: CampaignDonation[] = [];

  for (const campaign of campaigns) {
    let currentTotalDonated = 0;
    const fundraisingGoal = parseFloat(campaign.fundraisingGoal);

    let donationAttempts = 0;
    const maxDonationAttempts = 500;

    while (
      currentTotalDonated < fundraisingGoal &&
      donationAttempts < maxDonationAttempts
    ) {
      const remainingGoal = fundraisingGoal - currentTotalDonated;

      const maxPossibleDonation = Math.max(
        5,
        Math.min(avgDonationAmountForCampaign * 2, remainingGoal * 0.8)
      );

      const minDonationAmount = 5;
      const actualMaxDonation = Math.max(
        minDonationAmount,
        maxPossibleDonation
      );

      let grossAmount = faker.finance.amount({
        min: minDonationAmount,
        max: actualMaxDonation,
        dec: 2,
      });

      const donationAmount = parseFloat(grossAmount);

      if (currentTotalDonated + donationAmount > fundraisingGoal) {
        if (remainingGoal > 0.01) {
          grossAmount = (remainingGoal - 0.01).toFixed(2);
          if (parseFloat(grossAmount) <= 0) {
            break;
          }
        } else {
          break;
        }
      }

      const serviceFee = (
        parseFloat(grossAmount) *
        faker.number.float({ min: 0.01, max: 0.1, fractionDigits: 2 })
      ).toFixed(2);

      const campaignDonation: CampaignDonation = {
        id: randomUUID(),
        grossAmount: grossAmount,
        serviceFee: serviceFee,
        createdAt: faker.date.recent(),
        transactionRef: faker.string.alphanumeric(16),
        isTransferred: faker.datatype.boolean(),
        campaignId: campaign.id,
      };

      campaignDonations.push(campaignDonation);
      currentTotalDonated += parseFloat(grossAmount);
      donationAttempts++;
    }

    campaign.totalDonated = currentTotalDonated.toFixed(2);
  }

  return campaignDonations;
}

export function generateCampaignPosts(
  campaigns: Campaign[],
  avgPostPerCampaign: number
): CampaignPost[] {
  const campaignPosts: CampaignPost[] = [];

  for (const campaign of campaigns) {
    const postCount = Math.round(
      avgPostPerCampaign * (1 + (Math.random() - 0.5))
    );

    for (let i = 0; i < postCount; i++) {
      const campaignPost = {
        id: randomUUID(),
        title: faker.lorem.words({ min: 3, max: 5 }),
        content: faker.lorem.sentences({ min: 5, max: 7 }),
        publicPostDate:
          Math.random() >= 0.5 ? undefined : faker.date.recent({ days: 400 }),
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
  noOfRequests: number
): PostUpdateRequest[] {
  // This is because of the unique constraint on table "PostUpdateRequest", we need a way to uniquely and randomly select campaign posts.

  const availableCampaignPosts = [...campaignPosts];

  return Array.from({ length: noOfRequests }, () => {
    const campaign = faker.helpers.arrayElement(campaigns);
    const newPost = availableCampaignPosts.splice(
      Math.floor(Math.random() * availableCampaignPosts.length),
      1
    )[0];
    const requestDate = faker.date.past();
    const resolutionDate = faker.datatype.boolean()
      ? faker.date.future({ refDate: requestDate })
      : null;

    return {
      id: randomUUID(),
      requestType: "Post Update",
      title: faker.lorem.words(),
      requestDate: requestDate,
      justification: faker.lorem.sentences(),
      resolutionDate: resolutionDate ? resolutionDate : undefined,
      resolutionType: faker.helpers.arrayElement(REQUEST_RESOLUTION_TYPES),
      campaignId: campaign.id,
      newPost: newPost,
    };
  });
}

export function generateEndDateExtensionRequests(
  campaigns: Campaign[],
  noOfRequests: number
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
      requestType: "End Date Extension",
      title: faker.lorem.words(),
      requestDate: requestDate,
      justification: faker.lorem.sentences(),
      resolutionDate: resolutionDate ? resolutionDate : undefined,
      resolutionType: faker.helpers.arrayElement(REQUEST_RESOLUTION_TYPES),
      campaignId: campaign.id,
      newEndDate: newEndDate,
    };
  });
}

export function generateGoalAdjustmentRequests(
  campaigns: Campaign[],
  noOfRequests: number
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
      requestType: "Goal Adjustment",
      title: faker.lorem.words(),
      requestDate: requestDate,
      justification: faker.lorem.sentences(),
      resolutionDate: resolutionDate ? resolutionDate : undefined,
      resolutionType: faker.helpers.arrayElement(REQUEST_RESOLUTION_TYPES),
      campaignId: campaign.id,
      newGoal: newGoal,
    };
  });
}

export function generateStatusChangeRequests(
  campaigns: Campaign[],
  noOfRequests: number
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
      requestType: "Status Change",
      title: faker.lorem.words(),
      requestDate: requestDate,
      justification: faker.lorem.sentences(),
      resolutionDate: resolutionDate ? resolutionDate : undefined,
      resolutionType: faker.helpers.arrayElement(REQUEST_RESOLUTION_TYPES),
      campaignId: campaign.id,
      newStatus: newStatus,
    };
  });
}
