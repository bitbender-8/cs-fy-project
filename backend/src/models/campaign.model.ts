import { UUID } from "crypto";
import { z } from "zod";
import {
  MIN_STRING_LENGTH,
  validNonEmptyString,
  validBankAccountNo,
  validCampaignStatus,
  validDate,
  validPhoneNo,
  validUrl,
  validUuid,
  validMoneyAmount,
  CAMPAIGN_STATUSES,
} from "../utils/zod-helpers.js";

export type CampaignStatus = (typeof CAMPAIGN_STATUSES)[number];

/** These fields cannot be updated manually by a user. */
export const LOCKED_CAMPAIGN_FIELDS = [
  "id",
  "ownerRecipientId",
  "launchDate",
  "isPublic",
  "submissionDate",
  "verificationDate",
  "denialDate",
  "paymentInfo",
] as const;
export type LockedCampaignFields = (typeof LOCKED_CAMPAIGN_FIELDS)[number];

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

/** Schema defined at {@link CampaignSchema} */
export interface Campaign {
  id: UUID; // Locked
  ownerRecipientId: UUID; // Locked
  title: string; // Normal
  description: string; // Normal
  fundraisingGoal: string; // Request, just replace old
  // Request, there are valid and invalid state transitions.
  status: CampaignStatus; 
  category: string; // Normal
  launchDate?: Date | string; // Locked
  endDate: Date | string; // Request, check that it is later

  // Sensitive fields: Available to Supervisors and Campaign owners
  isPublic?: boolean; // Locked
  submissionDate?: Date | string; // Locked
  verificationDate?: Date | string; // Locked
  denialDate?: Date | string; // Locked
  documents: {
    campaignId: UUID;
    documentUrl: string;
    redactedDocumentUrl?: string;
  }[]; // Normal, replace both the files and their url.
  paymentInfo: PaymentInfo; // Locked
}

export interface PaymentInfo {
  paymentMethod: string;
  phoneNo: string;
  bankAccountNo?: string;
  bankName?: string;
}

export interface CampaignDonation {
  id: UUID;
  grossAmount: string;
  serviceFee: string;
  createdAt: Date | string;
  transactionRef: string;
  campaignId: UUID;
}

export interface CampaignPost {
  id: UUID;
  title: string;
  content: string;
  // If falsy, then campaign is not publicly available.
  publicPostDate?: Date | string;
  campaignId: UUID;
}

// ================= Zod schemas ====================

export const PaymentInfoSchema = z.object({
  paymentMethod: validNonEmptyString(MIN_STRING_LENGTH, 50),
  phoneNo: validPhoneNo(),
  bankAccountNo: validBankAccountNo().optional(),
  bankName: validNonEmptyString(MIN_STRING_LENGTH, 50).optional(),
});

// FIXME Add more specific validation logic. Like min and max length of campaign, things like submissionDate < verificationDate.
export const CampaignSchema = z.object({
  id: validUuid().optional(),
  ownerRecipientId: validUuid(),
  title: validNonEmptyString(MIN_STRING_LENGTH, 100),
  description: validNonEmptyString(MIN_STRING_LENGTH, 500),
  fundraisingGoal: validMoneyAmount(),
  status: validCampaignStatus(),
  category: validNonEmptyString(MIN_STRING_LENGTH, 50),
  launchDate: validDate(false).optional(),
  endDate: validDate(false),

  // Sensitive fields
  isPublic: z.boolean().optional(),
  submissionDate: validDate(true).optional(),
  verificationDate: validDate(true).optional(),
  denialDate: validDate(true).optional(),
  documents: z
    .array(
      z.object({
        documentUrls: validUrl(),
        redactedDocumentUrls: validUrl().optional(),
      })
    )
    .optional(),
  paymentInfo: PaymentInfoSchema,
});

export const CampaignDonationSchema = z.object({
  id: validUuid().optional(),
  grossAmount: validMoneyAmount(),
  serviceFee: validMoneyAmount(),
  createdAt: validDate(true),
  transactionRef: validNonEmptyString(MIN_STRING_LENGTH, 255),
  campaignId: validUuid(),
});

export const CampaignPostSchema = z.object({
  id: validUuid().optional(),
  title: validNonEmptyString(MIN_STRING_LENGTH, 100),
  content: validNonEmptyString(MIN_STRING_LENGTH, Infinity),
  publicPostDate: validDate(true).optional(),
  campaingId: validUuid(),
});
