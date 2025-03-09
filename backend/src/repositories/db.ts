/* eslint-disable @typescript-eslint/no-explicit-any */
import pg, { PoolClient, QueryResult, QueryResultRow } from "pg";

const pool = new pg.Pool({
  user: process.env.DB_USER,
  host: process.env.DB_HOST,
  database: process.env.DB_NAME,
  password: process.env.DB_PASSWORD,
  port: Number(process.env.DB_PORT),
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
  params?: any[],
): Promise<QueryResult<T>> => {
  try {
    const result = await pool.query<T>(text, params);
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
