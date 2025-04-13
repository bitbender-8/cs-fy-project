export interface UpdateObject {
  [key: string]: unknown;
}

export interface UpdateResult {
  fragments: string[];
  values: unknown[];
}

// CONSIDER: Updating all insert and update functions to use this.
/**
 * Constructs the SET clause and parameter values for a SQL UPDATE query.
 *
 * Generates an array of "fieldName" = $n strings (SET clause fragments) and
 * an array of corresponding parameter values, including the ID for the WHERE clause.
 *
 * @param updateData - Fields and values to update (key: field, value: new value).
 * @param idValue - ID for the WHERE clause.
 * @param startValueIndex - Starting index for parameter values (defaults to 1).
 * @returns - Object containing SET clause fragments and parameter values.
 */
export function buildUpdateQueryString(
  updateData: UpdateObject,
  startValueIndex: number = 1
): UpdateResult {
  const updateFields: string[] = [];
  const updateValues: unknown[] = [];
  let valueIndex = startValueIndex;

  for (const fieldName in updateData) {
    if (updateData[fieldName] !== undefined) {
      updateFields.push(`"${fieldName}" = $${valueIndex}`);
      updateValues.push(updateData[fieldName]);
      valueIndex++;
    }
  }

  return { fragments: updateFields, values: updateValues };
}
