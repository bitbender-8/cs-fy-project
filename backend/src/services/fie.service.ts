import fs from "fs/promises";
import { AppError } from "../errors/error.types.js";

export async function deleteFiles(filePaths: string[]): Promise<void> {
  if (!filePaths || filePaths.length === 0) {
    return;
  }

  const deletePromises = filePaths.map(async (filePath) => {
    try {
      await fs.unlink(filePath);
      console.log(`Successfully deleted: ${filePath}`);
    } catch (error: unknown) {
      if ((error as NodeJS.ErrnoException).code === "ENOENT") {
        throw new AppError(
          "Not Found",
          404,
          `File not found at path: ${filePath}`,
          {
            cause: error as Error,
            internalDetails: `Attempted to delete non-existent file: ${filePath}`,
          },
        );
      } else {
        throw new AppError(
          "Internal Server Error",
          500,
          `Failed to delete file`,
          {
            cause: error as Error,
            internalDetails: `Failed to delete file at path ${filePath}`,
          },
        );
      }
    }
  });

  await Promise.all(deletePromises);
}

export async function getFiles(
  fileUrls: string[],
): Promise<Map<string, Buffer>> {
  if (!fileUrls || fileUrls.length === 0) {
    return new Map();
  }

  const fileMap = new Map<string, Buffer>();

  const readPromises = fileUrls.map(async (filePath) => {
    try {
      const fileContent = await fs.readFile(filePath);
      fileMap.set(filePath, fileContent);
    } catch (error: unknown) {
      throw new AppError("Internal Server Error", 500, `Failed to read file`, {
        cause: error as Error,
        internalDetails: `Failed to read file at path ${filePath}`,
      });
    }
  });

  await Promise.all(readPromises);
  return fileMap;
}
