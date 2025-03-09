import path from "path";
import fs from "fs";
import * as fileType from "file-type";
import multer from "multer";

import { NextFunction, Request, Response } from "express";
import { ProblemDetails } from "./models/error-types.js";

const upload = multer({ dest: process.env.UPLOAD_DIR });

export async function validatedFileUpload(fileFieldName: string) {
  return async (req: Request, res: Response, next: NextFunction) => {
    if (
      req.headers["content-type"] &&
      req.headers["content-type"].startsWith("multipart/form-data")
    ) {
      upload.single(fileFieldName)(req, res, async (err) => {
        if (err) {
          const errorResponse: ProblemDetails = {
            title: "File Upload Error",
            status: 500,
            detail: "An error occurred during file upload.",
          };
          return res.status(500).json(errorResponse);
        }

        if (!req.file) {
          // If multer was successful, but no file was actually uploaded.
          return next();
        }

        try {
          // File Type Validation (MIME Type)
          const allowedMimeTypes = ["image/jpeg", "image/png", "image/gif"];
          if (!allowedMimeTypes.includes(req.file.mimetype)) {
            const errorResponse: ProblemDetails = {
              title: "Invalid File Type",
              status: 400,
              detail:
                "The uploaded file has an invalid MIME type. Allowed types are JPEG, PNG, and GIF.",
            };
            return res.status(400).json(errorResponse);
          }

          // File Size Validation\
          const maxSizeMb = Number(process.env.MAX_SIZE_MB);
          const maxSize = maxSizeMb * 1024 * 1024;
          if (req.file.size > maxSize) {
            const errorResponse: ProblemDetails = {
              title: "File Size Too Large",
              status: 400,
              detail: `The uploaded file exceeds the maximum allowed size of ${maxSizeMb}MB.`,
            };
            return res.status(400).json(errorResponse);
          }

          // File Extension Validation
          const allowedExtensions = [".jpg", ".jpeg", ".png", ".gif"];
          const ext = path.extname(req.file.originalname).toLowerCase();
          if (!allowedExtensions.includes(ext)) {
            const errorResponse: ProblemDetails = {
              title: "Invalid File Extension",
              status: 400,
              detail:
                "The uploaded file has an invalid extension. Allowed extensions are .jpg, .jpeg, .png, and .gif.",
            };
            return res.status(400).json(errorResponse);
          }

          // File Magic Number Validation
          const buffer = fs.readFileSync(req.file.path);
          const type = await fileType.fileTypeFromBuffer(buffer);
          if (!type || !["jpg", "png", "gif"].includes(type.ext)) {
            const errorResponse: ProblemDetails = {
              title: "Invalid File Content",
              status: 400,
              detail:
                "The uploaded file has invalid content or is corrupted. Allowed file types are JPEG, PNG, and GIF.",
            };
            return res.status(400).json(errorResponse);
          }

          // Filename sanitization
          req.file.originalname = req.file.originalname.replace(
            /[^a-zA-Z0-9._-]/g,
            "_",
          );

          next();
        } catch (validationError) {
          console.error("File validation error:", validationError);
          const errorResponse: ProblemDetails = {
            title: "File Validation Failed",
            status: 500,
            detail: "An unexpected error occurred during file validation.",
          };
          return res.status(500).json(errorResponse);
        }
      });
    } else {
      next(); // No file upload, proceed to next middleware or route handler.
    }
  };
}
