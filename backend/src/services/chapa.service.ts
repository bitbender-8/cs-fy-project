import axios from "axios";
import { config } from "../config.js";

type ChapaResponse = {
  message: string;
  status: string;
  data: unknown;
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

export async function initiateChapaTransfer(
  destinationAccountNo: string,
  amount: string,
  chapaBankCode: string,
  currency: "ETB" | "USD" = "ETB",
  reference?: string,
  accountName?: string
): Promise<ChapaResponse> {
  const url = "https://api.chapa.co/v1/transfers";

  // Prepare the payload according to Chapa's API requirements
  const payload = {
    amount,
    currency,
    account_bank: chapaBankCode,
    account_number: destinationAccountNo,
    account_name: accountName,
    narration: `Transfer for reference ${reference}`,
    reference,
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
