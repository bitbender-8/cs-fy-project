export function excludeSensitiveProperties<T, K extends keyof T>(
  object: T,
  sensitiveFields: readonly K[]
): Omit<T, K> {
  const newObject: T = { ...object };

  for (const field of sensitiveFields) {
    delete newObject[field];
  }

  return newObject;
}
