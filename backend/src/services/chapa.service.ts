import axios from "axios";
import { config } from "../config.js";
import { UUID } from "crypto";

export type ChapaResponse = {
  message: string;
  status: "success" | "failed";
  data?:
    | ChapaPaymentVerifyData
    | ChapaTransferVerifyData
    | ChapaTransferInitiateData;
};

export type ChapaPaymentVerifyData = {
  first_name: string;
  last_name: string;
  email: string;
  currency: "ETB" | "USD";
  amount: number;
  charge: number;
  mode: string;
  method: string;
  type: string;
  status: string;
  reference: string;
  tx_ref: string;
  customization: unknown;
  meta: null;
  created_at: string;
  updated_at: string;
};

export type ChapaTransferInitiateData = string;

export type ChapaTransferVerifyData = {
  account_name: string;
  account_number: string;
  mobile: string | null;
  currency: "ETB" | "USD";
  amount: number;
  charge: number;
  mode: string;
  transfer_method: string;
  narration: string | null;
  chapa_transfer_id: UUID;
  bank_code: number;
  bank_name: string;
  cross_party_reference: string | null;
  ip_address: string;
  status: string;
  tx_ref: string;
  created_at: string;
  updated_at: string;
};

export async function verifyChapaPayment(
  txnRef: string
): Promise<ChapaResponse> {
  const url = `https://api.chapa.co/v1/transaction/verify/${txnRef}`;

  const response = await axios.get(url, {
    headers: { Authorization: `Bearer ${config.TEST_CHAPA_SECRET}` },
  });

  return response.data as ChapaResponse;
}

export async function initiateChapaTransfer(params: {
  destinationAccountNo: string;
  chapaBankCode: number;
  amount: string;
  reference?: string;
  currency?: "ETB" | "USD";
  accountName?: string;
}): Promise<ChapaResponse> {
  const url = "https://api.chapa.co/v1/transfers";

  // Prepare the payload according to Chapa's API requirements
  const payload = {
    amount: params.amount,
    bank_code: params.chapaBankCode,
    account_number: params.destinationAccountNo,
    reference: params.reference,
    currency: params.currency ?? "ETB",
    account_name: params.accountName,
  };

  const response = await axios.post(url, payload, {
    headers: {
      Authorization: `Bearer ${config.TEST_CHAPA_SECRET}`,
      "Content-Type": "application/json",
    },
  });

  return response.data as ChapaResponse;
}

export async function verifyChapaTransfer(
  txnRef: string
): Promise<ChapaResponse> {
  const url = `https://api.chapa.co/v1/transfers/verify/${txnRef}`;

  const response = await axios.get(url, {
    headers: { Authorization: `Bearer ${config.TEST_CHAPA_SECRET}` },
  });

  return response.data as ChapaResponse;
}
