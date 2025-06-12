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
import { validUrl, validUuid } from "../utils/zod-helpers.js";
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

// TODO (bitbender-8): Add route to openapi.yml
// To be more robust, you would use an Auth0 action instead relying on calls from the
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
