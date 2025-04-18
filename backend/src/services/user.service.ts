import { JWTPayload } from "express-oauth2-jwt-bearer";

import { config } from "../config.js";
import { UserType } from "../models/user.model.js";
import axios from "axios";
import { AppError } from "../errors/error.types.js";
import { objectToCamel } from "ts-case-convert";

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

export async function deleteAuth0User(auth0UserId: string): Promise<void> {
  const options = {
    method: "DELETE",
    url: `${config.ISSUER_BASE_URL}/api/v2/users/${auth0UserId}`,
    headers: { authorization: `Bearer ${config.MANAGEMENT_ACCESS_TOKEN}` },
  };

  try {
    console.log(await axios.request(options));

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
            "Failed to verify user ID",
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

export async function verifyAuth0UserId(
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
              internalDetails: `User ID verification failed due to a bad request.
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
