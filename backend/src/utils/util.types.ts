import { z } from "zod";
import {
  CURRENCY_CODES,
  validCurrency,
  validMoneyAmount,
} from "./zod-helpers.js";

export interface PaginatedList<T> {
  items: T[];
  pageNo: number;
  pageCount: number;
}

export type CurrencyCode = (typeof CURRENCY_CODES)[number];

export interface Money {
  amount: number;
  currency: CurrencyCode;
}

// ================= Zod schemas ====================

export const moneySchema = z.object({
  amount: validMoneyAmount(),
  currency: validCurrency(),
});
