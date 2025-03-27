import path from "path";
import fs from "fs";
import * as fileType from "file-type";
import multer from "multer";
import { NextFunction, Request, Response } from "express";

import { AppError } from "../errors/error.types.js";
import { config } from "../config.js";

const upload = multer({ dest: config.UPLOAD_DIR });

export async function validateFileUpload(fileFieldName: string) {
  return async (req: Request, res: Response, next: NextFunction) => {
    // If there is a file upload
    if (
      req.headers["content-type"] &&
      req.headers["content-type"].startsWith("multipart/form-data")
    ) {
      const fileHandler = upload.single(fileFieldName);
      fileHandler(req, res, async (err) => {
        if (err) {
          next(
            new AppError(
              "Internal Server Error",
              500,
              "An error occurred during file upload",
              err.message
            )
          );

          return;
        }

        // If no file was actually uploaded, move on to next middleware
        if (!req.file) {
          next();
          return;
        }

        // File type validation (MIME type)
        const allowedMimeTypes = config.ALLOWED_MIME_TYPES.split(";");
        if (!allowedMimeTypes.includes(req.file.mimetype)) {
          next(
            new AppError(
              "Validation Failure",
              400,
              `The MIME file type ${req.file.mimetype} is invalid. Allowed type(s) are ${allowedMimeTypes.join(", ")}`
            )
          );
          return;
        }

        // File size validation
        const maxSizeMb = Number(config.MAX_FILE_SIZE_MB);
        const maxSize = maxSizeMb * 1024 * 1024;
        if (req.file.size > maxSize) {
          next(
            new AppError(
              "Validation Failure",
              400,
              `The uploaded file exceeds the maximum allowed size of ${maxSizeMb}MB.`
            )
          );
          return;
        }
        // File extension validation
        const allowedExtensions = config.ALLOWED_FILE_EXTENSIONS?.split(";");
        const ext = path.extname(req.file.originalname).toLowerCase();

        if (!allowedExtensions.includes(ext)) {
          next(
            new AppError(
              "Validation Failure",
              400,
              `The uploaded file has an invalid extension. Allowed extension(s) include(s) ${allowedExtensions.join(", ")}.`
            )
          );
          return;
        }
        // File Magic Number Validation
        // Remove leading dot
        const allowedFileTypes = allowedExtensions.map((ext) => ext.slice(1));
        const buffer = fs.readFileSync(req.file.path);
        const type = await fileType.fileTypeFromBuffer(buffer);
        if (!type || !allowedFileTypes.includes(type.ext)) {
          next(
            new AppError(
              "Validation Failure",
              400,
              `The uploaded file has invalid content or is corrupted. Allowed file types include ${allowedExtensions.join(", ")}.`
            )
          );
          return;
        }
        next();
      });
    } else {
      // No file upload, proceed to next middleware or route handler.
      next();
    }
  };
}
