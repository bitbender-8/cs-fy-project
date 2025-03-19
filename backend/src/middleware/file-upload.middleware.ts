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
      try {
        const fileHandler = upload.single(fileFieldName);
        fileHandler(req, res, async (err) => {
          if (err) {
            next(
              new AppError(
                "Internal Server Error",
                500,
                "An error occurred during file upload"
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
          const allowedMimeTypes = ["image/jpeg", "image/png", "image/gif"];
          if (!allowedMimeTypes.includes(req.file.mimetype)) {
            next(
              new AppError(
                "Validation Failure",
                400,
                "The uploaded file has an invalid MIME type. Allowed types are JPEG, PNG, and GIF."
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
          const allowedExtensions = config.ALLOWED_FILE_EXTENSIONS?.split(
            ";"
          ) ?? [".jpeg", ".jpg"];
          const ext = path.extname(req.file.originalname).toLowerCase();
          const formattedExtensions =
            allowedExtensions.length === 1
              ? allowedExtensions[0]
              : allowedExtensions.slice(0, -1).join(", ") +
                ` and ${allowedExtensions[allowedExtensions.length - 1]}`;

          if (!allowedExtensions.includes(ext)) {
            next(
              new AppError(
                "Validation Failure",
                400,
                `The uploaded file has an invalid extension. Allowed extension(s) include(s) ${formattedExtensions}.`
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
                `The uploaded file has invalid content or is corrupted. Allowed file types include ${formattedExtensions}.`
              )
            );
            return;
          }
        });
      } catch (error: unknown) {
        console.error("File validation error:", error);
        next(
          new AppError(
            "Internal Server Error",
            500,
            "An unexpectd error occurred during file validation"
          )
        );
        return;
      }
    } else {
      // No file upload, proceed to next middleware or route handler.
      next();
    }
  };
}
