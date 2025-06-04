import fs from "fs";
import path from "path";
import multer, { MulterError } from "multer";
import { randomUUID } from "crypto";
import * as fileType from "file-type";
import { NextFunction, Request, Response } from "express";

import { AppError } from "../errors/error.types.js";
import { config } from "../config.js";

/**
 * Middleware to validate and handle multiple file uploads.
 *
 * @param fileFieldName - The field name for the file uploads (e.g., 'images', 'documents').
 * @param expectedFileTypes - "Images" | "Files" | "Both"
 * @param maxFileCount - The maximum number of files allowed to be uploaded.
 * @returns - An Express middleware function.
 */
export function validateFileUpload(
  fileFieldName: string,
  expectedFileTypes: "Images" | "Files" | "Both",
  destinationPath: string,
  maxFileCount: number = config.MAX_FILE_NO,
) {
  const upload = multer({
    storage: multer.diskStorage({
      destination: (req, file, cb) => {
        if (!fs.existsSync(destinationPath)) {
          fs.mkdirSync(destinationPath, { recursive: true });
        }
        cb(null, destinationPath);
      },
      filename: (req, file, cb) => {
        const ext = path.extname(file.originalname);
        cb(null, `${randomUUID()}${ext}`);
      },
    }),
  });

  return async (req: Request, res: Response, next: NextFunction) => {
    // Check if request contains multipart/form-data
    if (
      req.headers["content-type"] &&
      req.headers["content-type"].startsWith("multipart/form-data")
    ) {
      // Setup multer file handler based on file count
      const fileHandler =
        maxFileCount > 1
          ? upload.array(fileFieldName, maxFileCount)
          : upload.single(fileFieldName);

      fileHandler(req, res, async (err: unknown) => {
        if (
          err instanceof MulterError &&
          err.code === "LIMIT_UNEXPECTED_FILE"
        ) {
          next(
            new AppError(
              "Validation Failure",
              500,
              `A file was uploaded in the unexpected field '${err.field}'`,
              {
                internalDetails: `Unexpected upload file field: '${err.field}'`,
                cause: err,
              },
            ),
          );
          return;
        } else if (err instanceof Error) {
          next(
            new AppError(
              "Internal Server Error",
              500,
              "An error occurred during file upload",
              {
                cause: err,
              },
            ),
          );
          return;
        }

        // If no file(s) were uploaded, move to next middleware
        if (!req.files && !req.file) {
          next();
          return;
        }

        // Combine single file and multiple files into one array
        const files =
          (req.files as Express.Multer.File[]) || (req.file ? [req.file] : []);

        // Build allowed extensions and MIME types based on expectedFileTypes
        let allowedExtensions: string[] = [];
        let allowedMimeTypes: string[] = [];

        switch (expectedFileTypes) {
          case "Images":
            allowedExtensions = config.IMG_EXTENSIONS.split(";");
            allowedMimeTypes = config.IMG_MIME_TYPES.split(";");
            break;
          case "Files":
            allowedExtensions = config.FILE_EXTENSIONS.split(";");
            allowedMimeTypes = config.FILE_MIME_TYPES.split(";");
            break;
          case "Both":
            allowedExtensions = config.IMG_EXTENSIONS.split(";").concat(
              config.FILE_EXTENSIONS.split(";"),
            );
            allowedMimeTypes = config.IMG_MIME_TYPES.split(";").concat(
              config.FILE_MIME_TYPES.split(";"),
            );
            break;
          default:
            // if none match, we can pass along without further validation or throw an error.
            next(
              new AppError(
                "Validation Failure",
                400,
                "Invalid expectedFileTypes parameter",
              ),
            );
            return;
        }

        for (const file of files) {
          let validationFailed = false;

          // Validate MIME type
          if (!allowedMimeTypes.includes(file.mimetype)) {
            next(
              new AppError(
                "Validation Failure",
                400,
                `The MIME file type ${file.mimetype} is invalid. Allowed type(s) are ${allowedMimeTypes.join(", ")}.`,
              ),
            );
            validationFailed = true;
          }

          // Validate file size
          const maxSizeMb = Number(config.MAX_FILE_SIZE_MB);
          const maxSizeBytes = maxSizeMb * 1024 * 1024;
          if (file.size > maxSizeBytes) {
            next(
              new AppError(
                "Validation Failure",
                400,
                `The uploaded file exceeds the maximum allowed size of ${maxSizeMb}MB.`,
              ),
            );
            validationFailed = true;
          }

          // Validate file extension
          const ext = path.extname(file.originalname).toLowerCase();
          if (!allowedExtensions.includes(ext)) {
            next(
              new AppError(
                "Validation Failure",
                400,
                `The uploaded file has an invalid extension. Allowed extension(s) include(s) ${allowedExtensions.join(", ")}.`,
              ),
            );
            validationFailed = true;
          }

          // Validate file content using magic number
          // Remove leading dot from each allowed extension for content check
          const allowedFileTypes = allowedExtensions.map((ext) =>
            ext.replace(".", ""),
          );
          const buffer = fs.readFileSync(file.path);
          const type = await fileType.fileTypeFromBuffer(buffer);
          if (!type || !allowedFileTypes.includes(type.ext)) {
            next(
              new AppError(
                "Validation Failure",
                400,
                `The uploaded file has invalid content or is corrupted. Allowed file type(s) include(s) ${allowedExtensions.join(", ")}.`,
              ),
            );
            validationFailed = true;
          }
          if (validationFailed && file.path) {
            fs.unlink(file.path, (err) => {
              if (err) {
                console.error(`Error deleting invalid file ${file.path}:`, err);
              } else {
                console.log(`Deleted invalid file: ${file.path}`);
              }
            });

            return;
          }
        }

        // All file validations passed; move to the next middleware.
        next();
        return;
      });
    } else {
      // If content-type is not 'multipart/form-data', pass along without processing.
      next();
      return;
    }
  };
}
