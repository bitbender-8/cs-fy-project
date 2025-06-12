import { Request, Response, Router } from "express";
import { z } from "zod";

import {
  SENSITIVE_USER_FILTERS,
  UserFilterSchema,
} from "../models/filters/user-filters.js";
import { ProblemDetails } from "../errors/error.types.js";
import {
  excludeProperties,
  PaginatedList,
  validateUuidParam,
} from "../utils/utils.js";
import {
  LOCKED_USER_FIELDS,
  LockedUserFields,
  Recipient,
  RecipientSchema,
  SENSITIVE_USER_FIELDS,
  SensitiveUserFields,
  SocialMediaHandle,
  SocialMediaHandleSchema,
} from "../models/user.model.js";
import {
  deleteAuth0User,
  getUserRole,
  getAuth0User,
  assignRoleToAuth0User,
} from "../services/user.service.js";
import {
  deleteRecipient,
  getRecipients,
  getUuidFromAuth0Id,
  insertRecipient,
  updateRecipient,
} from "../repositories/user.repo.js";
import { validateFileUpload } from "../middleware/file-upload.middleware.js";
import { validateRequestBody } from "../middleware/request-body.middleware.js";
import { optionalAuth, requireAuth } from "../middleware/auth.middleware.js";
import { validUuid } from "../utils/zod-helpers.js";
import { config } from "../config.js";
import { deleteFiles } from "../services/fie.service.js";
import path from "path";

export const recipientRouter: Router = Router();

// A user can't update their email or phone number. This is because we have to update the auth0 entry as well. We will add it later if we have to. This Removes non-updateable fields from the recipient schema
const recipientUpdateSchema = RecipientSchema.omit({
  ...LOCKED_USER_FIELDS.reduce(
    (acc, field) => ({ ...acc, [field]: true }),
    {} as { [key in LockedUserFields]: true }
  ),
  socialMediaHandles: true,
}).extend({
  socialMediaHandles: z
    .array(
      SocialMediaHandleSchema.extend({
        id: validUuid().optional(),
      })
    )
    .optional(),
});

const recipientCreateSchema = RecipientSchema.omit({
  id: true,
  email: true,
  auth0UserId: true,
  socialMediaHandles: true,
  profilePictureUrl: true,
}).extend({
  socialMediaHandles: z
    .array(
      SocialMediaHandleSchema.extend({
        id: validUuid().optional(),
        recipientId: validUuid().optional(),
      })
    )
    .optional(),
});

const profilePictureDir = config.PUBLIC_UPLOAD_DIR;

/**
 * @route POST /recipients
 * @description Creates a new recipient profile.
 * The user must be authenticated. Their Auth0 user will be assigned the "Recipient" role.
 * A profile picture can be uploaded.
 *
 * @param {Request} req - Express request object. Expects recipient data in `req.body` (conforming to `recipientCreateSchema`) and an optional `profilePicture` in `req.file`.
 * @param {Response} res - Express response object.
 * @returns {Response} 201 - The created recipient object with a Location header.
 * @returns {Response} 400 - If request body validation or file upload validation fails.
 * @returns {Response} 401 - If the user is not authenticated.
 */
recipientRouter.post(
  "/",
  requireAuth,
  validateFileUpload("profilePicture", "Images", profilePictureDir, 1),
  validateRequestBody(recipientCreateSchema),
  async (req: Request, res: Response): Promise<void> => {
    const auth0UserIdFromJwt = req.auth?.payload.sub ?? "";
    const auth0User = await getAuth0User(auth0UserIdFromJwt as string);

    await assignRoleToAuth0User(auth0UserIdFromJwt, "Recipient");

    // Validated recipient data from middleware
    const recipientData = req.body as z.infer<typeof recipientCreateSchema>;
    const recipient: Omit<Recipient, "id"> = {
      ...recipientData,
      email: auth0User.email,
      auth0UserId: auth0User.userId,
      socialMediaHandles: recipientData.socialMediaHandles?.map((value) => {
        return {
          socialMediaHandle: value.socialMediaHandle,
        } as SocialMediaHandle;
      }),
      profilePictureUrl: req.file ? `${req.file.filename}` : undefined,
    };

    // Store recipient in DB
    const insertedRecipient = await insertRecipient(recipient);
    res
      .set(
        "Location",
        `${req.protocol}://${req.get("host")}/recipients/${insertedRecipient.id}`
      )
      .status(201)
      .json(insertedRecipient);
    return;
  }
);

/**
 * @route PUT /recipients/:id
 * @description Updates an existing recipient profile.
 * Recipients can only update their own profiles.
 * A new profile picture can be uploaded, replacing the old one. If `profilePictureUrl` is set to `null` in the body, the existing picture will be removed.
 *
 * @param {string} req.params.id - The UUID of the recipient to update.
 * @param {Request} req - Express request object. Expects recipient update data in `req.body` (conforming to `recipientUpdateSchema`) and an optional `profilePicture` in `req.file`.
 * @param {Response} res - Express response object.
 * @returns {Response} 204 - If the recipient was successfully updated.
 * @returns {Response} 400 - If request body validation or file upload validation fails.
 * @returns {Response} 401 - If the user is not authenticated.
 * @returns {Response} 403 - If the user is not a recipient or does not own the profile being updated.
 * @returns {Response} 404 - If the recipient with the given ID is not found.
 */
recipientRouter.put(
  "/:id",
  requireAuth,
  validateFileUpload("profilePicture", "Images", profilePictureDir, 1),
  validateRequestBody(recipientUpdateSchema),
  async (req: Request, res: Response): Promise<void> => {
    if (getUserRole(req.auth) !== "Recipient") {
      const problemDetails: ProblemDetails = {
        title: "Permission Denied",
        status: 403,
        detail: "You do not have permission to access this resource",
      };
      res.status(problemDetails.status).json(problemDetails);
      return;
    }

    const recipientId = validateUuidParam(req.params.id);
    const existingRecipient = (await getRecipients({ id: recipientId }))
      .items[0];
    if (!existingRecipient || Object.keys(existingRecipient).length === 0) {
      const problemDetails: ProblemDetails = {
        title: "Not Found",
        status: 404,
        detail: `Recipient with id ${recipientId} was not found.`,
      };
      res.status(problemDetails.status).json(problemDetails);
      return;
    }

    const recipientIdFromJwt = await getUuidFromAuth0Id(
      req.auth?.payload.sub ?? ""
    );
    // Check that the authenticated recipient owns the data they are trying to modify
    if (recipientId !== recipientIdFromJwt) {
      const problemDetails: ProblemDetails = {
        title: "Permission Denied",
        status: 403,
        detail: "You do not have permission to update this recipient",
      };
      res.status(problemDetails.status).json(problemDetails);
      return;
    }

    const recipientUpdateData: Omit<Recipient, LockedUserFields> = req.body;

    let oldProfilePictureUrl: string | undefined;

    if (req.file) {
      recipientUpdateData.profilePictureUrl = req.file.filename;
      oldProfilePictureUrl = existingRecipient.profilePictureUrl;
    } else if (recipientUpdateData.profilePictureUrl === null) {
      oldProfilePictureUrl = existingRecipient.profilePictureUrl;
    }

    await updateRecipient(recipientId, recipientUpdateData);

    if (oldProfilePictureUrl && !oldProfilePictureUrl.startsWith("http")) {
      await deleteFiles([
        path.join(config.PUBLIC_UPLOAD_DIR, oldProfilePictureUrl),
      ]);
    }

    res.status(204).send();
    return;
  }
);

/**
 * @route GET /recipients
 * @description Retrieves a paginated list of recipients based on filter criteria.
 * Access to sensitive recipient information is restricted:
 * - Supervisors see all data for all recipients.
 * - Authenticated recipients see all data for their own profile if `auth0UserId` filter matches their ID.
 * - Otherwise, only public recipient data is returned.
 * @param {Request} req - Express request object, expects query parameters for filtering (conforming to `UserFilterSchema`).
 * @param {Response} res - Express response object.
 * @returns {Response} 200 - A paginated list of recipients (full or redacted based on permissions).
 * @returns {Response} 400 - If query parameter validation fails.
 */
recipientRouter.get(
  "/",
  optionalAuth,
  async (req: Request, res: Response): Promise<void> => {
    const parsedQueryParams = UserFilterSchema.safeParse(req.query);

    if (!parsedQueryParams.success) {
      const problemDetails: ProblemDetails = {
        title: "Validation Failure",
        status: 400,
        detail: "One or more query params failed validation",
        fieldFailures: parsedQueryParams.error.issues.map((issue) => ({
          field: issue.path.join("."),
          uiMessage: issue.message,
        })),
      };
      res.status(problemDetails.status).json(problemDetails);
      return;
    }

    // Create filter params with sensitive filters omitted
    const queryParams = parsedQueryParams.data;
    const publicQueryParams = excludeProperties(
      queryParams,
      SENSITIVE_USER_FILTERS
    );
    const auth0UserIdFromJwt = req.auth?.payload.sub ?? "";

    let recipients:
      | PaginatedList<Recipient>
      | PaginatedList<Omit<Recipient, SensitiveUserFields>>;

    if (
      getUserRole(req.auth) === "Supervisor" ||
      (getUserRole(req.auth) === "Recipient" &&
        queryParams.auth0UserId === auth0UserIdFromJwt)
    ) {
      // Supervisor and Account owners: full access
      recipients = await getRecipients(queryParams);
    } else {
      // Everyone else has access to public recipient data
      const result = await getRecipients(publicQueryParams);
      recipients = {
        ...result,
        items: result.items.map((recipient) =>
          excludeProperties(recipient, SENSITIVE_USER_FIELDS)
        ),
      };
    }

    res.status(200).json(recipients);
    return;
  }
);

/**
 * @route GET /recipients/:id
 * @description Retrieves a single recipient by their ID.
 * Access to sensitive recipient information is restricted:
 * - Supervisors see all data for the recipient.
 * - Authenticated recipients see all data if the requested ID matches their own profile.
 * - Otherwise, only public recipient data is returned.
 *
 * @param {string} req.params.id - The UUID of the recipient to retrieve.
 * @param {Request} req - Express request object.
 * @param {Response} res - Express response object.
 * @returns {Response} 200 - The recipient object (full or redacted based on permissions).
 * @returns {Response} 404 - If the recipient with the given ID is not found.
 */
recipientRouter.get(
  "/:id",
  optionalAuth,
  async (req: Request, res: Response): Promise<void> => {
    const recipientId = validateUuidParam(req.params.id);
    let recipient: Recipient | Omit<Recipient, SensitiveUserFields>;

    switch (getUserRole(req.auth)) {
      case "Supervisor":
        // Supervisor: Full access
        recipient = (await getRecipients({ id: recipientId })).items[0];
        break;
      case "Recipient": {
        const userIdFromJwt = await getUuidFromAuth0Id(
          req.auth?.payload.sub ?? ""
        );

        if (userIdFromJwt === recipientId) {
          // Recipient: Own recipient data
          recipient = (
            await getRecipients({
              id: recipientId,
            })
          ).items[0];
        } else {
          // Recipient: Public recipient data
          recipient = excludeProperties(
            (
              await getRecipients({
                id: recipientId,
              })
            ).items[0],
            SENSITIVE_USER_FIELDS
          );
        }
        break;
      }
      default:
        // Public recipient data
        recipient = excludeProperties(
          (
            await getRecipients({
              id: recipientId,
            })
          ).items[0],
          SENSITIVE_USER_FIELDS
        );
    }

    if (!recipient || Object.keys(recipient).length === 0) {
      const problemDetails: ProblemDetails = {
        title: "Not Found",
        status: 404,
        detail: "Recipient not found.",
      };
      res.status(problemDetails.status).json(problemDetails);
    } else {
      res.status(200).json(recipient);
    }

    return;
  }
);

/**
 * @route DELETE /recipients/:id
 * @description Deletes a recipient profile and their associated Auth0 user.
 * - Supervisors can delete any recipient.
 * - Recipients can only delete their own profiles.
 *
 * @param {string} req.params.id - The UUID of the recipient to delete.
 * @param {Request} req - Express request object.
 * @param {Response} res - Express response object.
 * @returns {Response} 204 - If the recipient was successfully deleted.
 * @returns {Response} 401 - If the user is not authenticated.
 * @returns {Response} 403 - If the user does not have permission to delete this recipient.
 * @returns {Response} 404 - If the recipient with the given ID is not found.
 */
recipientRouter.delete(
  "/:id",
  requireAuth,
  async (req: Request, res: Response): Promise<void> => {
    const recipientId = validateUuidParam(req.params.id);
    const auth0UserIdFromJwt = req.auth?.payload.sub ?? "";
    let deleteResult: boolean;

    switch (getUserRole(req.auth)) {
      case "Supervisor":
        // Supervisor: full access
        await deleteAuth0User(auth0UserIdFromJwt);
        deleteResult = await deleteRecipient(recipientId);

        break;
      case "Recipient": {
        // Recipient: full access only if they own the data
        if ((await getUuidFromAuth0Id(auth0UserIdFromJwt)) !== recipientId) {
          const problemDetails: ProblemDetails = {
            title: "Permission Denied",
            status: 403,
            detail: "You do not have permission to delete this recipient",
          };
          res.status(problemDetails.status).json(problemDetails);
          return;
        }

        await deleteAuth0User(auth0UserIdFromJwt);
        deleteResult = await deleteRecipient(recipientId);

        break;
      }
      default: {
        const problemDetails: ProblemDetails = {
          title: "Permission Denied",
          status: 403,
          detail: "You do not have permission to access this resource",
        };
        res.status(problemDetails.status).json(problemDetails);
        return;
      }
    }

    if (!deleteResult) {
      const problemDetails: ProblemDetails = {
        title: "Not Found",
        status: 404,
        detail: `Recipient with id '${recipientId}' was not found`,
      };
      res.status(problemDetails.status).json(problemDetails);
      return;
    }

    res.status(204).send();
  }
);

/**
 * @route DELETE /recipients/auth0/:auth0UserId
 * @description Deletes an Auth0 user account.
 * Users can only delete their own Auth0 account. This is typically used to allow users to delete their account entirely.
 *
 * @param {string} req.params.auth0UserId - The Auth0 User ID of the account to delete.
 * @param {Request} req - Express request object.
 * @param {Response} res - Express response object.
 * @returns {Response} 204 - If the Auth0 user was successfully deleted.
 * @returns {Response} 401 - If the user is not authenticated.
 * @returns {Response} 403 - If the authenticated user tries to delete an Auth0 account other than their own.
 */
recipientRouter.delete(
  "/auth0/:auth0UserId",
  requireAuth,
  async (req: Request, res: Response): Promise<void> => {
    const auth0UserId = req.params.auth0UserId;
    const auth0UserIdFromJwt = req.auth?.payload.sub ?? "";

    // Only allow deleting own Auth0 account
    if (auth0UserIdFromJwt !== auth0UserId) {
      res.status(403).json({
        title: "Permission Denied",
        status: 403,
        detail: "You can only delete your own Auth0 account.",
      });
      return;
    }

    await deleteAuth0User(auth0UserId);
    res.status(204).send();
  }
);
