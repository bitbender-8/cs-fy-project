import { UUID } from "crypto";

export type CampaignStatus =
  | "PENDING_REVIEW"
  | "VERIFIED"
  | "DENIED"
  | "LIVE"
  | "PAUSED"
  | "COMPLETED";

export interface Campaign {
  id: UUID;
  title: string;
  description: string;
  fundraisingGoal: string;
  status: CampaignStatus;
  category: string;
  submissionDate: Date | string;
  verificationDate: Date | string;
  denialDate: Date | string;
  launchDate: Date | string;
  endDate: Date | string;
  redactedDocumentUrls: string[];

  // Sensitive fields below
  documentUrls: string[];
  paymentInfo: PaymentInfo;
}

export interface PaymentInfo {
  paymentMethod: string;
  phoneNo: string;
  bankAccountNo: string;
  bankName: string;
}

export interface CampaignDonation {
  id: UUID;
  grossAmount: string;
  serviceFee: string;
  timestmap: Date | string;
  transactionRef: string;
  campaignId: UUID;
}

export interface CampaignPost {
  id: UUID;
  title: string;
  content: string;
  publicPostDate: Date | string;
  campaignId: UUID;
}
