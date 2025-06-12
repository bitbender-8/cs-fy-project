import axios from "axios";
import { config } from "../config.js";
import { UUID } from "crypto";
import { AppError } from "../errors/error.types.js";

/**
 * @typedef {object} ChapaResponse
 * @description Represents a generic response structure from the Chapa API.
 * For detailed and up-to-date information on this type and its properties,
 * please refer to the official Chapa API documentation.
 */
export type ChapaResponse = {
  message: string;
  status: "success" | "failed" | "pending";
  data?:
    | ChapaPaymentVerifyData
    | ChapaTransferVerifyData
    | ChapaTransferInitiateData;
};

/**
 * @typedef {object} ChapaPaymentVerifyData
 * @description Represents the data structure for a verified Chapa payment transaction.
 * For detailed and up-to-date information on this type and its properties,
 * please refer to the official Chapa API documentation.
 */
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

/**
 * @typedef {string} ChapaTransferInitiateData
 * @description Represents the data structure for an initiated Chapa transfer, which is typically the transaction reference string.
 * For detailed and up-to-date information on this type,
 * please refer to the official Chapa API documentation.
 */
export type ChapaTransferInitiateData = string;

/**
 * @typedef {object} ChapaTransferVerifyData
 * @description Represents the data structure for a verified Chapa transfer.
 * For detailed and up-to-date information on this type and its properties,
 * please refer to the official Chapa API documentation.
 */
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

/**
 * Verifies a Chapa payment transaction.
 * @async
 * @param {string} txnRef - The transaction reference (`tx_ref`) to verify.
 * @returns {Promise<ChapaResponse>} A promise that resolves with the Chapa API response.
 * @throws {AppError} If the API request fails or returns an error status.
 */
export async function verifyChapaPayment(
  txnRef: string
): Promise<ChapaResponse> {
  const url = `https://api.chapa.co/v1/transaction/verify/${txnRef}`;

  try {
    const response = await axios.get(url, {
      headers: { Authorization: `Bearer ${config.TEST_CHAPA_SECRET}` },
    });
    console.log("Chapa Payment Verification Response:", response.data);
    return response.data as ChapaResponse;
  } catch (error: unknown) {
    if (!axios.isAxiosError(error)) {
      throw error;
    }

    if (error.response) {
      switch (error.response.status) {
        case 400:
          throw new AppError(
            "Validation Failure",
            400,
            "Failed to verify Chapa payment: Invalid request or malformed data",
            {
              internalDetails: `Chapa API rejected the payment verification request due to bad data.
              Status: ${error.response.status}
              Response: ${JSON.stringify(error.response.data)}`,
              cause: error,
            }
          );
        case 401:
          throw new AppError(
            "Internal Server Error",
            500,
            "Failed to verify Chapa payment: Authentication failed.",
            {
              internalDetails: `Chapa API authentication failed. This could be due to an invalid API key, or using a test key for a live transaction/vice-versa.
              Status: ${error.response.status}
              Response: ${JSON.stringify(error.response.data)}`,
              cause: error,
            }
          );
        case 404:
          throw new AppError(
            "Not Found",
            404,
            "Failed to verify Chapa payment: Invalid transaction, not found, or not paid yet",
            {
              internalDetails: `Chapa API could not find the payment transaction with reference '${txnRef}' or it's not yet paid.
              Status: ${error.response.status}
              Response: ${JSON.stringify(error.response.data)}`,
              cause: error,
            }
          );
        case 500:
        case 503:
          throw new AppError(
            "Service Unavailable",
            error.response.status,
            "Chapa service is temporarily unavailable for payment verification",
            {
              internalDetails: `Payment verification failed due to an unexpected error from the Chapa API.
              Status: ${error.response.status}
              Response: ${JSON.stringify(error.response.data)}`,
              cause: error,
            }
          );
        default:
          throw new AppError(
            "Internal Server Error",
            500,
            "Something went wrong during Chapa payment verification",
            {
              internalDetails: `Chapa payment verification failed due to an unexpected HTTP error.
              Status: ${error.response.status}
              Response: ${JSON.stringify(error.response.data)}`,
              cause: error,
            }
          );
      }
    } else if (error.request) {
      throw new AppError(
        "Service Unavailable",
        503,
        "Chapa service is temporarily unavailable",
        {
          internalDetails:
            "No response was received from the Chapa API for payment verification.",
          cause: error,
        }
      );
    } else {
      throw new AppError(
        "Internal Server Error",
        500,
        "Something went wrong while setting up Chapa payment verification request",
        {
          internalDetails:
            "An error occurred while setting up the payment verification request for Chapa API.",
          cause: error,
        }
      );
    }
  }
}

/**
 * Initiates a transfer to a bank account via Chapa.
 * @async
 * @param {object} params - The parameters for initiating the transfer.
 * @param {string} params.destinationAccountNo - The recipient's bank account number.
 * @param {number} params.chapaBankCode - The Chapa bank code for the recipient's bank.
 * @param {string} params.amount - The amount to transfer (as a string, e.g., "100.00").
 * @param {string} [params.reference] - Optional unique reference for the transfer.
 * @param {"ETB" | "USD"} [params.currency="ETB"] - Optional currency for the transfer, defaults to "ETB".
 * @param {string} [params.accountName] - Optional name of the recipient account.
 * @returns {Promise<ChapaResponse>} A promise that resolves with the Chapa API response, containing the transaction reference if successful.
 * @throws {AppError} If the API request fails or returns an error status.
 */
export async function initiateChapaTransfer(params: {
  destinationAccountNo: string;
  chapaBankCode: number;
  amount: string;
  reference?: string;
  currency?: "ETB" | "USD";
  accountName?: string;
}): Promise<ChapaResponse> {
  const url = "https://api.chapa.co/v1/transfers";

  const payload: Record<string, unknown> = {
    amount: params.amount,
    bank_code: params.chapaBankCode,
    account_number: params.destinationAccountNo,
    currency: params.currency ?? "ETB",
  };

  if (params.reference !== undefined) {
    payload.reference = params.reference;
  }
  if (params.accountName !== undefined) {
    payload.account_name = params.accountName;
  }
  console.log("Chapa Transfer Initiate Payload:", payload);

  try {
    const response = await axios.post(url, payload, {
      headers: {
        Authorization: `Bearer ${config.TEST_CHAPA_SECRET}`,
        "Content-Type": "application/json",
      },
    });
    console.log("Chapa Transfer Initiation Response:", response.data);
    return response.data as ChapaResponse;
  } catch (error: unknown) {
    if (!axios.isAxiosError(error)) {
      throw error;
    }

    if (error.response) {
      switch (error.response.status) {
        case 400:
          throw new AppError(
            "Validation Failure",
            400,
            `Failed to initiate Chapa transfer: Invalid request data or business rule violation.`,
            {
              internalDetails: `Chapa API rejected the transfer initiation request due to bad data: ${error.response.data?.message || "Unknown reason"}. Common issues: missing required attributes, invalid bank code, invalid account number, unsupported currency, insufficient balance, or used reference number.
              Status: ${error.response.status}
              Response: ${JSON.stringify(error.response.data)}`,
              cause: error,
            }
          );
        case 401:
          throw new AppError(
            "Internal Server Error",
            500,
            `Failed to initiate Chapa transfer: Authentication failed.`,
            {
              internalDetails: `Chapa API authentication failed: ${error.response.data?.message || "Invalid API Key or user existence issue."}. Check API key, user existence, or transfer hours.
              Status: ${error.response.status}
              Response: ${JSON.stringify(error.response.data)}`,
              cause: error,
            }
          );
        case 404:
          throw new AppError(
            "Not Found",
            404,
            `Failed to initiate Chapa transfer: Service temporarily unavailable.`,
            {
              internalDetails: `Chapa API indicated that the transfer service is not available: ${error.response.data?.message || "Unknown reason"}.
              Status: ${error.response.status}
              Response: ${JSON.stringify(error.response.data)}`,
              cause: error,
            }
          );
        case 429:
          throw new AppError(
            "Service Unavailable",
            429,
            "Failed to initiate Chapa transfer: Too many requests. Please try again later.",
            {
              internalDetails: `Chapa API rejected the transfer initiation due to rate limiting.
              Status: ${error.response.status}
              Response: ${JSON.stringify(error.response.data)}`,
              cause: error,
            }
          );
        case 500:
        case 503:
          throw new AppError(
            "Service Unavailable",
            error.response.status,
            "Chapa service is temporarily unavailable for transfer initiation",
            {
              internalDetails: `Transfer initiation failed due to an unexpected error from the Chapa API.
              Status: ${error.response.status}
              Response: ${JSON.stringify(error.response.data)}`,
              cause: error,
            }
          );
        default:
          throw new AppError(
            "Internal Server Error",
            500,
            "Something went wrong during Chapa transfer initiation",
            {
              internalDetails: `Chapa transfer initiation failed due to an unexpected HTTP error.
              Status: ${error.response.status}
              Response: ${JSON.stringify(error.response.data)}`,
              cause: error,
            }
          );
      }
    } else if (error.request) {
      throw new AppError(
        "Service Unavailable",
        503,
        "Chapa service is temporarily unavailable",
        {
          internalDetails:
            "No response was received from the Chapa API for transfer initiation.",
          cause: error,
        }
      );
    } else {
      throw new AppError(
        "Internal Server Error",
        500,
        "Something went wrong while setting up Chapa transfer initiation request",
        {
          internalDetails:
            "An error occurred while setting up the transfer initiation request for Chapa API.",
          cause: error,
        }
      );
    }
  }
}

/**
 * Verifies a Chapa transfer transaction.
 * @async
 * @param {string} txnRef - The transaction reference (`tx_ref` or the reference returned by `initiateChapaTransfer`) to verify.
 * @returns {Promise<ChapaResponse>} A promise that resolves with the Chapa API response.
 * @throws {AppError} If the API request fails or returns an error status.
 */
export async function verifyChapaTransfer(
  txnRef: string
): Promise<ChapaResponse> {
  const url = `https://api.chapa.co/v1/transfers/verify/${txnRef}`;

  try {
    const response = await axios.get(url, {
      headers: { Authorization: `Bearer ${config.TEST_CHAPA_SECRET}` },
    });
    console.log("Chapa Transfer Verification Response:", response.data);
    return response.data as ChapaResponse;
  } catch (error: unknown) {
    if (!axios.isAxiosError(error)) {
      throw error;
    }

    if (error.response) {
      switch (error.response.status) {
        case 400:
          throw new AppError(
            "Validation Failure",
            400,
            "Failed to verify Chapa transfer: Invalid request or malformed data.",
            {
              internalDetails: `Chapa API rejected the transfer verification request due to bad data.
              Status: ${error.response.status}
              Response: ${JSON.stringify(error.response.data)}`,
              cause: error,
            }
          );
        case 401:
          throw new AppError(
            "Internal Server Error",
            500,
            "Failed to verify Chapa transfer: Authentication failed.",
            {
              internalDetails: `Chapa API authentication failed. This could be due to an invalid API key, or using a test key for a live transaction/vice-versa.
              Status: ${error.response.status}
              Response: ${JSON.stringify(error.response.data)}`,
              cause: error,
            }
          );
        case 404:
          throw new AppError(
            "Not Found",
            404,
            "Failed to verify Chapa transfer: Invalid transaction or transaction not found.",
            {
              internalDetails: `Chapa API could not find the transfer transaction with reference '${txnRef}'.
              Status: ${error.response.status}
              Response: ${JSON.stringify(error.response.data)}`,
              cause: error,
            }
          );
        case 500:
        case 503:
          throw new AppError(
            "Service Unavailable",
            error.response.status,
            "Chapa service is temporarily unavailable for transfer verification",
            {
              internalDetails: `Transfer verification failed due to an unexpected error from the Chapa API.
              Status: ${error.response.status}
              Response: ${JSON.stringify(error.response.data)}`,
              cause: error,
            }
          );
        default:
          throw new AppError(
            "Internal Server Error",
            500,
            "Something went wrong during Chapa transfer verification",
            {
              internalDetails: `Chapa transfer verification failed due to an unexpected HTTP error.
              Status: ${error.response.status}
              Response: ${JSON.stringify(error.response.data)}`,
              cause: error,
            }
          );
      }
    } else if (error.request) {
      throw new AppError(
        "Service Unavailable",
        503,
        "Chapa service is temporarily unavailable",
        {
          internalDetails:
            "No response was received from the Chapa API for transfer verification.",
          cause: error,
        }
      );
    } else {
      throw new AppError(
        "Internal Server Error",
        500,
        "Something went wrong while setting up Chapa transfer verification request",
        {
          internalDetails:
            "An error occurred while setting up the transfer verification request for Chapa API.",
          cause: error,
        }
      );
    }
  }
}
