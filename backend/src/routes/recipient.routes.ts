import { Router, Request, Response } from "express";

import {
  Recipient,
  RecipientSchema,
  SensitiveUserFields,
  LOCKED_USER_FIELDS,
  SENSITIVE_USER_FIELDS,
} from "../models/user.model.js";
import {
  getRecipients,
  insertRecipient,
  updateRecipient,
  getUuidFromAuth0Id,
  deleteRecipient,
} from "../repositories/user.repo.js";
import {
  RecipientFilterSchema,
  SENSITIVE_USER_FILTERS,
} from "../models/filters/recipient-filters.js";
import { excludeProperties } from "../utils/utils.js";
import { ProblemDetails } from "../errors/error.types.js";
import { PaginatedList, validateUUIDParam } from "../utils/utils.js";
import { getUserRole, verifyAuth0UserId } from "../services/user.service.js";
import { validateFileUpload } from "../middleware/file-upload.middleware.js";

export const recipientRouter: Router = Router();

recipientRouter.post(
  "/",
  await validateFileUpload("profilePicture"),
  async (req: Request, res: Response): Promise<void> => {
    // Validate recipient data
    if (!req.body) {
      const problemDetails: ProblemDetails = {
        title: "Validation Failure",
        status: 400,
        detail: "Recipient body cannot be empty",
      };
      res.status(problemDetails.status).json(problemDetails);
      return;
    }

    const parsedRecipient = RecipientSchema.safeParse(req.body);
    if (!parsedRecipient.success) {
      const problemDetails: ProblemDetails = {
        title: "Validation Failure",
        status: 400,
        detail: "One or more recipient fields failed validation",
        fieldFailures: parsedRecipient.error.issues.map((issue) => ({
          field: issue.path.join("."),
          uiMessage: issue.message,
        })),
      };
      res.status(problemDetails.status).json(problemDetails);
      return;
    }

    // Verify the recipient's auth0 user ID
    const recipient = parsedRecipient.data as Recipient;
    const auth0User = await verifyAuth0UserId(recipient.auth0UserId as string);
    recipient.email = auth0User.email;
    recipient.profilePictureUrl = req.file
      ? `${process.env.UPLOAD_DIR}/${req?.file?.filename}`
      : undefined;

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

recipientRouter.get(
  "/:id",
  async (req: Request, res: Response): Promise<void> => {
    const recipientId = validateUUIDParam(req.params.id);
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

recipientRouter.get("/", async (req: Request, res: Response): Promise<void> => {
  const parsedQueryParams = RecipientFilterSchema.safeParse(req.query);

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

  let recipients:
    | PaginatedList<Recipient>
    | PaginatedList<Omit<Recipient, SensitiveUserFields>>;

  if (getUserRole(req.auth) === "Supervisor") {
    // Supervisor: full access
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
});

recipientRouter.put(
  "/:id",
  await validateFileUpload("profilePicture"),
  async (req: Request, res: Response): Promise<void> => {
    if (getUserRole(req.auth) === "Recipient") {
      const recipientId = validateUUIDParam(req.params.id);

      // Check that the authenticatd recipient owns the data they are trying to modify
      const recipientIdFromJwt = await getUuidFromAuth0Id(
        req.auth?.payload.sub ?? ""
      );

      if (recipientId !== recipientIdFromJwt) {
        const problemDetails: ProblemDetails = {
          title: "Permission Denied",
          status: 403,
          detail: "You do not have permission to update this recipient",
        };
        res.status(problemDetails.status).json(problemDetails);
        return;
      }

      // Validate recipient data
      if (!req.body || Object.keys(req.body).length === 0) {
        const problemDetails: ProblemDetails = {
          title: "Validation Failure",
          status: 400,
          detail: "Recipient body cannot be empty",
        };
        res.status(problemDetails.status).json(problemDetails);
        return;
      }

      const parsedRecipient = RecipientSchema.partial().safeParse(req.body);
      if (!parsedRecipient.success) {
        const problemDetails: ProblemDetails = {
          title: "Validation Failure",
          status: 400,
          detail: "One or more recipient fields failed validation",
          fieldFailures: parsedRecipient.error.issues.map((issue) => ({
            field: issue.path.join("."),
            uiMessage: issue.message,
          })),
        };
        res.status(problemDetails.status).json(problemDetails);
        return;
      }
      console.log(parsedRecipient.data);

      // A user can't update their email or phone number. This is because we have to update the auth0 entry as well. We will add it later if we have to.
      await updateRecipient(
        recipientId,
        excludeProperties(parsedRecipient.data as Recipient, LOCKED_USER_FIELDS)
      );

      res.status(204).send();
      return;
    } else {
      const problemDetails: ProblemDetails = {
        title: "Permission Denied",
        status: 403,
        detail: "You do not have permission to update this recipient",
      };
      res.status(problemDetails.status).json(problemDetails);
      return;
    }
  }
);

recipientRouter.delete(
  "/:id",
  async (req: Request, res: Response): Promise<void> => {
    const recipientId = validateUUIDParam(req.params.id);
    let isRecipientDeleted = false;

    switch (getUserRole(req.auth)) {
      case "Supervisor":
        // Supervisor: full access
        isRecipientDeleted = await deleteRecipient(recipientId);
        break;
      case "Recipient": {
        const userIdFromJwt = await getUuidFromAuth0Id(
          req.auth?.payload.sub ?? ""
        );

        // Recipient: full access only if they own the data
        if (userIdFromJwt === recipientId) {
          isRecipientDeleted = await deleteRecipient(recipientId);
        } else {
          const problemDetails: ProblemDetails = {
            title: "Permission Denied",
            status: 403,
            detail: "You do not have permission to delete this recipient.",
          };
          res.status(problemDetails.status).json(problemDetails);
          return;
        }
        break;
      }
      default: {
        const problemDetails: ProblemDetails = {
          title: "Permission Denied",
          status: 403,
          detail: "You do not have permission to delete recipients.",
        };
        res.status(problemDetails.status).json(problemDetails);
        return;
      }
    }

    if (!isRecipientDeleted) {
      const problemDetails: ProblemDetails = {
        title: "Not Found",
        status: 404,
        detail: "Recipient with given ID not found",
      };
      res.status(problemDetails.status).json(problemDetails);
      return;
    }

    res.status(204).send();
  }
);
