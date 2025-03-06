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
  submissionDate: Date;
  verificationDate: Date;
  denialDate: Date;
  launchDate: Date;
  endDate: Date;
  documentUrls: string[];
  redactedDocumentUrls: string[];
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
  timestmap: Date;
  transactionRef: string;
  campaignId: UUID;
}

export interface CampaignPost {
  id: UUID;
  title: string;
  content: string;
  publicPostDate: Date;
  campaignId: UUID;
}
