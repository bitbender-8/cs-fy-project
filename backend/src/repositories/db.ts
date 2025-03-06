/* eslint-disable @typescript-eslint/no-explicit-any */
import { Pool, QueryResult, PoolClient } from "pg";

const pool = new Pool();

/**
 * Executes a database query. Don't use this for transactions, use {@link getClient} instead.
 * @param text - The SQL query string.
 * @param params - The query parameters.
 * @returns A promise resolving to the query result.
 * @throws An error if the query fails.
 */
export const query = async (
  text: string,
  params?: any[]
): Promise<QueryResult> => {
  try {
    const result = await pool.query(text, params);
    return result;
  } catch (error) {
    console.error("Database query error:", error);
    throw error;
  }
};

/**
 * Retrieves a database client for transactions.
 * @returns A promise resolving to a database client.
 * @throws An error if connecting to the database fails.
 */
export const getClient = async (): Promise<PoolClient> => {
  try {
    const client = await pool.connect();
    return client;
  } catch (error) {
    console.error("Error connecting to database:", error);
    throw error;
  }
};
