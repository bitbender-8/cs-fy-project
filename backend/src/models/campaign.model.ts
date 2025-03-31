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

export const LOCKED_CAMPAIGN_FIELDS = [
  "id",
  "ownerRecipientId",
  "launchDate",
  "submissionDate",
  "verificationDate",
  "denialDate",
] as const;
export type LockedCampaignFields = (typeof LOCKED_CAMPAIGN_FIELDS)[number];

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
  id: UUID;
  ownerRecipientId: UUID;
  title: string;
  description: string;
  fundraisingGoal: string;
  status: CampaignStatus;
  category: string;
  launchDate?: Date | string;
  endDate: Date | string;

  // Sensitive fields: Available to Supervisors and Campaign owners
  isPublic?: boolean;
  submissionDate?: Date | string;
  verificationDate?: Date | string;
  denialDate?: Date | string;
  // TODO On the admin client-side, make sure to require that every redacted document is matched to a normal document.
  documents: {
    campaignId: UUID;
    documentUrl: string;
    redactedDocumentUrl?: string;
  }[];
  paymentInfo: PaymentInfo;
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
