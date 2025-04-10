import { z } from "zod";

import {
  CURRENCY_CODES,
  validCurrency,
  validMoneyAmount,
  validUuid,
} from "./zod-helpers.js";
import { AppError } from "../errors/error.types.js";
import { UUID } from "crypto";

export interface PaginatedList<T> {
  items: T[];
  pageNo: number;
  pageCount: number;
}

export type CurrencyCode = (typeof CURRENCY_CODES)[number];
export const MoneySchema = z.object({
  amount: validMoneyAmount(),
  currency: validCurrency(),
});
export type Money = z.infer<typeof MoneySchema>;

/**
 * Converts a money string (e.g., "123.45") to a bigint representing the amount in cents.
 *
 * @param moneyAmount The money string to convert.
 * @returns The bigint representation of the amount in cents, or null if the input is invalid.
 * Returns null if the input contains non-numeric and non-dot characters,
 * has more than one decimal point, or has more than two decimal places.
 */
export function fromMoneyStrToBigInt(moneyAmount: string): bigint | null {
  if (!/^[0-9.]+$/.test(moneyAmount)) {
    return null; // Fail if non-numeric or non-dot characters are present
  }

  const parts = moneyAmount.split(".");

  if (parts.length > 2) {
    return null; // Invalid format: more than one decimal point
  }

  const integerPart = parts[0] || "0";
  const decimalPart = parts[1] || "00";

  if (decimalPart.length > 2) {
    return null; // Invalid format: more than two decimal places
  }

  const paddedDecimalPart = decimalPart.padEnd(2, "0");

  const combinedString = integerPart + paddedDecimalPart;

  try {
    return BigInt(combinedString);
  } catch (error: unknown) {
    console.error("Error converting money to int:", error);
    return null;
  }
}

/**
 * Converts a bigint representing an amount in cents to a money string (e.g., "123.45").
 *
 * @param moneyAmount The bigint representing the amount in cents.
 * @returns The money string representation of the amount, or null if the input is invalid.
 * Returns null if the input is not a bigint.
 */
export function fromIntToMoneyStr(moneyAmount: bigint): string | null {
  if (typeof moneyAmount !== "bigint") {
    return null; // Handle invalid input type
  }

  const amountStr = moneyAmount.toString();
  const length = amountStr.length;

  if (length <= 2) {
    return `0.${amountStr.padStart(2, "0")}`;
  }

  const integerPart = amountStr.slice(0, length - 2);
  const decimalPart = amountStr.slice(length - 2);

  return `${integerPart}.${decimalPart}`;
}

export function validateUuidParam(
  id: string,
  paramType: "path" | "query" = "path",
  paramName?: string,
): UUID {
  if (!id) {
    throw new AppError(
      "Validation Failure",
      400,
      `The ${paramType} parameter ${paramName} is required`,
    );
  }

  const parsedId = validUuid().safeParse(id);

  if (!parsedId.success) {
    throw new AppError(
      "Validation Failure",
      400,
      `Value provided for ${paramType} parameter ${paramName ? paramName : "ID"} is not a valid UUID`,
    );
  }

  return parsedId.data as UUID;
}

export function excludeProperties<T, K extends keyof T>(
  object: T,
  sensitiveFields: readonly K[],
): Omit<T, K> {
  const newObject: T = { ...object };

  for (const field of sensitiveFields) {
    delete newObject[field];
  }

  return newObject;
}
