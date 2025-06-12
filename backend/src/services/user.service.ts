import { JWTPayload } from "express-oauth2-jwt-bearer";

import { config } from "../config.js";
import { UserType } from "../models/user.model.js";
import axios from "axios";
import { AppError } from "../errors/error.types.js";
import { objectToCamel } from "ts-case-convert";

const userTypeToRoleId: Record<UserType, string> = {
  Recipient: config.RECIPIENT_ROLE_ID,
  Supervisor: config.SUPERVISOR_ROLE_ID,
};

/**
 * Extracts the user's role from an OAuth2 JWT payload.
 * The role is expected to be in a custom claim specified by `config.AUTH0_NAMESPACE`.
 *
 * @param {JWTPayload | undefined} authToken - The JWT payload from an authenticated request.
 * @returns {UserType | undefined} The user's role (e.g., "Recipient", "Supervisor") or undefined if no role is found or the token is invalid.
 */
export function getUserRole(authToken?: {
  payload: JWTPayload;
}): UserType | undefined {
  if (!authToken || !authToken.payload) {
    return undefined; // No auth token or payload, so no role.
  }

  const roles = authToken.payload[`${config.AUTH0_NAMESPACE}/roles`];

  if (!Array.isArray(roles) || roles.length === 0) {
    return undefined; // Roles are not an array or are empty.
  }

  const firstRole = roles[0];

  // Validate the type of the first element.
  if (typeof firstRole === "string") {
    return firstRole as UserType; // Safe type assertion after validation.
  }

  return undefined; // First element is not a string, hence not a valid role.
}

/**
 * @typedef {object} Auth0UserResponse
 * @description Represents the structure of a user object as returned by the Auth0 Management API.
 * Note: Property names in this type are in camelCase after transformation from the snake_case used by the Auth0 API.
 * For detailed and up-to-date information on the user object structure,
 * please refer to the official Auth0 Management API documentation regarding user objects.
 */
type Auth0UserResponse = {
  createdAt: string;
  email: string;
  emailVerified: boolean;
  identities: {
    connection: string;
    provider: string;
    userId: string;
    isSocial: boolean;
  }[];
  name: string;
  updatedAt: string;
  userId: string;
  lastLogin: string;
  loginsCount: number;
};

/**
 * Deletes a user from Auth0.
 *
 * @param {string} auth0UserId - The Auth0 ID of the user to delete.
 * @returns {Promise<void>} A promise that resolves when the user has been successfully deleted from Auth0.
 * @throws {AppError} If the Auth0 API request fails (e.g., user not found, authentication issues, service unavailable).
 *                    The error will contain details about the failure.
 */
export async function deleteAuth0User(auth0UserId: string): Promise<void> {
  const options = {
    method: "DELETE",
    url: `${config.ISSUER_BASE_URL}/api/v2/users/${auth0UserId}`,
    headers: { authorization: `Bearer ${config.MANAGEMENT_ACCESS_TOKEN}` },
  };

  try {
    const result = await axios.request(options);
    console.log(result.data);
    return;
  } catch (error: unknown) {
    // You can find details here: https://axios-http.com/docs/handling_errors
    if (!axios.isAxiosError(error)) {
      throw error;
    }

    if (error.response) {
      // Request made, but server responds with StatusCode > 2xx
      switch (error.response.status) {
        case 404:
          throw new AppError(
            "Validation Failure",
            400,
            "Failed to verify auth0 user ID",
            {
              internalDetails: `The authentication server could not find the user with the id '${auth0UserId}'.
              Status: ${JSON.stringify(error.response.data)}
              Response: ${JSON.stringify(error.response.data)}`,
              cause: error,
            },
          );
        case 400:
        case 401:
        case 403:
          throw new AppError(
            "Internal Server Error",
            500,
            "Something went wrong",
            {
              internalDetails: `User deletion from the authentication server failed due to a bad request.
              Status: ${JSON.stringify(error.response.data)}
              Response: ${JSON.stringify(error.response.data)}`,
              cause: error,
            },
          );
        case 500:
        case 503:
          throw new AppError(
            "Service Unavailable",
            503,
            "Authentication service is temporarily unavailable",
            {
              internalDetails: `User deletion failed due to an unexpected error from the authentication server.
              Status: ${JSON.stringify(error.response.status)}
              Response: ${JSON.stringify(error.response.data)}`,
              cause: error,
            },
          );
        default:
          throw new AppError(
            "Internal Server Error",
            500,
            "Something went wrong",
            {
              internalDetails: `User deletion from the authentication server failed due to an unexpected error.
              Status: ${JSON.stringify(error.response.data)}
              Response: ${JSON.stringify(error.response.data)}`,
              cause: error,
            },
          );
      }
    } else if (error.request) {
      // Request made, but no response received
      throw new AppError(
        "Service Unavailable",
        503,
        "Authentication service is temporarily unavailable",
        {
          internalDetails:
            "No response was received from the Auth0 authentication server.",
          cause: error,
        },
      );
    } else {
      // Something went wrong while setting up the request
      throw new AppError("Internal Server Error", 500, "Something went wrong", {
        internalDetails:
          "An error occurred while setting up the deletion request for the authentication server.",
        cause: error,
      });
    }
  }
}

/**
 * Retrieves a user's profile from Auth0.
 *
 * @param {string} auth0UserId - The Auth0 ID of the user to retrieve.
 * @returns {Promise<Auth0UserResponse>} A promise that resolves with the user's Auth0 profile information.
 * @throws {AppError} If the Auth0 API request fails (e.g., user not found, authentication issues, service unavailable).
 *                    The error will contain details about the failure.
 */
export async function getAuth0User(
  auth0UserId: string,
): Promise<Auth0UserResponse> {
  const options = {
    method: "GET",
    url: `${config.ISSUER_BASE_URL}/api/v2/users/${auth0UserId}`,
    headers: { authorization: `Bearer ${config.MANAGEMENT_ACCESS_TOKEN}` },
  };

  try {
    const response = await axios.request<Auth0UserResponse>(options);

    return objectToCamel(response.data);
  } catch (error: unknown) {
    // You can find details here: https://axios-http.com/docs/handling_errors
    if (!axios.isAxiosError(error)) {
      throw error;
    }

    if (error.response) {
      // Request made, but server responds with StatusCode > 2xx
      switch (error.response.status) {
        case 404:
          throw new AppError(
            "Validation Failure",
            400,
            "Failed to verify user ID",
            {
              internalDetails: `The authentication server could not find the user with the ID '${auth0UserId}'
              Status: ${JSON.stringify(error.response.status)}
              Response: ${JSON.stringify(error.response.data)}`,
              cause: error,
            },
          );
        case 400:
        case 401:
        case 403:
          throw new AppError(
            "Internal Server Error",
            500,
            "Something went wrong",
            {
              internalDetails: `User ID verification failed due to a bad request.
              Status: ${JSON.stringify(error.response.status)}
              Response: ${JSON.stringify(error.response.data)}`,
              cause: error,
            },
          );
        case 500:
        case 503:
          throw new AppError(
            "Service Unavailable",
            503,
            "Authentication service is temporarily unavailable",
            {
              internalDetails: `Status: ${error.response.status},
              Message: ${JSON.stringify(error.response.data)}`,
              cause: error,
            },
          );
        default:
          throw new AppError(
            "Internal Server Error",
            500,
            "Something went wrong",
            {
              internalDetails: `User ID verification failed due to an unexpected error from the authentication server.
              Status: ${error.response.status},
              Message: ${JSON.stringify(error.response.data)}`,
              cause: error,
            },
          );
      }
    } else if (error.request) {
      // Request made, but no response received
      throw new AppError(
        "Service Unavailable",
        503,
        "Authentication service is temporarily unavailable",
        {
          internalDetails: `No response was received from the authentication server.
          Message: ${error.message}`,
          cause: error,
        },
      );
    } else {
      // Something went wrong while setting up the request
      throw new AppError("Internal Server Error", 500, "Something went wrong", {
        internalDetails:
          "An error occurred while setting up the verification request for the authentication server.",
        cause: error,
      });
    }
  }
}

/**
 * Assigns a specific role to a user in Auth0.
 *
 * @param {string} auth0UserId - The Auth0 ID of the user to whom the role will be assigned.
 * @param {UserType} role - The role to assign (e.g., "Recipient", "Supervisor").
 * @returns {Promise<void>} A promise that resolves when the role has been successfully assigned in Auth0.
 * @throws {AppError} If no Auth0 role ID is mapped for the given `UserType`, or if the Auth0 API request fails
 *                    (e.g., user/role not found, authentication issues, service unavailable). The error will contain details about the failure.
 */
export async function assignRoleToAuth0User(
  auth0UserId: string,
  role: UserType,
) {
  const roleId = userTypeToRoleId[role];
  if (!roleId) {
    throw new AppError(
      "Validation Failure",
      400,
      `No Auth0 role mapping found for user type: ${role}`,
      { internalDetails: `UserType: ${role}` },
    );
  }

  const options = {
    method: "POST",
    url: `${config.ISSUER_BASE_URL}/api/v2/users/${auth0UserId}/roles`,
    headers: {
      authorization: `Bearer ${config.MANAGEMENT_ACCESS_TOKEN}`,
      "content-type": "application/json",
      "cache-control": "no-cache",
    },
    data: {
      roles: [roleId],
    },
  };

  try {
    console.log((await axios.request(options)).data);
  } catch (error) {
    if (!axios.isAxiosError(error)) {
      throw error;
    }

    if (error.response) {
      switch (error.response.status) {
        case 400:
        case 401:
        case 403:
          throw new AppError(
            "Internal Server Error",
            500,
            "Failed to assign role to user",
            {
              internalDetails: `Role assignment failed due to a bad request or insufficient permissions.
              Status: ${JSON.stringify(error.response.status)}
              Response: ${JSON.stringify(error.response.data)}`,
              cause: error,
            },
          );
        case 404:
          throw new AppError("Not Found", 404, "User not found in Auth0", {
            internalDetails: `The authentication server could not find the user or role.
              Status: ${JSON.stringify(error.response.status)}
              Response: ${JSON.stringify(error.response.data)}`,
            cause: error,
          });
        case 500:
        case 503:
          throw new AppError(
            "Service Unavailable",
            503,
            "Authentication service is temporarily unavailable",
            {
              internalDetails: `Status: ${error.response.status},
              Message: ${JSON.stringify(error.response.data)}`,
              cause: error,
            },
          );
        default:
          throw new AppError(
            "Internal Server Error",
            500,
            "Something went wrong while assigning role",
            {
              internalDetails: `Role assignment failed due to an unexpected error from the authentication server.
              Status: ${error.response.status},
              Message: ${JSON.stringify(error.response.data)}`,
              cause: error,
            },
          );
      }
    } else if (error.request) {
      throw new AppError(
        "Service Unavailable",
        503,
        "Authentication service is temporarily unavailable",
        {
          internalDetails: `No response was received from the authentication server.
          Message: ${error.message}`,
          cause: error,
        },
      );
    } else {
      throw new AppError("Internal Server Error", 500, "Something went wrong", {
        internalDetails:
          "An error occurred while setting up the role assignment request for the authentication server.",
        cause: error,
      });
    }
  }
}
