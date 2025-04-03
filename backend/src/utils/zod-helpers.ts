import { z } from "zod";
import { config } from "../config.js";

// Possible campaign statuses
export const CAMPAIGN_STATUSES = [
  "Pending Review",
  "Verified",
  "Denied",
  "Live",
  "Paused",
  "Completed",
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

const E164_PHONE_REGEX = /^\+[1-9]\d{7,14}$/;
export const validPhoneNo = () =>
  z.string().regex(E164_PHONE_REGEX, {
    message:
      "Phone number must be in E.164 format (e.g., +1234567890, 8 to 15 digits)",
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
    .transform((val) => new Date(val))
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
    .string({
      message: "Bank account number must be a string",
    })
    .regex(/^\d+$/, {
      message: "Bank account number must be numeric",
    })
    .min(10, {
      message: "Must be at least 10 digits",
    })
    .max(16, {
      message: "Must be at most 16 digits",
    });

export const validUuid = () => z.string().uuid({ message: "Invalid UUID" });

export const validMoneyAmount = () =>
  z
    .string()
    .refine(
      (val) => {
        const num = Number(val);
        return !isNaN(num) && num >= 0 && Number.isFinite(num);
      },
      { message: "Must be a valid non-negative number." },
    )
    .refine(
      (val) => {
        const [integer, decimal] = val.split(".");
        void integer;
        return !decimal || decimal.length <= 2;
      },
      { message: "Must have up to two decimal places." },
    )
    .refine((val) => Number(val) < config.MAX_MONEY_AMOUNT, {
      message: `Amount must be less than ${config.MAX_MONEY_AMOUNT}.`,
    });

export const validCurrency = () =>
  z.enum(CURRENCY_CODES, {
    message: `Invalid currency code. Must be one of: ${CURRENCY_CODES.filter(
      (val) => val !== "XXX",
    ).join(", ")}.`,
  });
