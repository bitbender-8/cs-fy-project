/* eslint-disable @typescript-eslint/no-explicit-any */
import pg, { PoolClient, QueryResult, QueryResultRow } from "pg";
import { config } from "./config.js";

const pool = new pg.Pool({
  user: config.DB_USER,
  host: config.DB_HOST,
  database: config.DB_NAME,
  password: config.DB_PASSWORD,
  port: config.DB_PORT,
});

/**
 * Executes a database query. Don't use this for transactions, use {@link getClient} instead.
 * @param text - The SQL query string.
 * @param params - The query parameters.
 * @returns A promise resolving to the query result.
 * @throws An error if the query fails.
 */
export const query = async <T extends QueryResultRow = any>(
  text: string,
  params?: any[]
): Promise<QueryResult<T>> => {
  try {
    const result = await pool.query<T>(text, params);
    return result;
  } catch (err) {
    const error = err as Error;
    error.message = "Database query error: " + error.message;
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
  } catch (err: unknown) {
    const error = err as Error;
    error.message = "Error connecting to the database: " + error.message;
    throw error;
  }
};
