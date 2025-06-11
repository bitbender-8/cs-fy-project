import { z } from "zod";
import {
  MIN_STRING_LENGTH,
  validNonEmptyString,
  validBankAccountNo,
  validCampaignStatus,
  validDate,
  validUrl,
  validUuid,
  validMoneyAmount,
  CAMPAIGN_STATUSES,
  validBankCode,
  validBoolean,
} from "../utils/zod-helpers.js";

export type CampaignStatus = (typeof CAMPAIGN_STATUSES)[number];

// DOC-UPDATE: Made changes to the way accounts are stored
export type PaymentInfo = z.infer<typeof PaymentInfoSchema>;
export const PaymentInfoSchema = z.object({
  chapaBankCode: validBankCode(),
  chapaBankName: validNonEmptyString(MIN_STRING_LENGTH, 50),
  bankAccountNo: validBankAccountNo(),
});

export type CampaignDocument = z.infer<typeof CampaignDocumentSchema>;
export const CampaignDocumentSchema = z.object({
  campaignId: validUuid(),
  /** Also serves as the id for the document */
  documentUrl: validUrl(),
  redactedDocumentUrl: validUrl().optional(),
});

// FIXME Add more specific validation logic. Like min and max length of campaign, things like submissionDate < verificationDate.
export type Campaign = z.infer<typeof CampaignSchema>;
export const CampaignSchema = z.object({
  id: validUuid(),
  ownerRecipientId: validUuid(),
  title: validNonEmptyString(MIN_STRING_LENGTH, 100),
  description: validNonEmptyString(MIN_STRING_LENGTH, 500),
  fundraisingGoal: validMoneyAmount(),
  status: validCampaignStatus(),
  category: validNonEmptyString(MIN_STRING_LENGTH, 50),
  launchDate: validDate(false).optional(),
  endDate: validDate(false),
  totalDonated: validMoneyAmount(),

  // Sensitive fields
  isPublic: z.boolean().optional(),
  submissionDate: validDate(true).optional(),
  verificationDate: validDate(true).optional(),
  denialDate: validDate(true).optional(),
  documents: z.array(CampaignDocumentSchema),
  paymentInfo: PaymentInfoSchema,
});

export type CampaignDonation = z.infer<typeof CampaignDonationSchema>;
export const CampaignDonationSchema = z.object({
  id: validUuid().optional(),
  grossAmount: validMoneyAmount(),
  serviceFee: validMoneyAmount(),
  createdAt: validDate(true),
  transactionRef: validNonEmptyString(MIN_STRING_LENGTH, 255),
  // DOC-UPDATE: Added isTransferred parameter
  isTransferred: validBoolean(),
  campaignId: validUuid(),
});

export type CampaignPost = z.infer<typeof CampaignPostSchema>;
export const CampaignPostSchema = z.object({
  id: validUuid(),
  title: validNonEmptyString(MIN_STRING_LENGTH, 100),
  content: validNonEmptyString(MIN_STRING_LENGTH, Infinity),
  publicPostDate: validDate(true).optional(),
  campaignId: validUuid(),
});

/** These fields must not be exposed to public users. */
export const SENSITIVE_CAMPAIGN_FIELDS = [
  "submissionDate",
  "verificationDate",
  "denialDate",
  "documents",
  "paymentInfo",
  "isPublic",
] as const;
export type SensitiveCampaignFields =
  (typeof SENSITIVE_CAMPAIGN_FIELDS)[number];

/** Only these fields are submitted when a campaign is updated by a user. */
export const UPDATABLE_CAMPAIGN_FIELDS = [
  "title",
  "description",
  "fundraisingGoal",
  "status",
  "category",
  "endDate",
] as const;
export type UpdateableCampaignFields =
  (typeof UPDATABLE_CAMPAIGN_FIELDS)[number];

/** Only these fields are submitted when a campaign is created by a user. */
export const CREATEABLE_CAMPAIGN_FIELDS = [
  "ownerRecipientId",
  "title",
  "description",
  "fundraisingGoal",
  "category",
  "endDate",
  "documents",
  "paymentInfo",
] as const;
export type CreateableCampaignFields =
  (typeof CREATEABLE_CAMPAIGN_FIELDS)[number];
