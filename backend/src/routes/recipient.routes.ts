import { Router, Request, Response } from "express";
import { UUID } from "crypto";

import { validateFileUpload } from "../middleware/file-upload.middleware.js";
import {
  Recipient,
  RecipientSchema,
  SENSITIVE_USER_FIELDS,
  SensitiveUserFields,
} from "../models/user.model.js";
import { ProblemDetails } from "../errors/error.types.js";
import { getUserRole, verifyAuth0UserId } from "../services/user.service.js";
import {
  getRecipients,
  getUuidFromAuth0Id,
  insertRecipient,
} from "../repositories/user.repo.js";
import { validUuid } from "../utils/zod-helpers.js";
import { excludeSensitiveProperties } from "../services/campaign.service.js";
import {
  RecipientFilterSchema,
  SENSITIVE_USER_FILTERS,
} from "../models/filters/recipient-filters.js";
import { PaginatedList } from "../utils/util.types.js";

export const recipientRouter: Router = Router();

recipientRouter.post(
  "/",
  await validateFileUpload("profilePicture"),
  async (req: Request, res: Response): Promise<void> => {
    const profilePicture = req.file;

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
    console.log(req.body);

    const parsedRecipient = RecipientSchema.safeParse(req.body);
    if (!parsedRecipient.success) {
      const problemDetails: ProblemDetails = {
        title: "Validation Failure",
        status: 400,
        detail: "One or more query params failed validation",
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
    recipient.profilePictureUrl = profilePicture
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
    const parsedId = validUuid().safeParse(req.params.id);

    if (!parsedId.success) {
      const problemDetails: ProblemDetails = {
        title: "Validation Failure",
        status: 400,
        detail: parsedId.error.issues[0].message,
      };
      res.status(problemDetails.status).json(problemDetails);
      return;
    }

    const recipientId = parsedId.data as UUID;
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
          console.log(recipient);
        } else {
          // Recipient: Public recipient data
          recipient = excludeSensitiveProperties(
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
        recipient = excludeSensitiveProperties(
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
  const publicQueryParams = excludeSensitiveProperties(
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
        excludeSensitiveProperties(recipient, SENSITIVE_USER_FIELDS)
      ),
    };
  }

  res.status(200).json(recipients);
  return;
});
