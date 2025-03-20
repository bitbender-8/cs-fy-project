import { z } from "zod";
import { config } from "../config.js";

// Possible campaign statuses
export const CAMPAIGN_STATUSES = [
  "PENDING_REVIEW",
  "VERIFIED",
  "DENIED",
  "LIVE",
  "PAUSED",
  "COMPLETED",
] as const;

// Supported currencies
export const CURRENCY_CODES = ["ETB", "XXX"] as const;

export const MIN_STRING_LENGTH = 3;
export const validNonEmptyString = (min: number, max: number) =>
  z
    .string()
    .min(min, { message: `Must be at least ${min} characters long` })
    .max(max, { message: `Must be no more than ${max} characters long` })
    .refine((val) => val.trim() !== "", {
      message: "Cannot be empty or contain only whitespace",
    });

const E164_PHONE_REGEX = /^\+[1-9]\d{1,14}$/;
export const validPhoneNo = () =>
  z.string().regex(E164_PHONE_REGEX, {
    message:
      "Phone number must be in E.164 format (e.g., +1234567890, max 15 digits)",
  });

export const validDate = (isPast: boolean) => {
  const comparisonDate = new Date();
  const message = isPast
    ? `Must be in the past`
    : `Must be now or in the future`;
  const comparison = isPast
    ? (date: Date) => date < comparisonDate
    : (date: Date) => date >= comparisonDate;

  return z
    .string()
    .refine((val) => !isNaN(Date.parse(val)), {
      message: "Invalid date format",
    })
    .refine((val) => comparison(new Date(val)), {
      message,
    });
};

export const validCampaignStatus = () =>
  z.enum(CAMPAIGN_STATUSES, {
    message: `Invalid campaign status. Must be one of: ${CAMPAIGN_STATUSES.join(", ")}.`,
  });

export const validUrl = () =>
  z.string().url({
    message: "Invalid URL format. Please provide a valid URL.",
  });

export const validBankAccountNo = () =>
  z
    .string()
    .trim() // Trim whitespace
    .min(10, {
      message: "Must be at least 10 digits",
    })
    .max(16, {
      message: "Must be at most 16 digits",
    })
    .refine(
      (val) => {
        const parsedValue = parseInt(val);
        return !isNaN(parsedValue) && parsedValue >= 0;
      },
      {
        message: "Must be a numeric bank account number",
      },
    );

export const validUuid = () => z.string().uuid({ message: "Invalid UUID" });

export const validMoneyAmount = () =>
  z
    .string()
    .refine(
      (val) => {
        const parsedValue = parseFloat(val);
        return (
          !isNaN(parsedValue) &&
          parsedValue >= 0 &&
          Number.isFinite(parsedValue) &&
          parsedValue.toFixed(2).replace(/\.0+$/, "") ===
            val.replace(/\.0+$/, "")
        );
      },
      {
        message:
          "Money field must be a non-negative number with up to two decimal places.",
      },
    )
    .refine((val) => parseFloat(val) < config.ALLOWED_MAX_MONEY_AMOUNT, {
      message: `Money amount specified is too large. Maximum amount allowed is ${config.ALLOWED_FILE_EXTENSIONS}.`,
    });

export const validCurrency = () =>
  z.enum(CURRENCY_CODES, {
    message: `Invalid currency code. Must be one of: ${CURRENCY_CODES.filter(
      (val) => val !== "XXX",
    ).join(", ")}.`,
  });
