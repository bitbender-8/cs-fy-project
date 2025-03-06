import { z } from "zod";

// Helpers
const E164_PHONE_REGEX = /^\+[1-9]\d{1,14}$/;

const nonEmptyString = (min: number, max: number) =>
  z
    .string()
    .min(min)
    .max(max)
    .refine((val) => val.trim() !== "", {
      message: "Field cannot be empty or contain only whitespace",
    });

// TDDO Update zod schema to complty with new type definitions.
// Schemas

export const createRecipientDtoSchema = z
  .object({
    id: z.string().uuid({ message: "Not a valid UUID" }).optional(),
    firstName: nonEmptyString(1, 50),
    middleName: nonEmptyString(1, 50),
    lastName: nonEmptyString(1, 50),
    dateOfBirth: z
      .string()
      .refine((val) => !isNaN(Date.parse(val)), {
        message: "Invalid date format",
      })
      .refine((val) => new Date(val) < new Date(), {
        message: "Date of birth must be in the past",
      }),
    email: z.string().email({ message: "Invalid email address" }).optional(),
    phoneNo: z.string().regex(E164_PHONE_REGEX, {
      message:
        "Phone number must be in E.164 format (e.g., +1234567890, max 15 digits)",
    }),
    password: z
      .string()
      .min(8, { message: "Password must be at least 8 characters long" })
      .refine((val) => val.trim() !== "", {
        message: "Password cannot be empty or contain only whitespace",
      }),
    passwordConfirmation: z
      .string()
      .min(8, {
        message: "Password confirmation must be at least 8 characters long",
      })
      .refine((val) => val.trim() !== "", {
        message:
          "Password confirmation cannot be empty or contain only whitespace",
      }),
    bio: z
      .string()
      .max(500, { message: "Bio must not exceed 500 characters" })
      .optional()
      .refine((val) => val === undefined || val.trim() !== "", {
        message: "Bio cannot contain only whitespace if provided",
      }),
    socialMediaHandles: z
      .array(
        z.object({
          id: z.string().uuid({ message: "Not a valid UUID" }).optional(),
          socialMediaHandle: z
            .string()
            .url({ message: "Handle is not a valid URL" }),
        })
      )
      .optional(),
  })
  .superRefine(({ password, passwordConfirmation }, ctx) => {
    if (password !== passwordConfirmation) {
      ctx.addIssue({
        path: ["passwordConfirmation"],
        message: "Passwords do not match.",
        code: z.ZodIssueCode.custom,
      });
    }
  });
