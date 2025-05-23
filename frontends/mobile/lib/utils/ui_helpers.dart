import 'package:flutter/material.dart';
import 'package:mobile/models/server/errors.dart';
import 'package:mobile/models/server/response.dart';

/// Shows a standard informational or success SnackBar.
///
/// [context] The BuildContext to show the SnackBar in.
/// [message] The message to display.
void showInfoSnackBar(BuildContext context, String message) {
  if (!context.mounted) return;
  ScaffoldMessenger.of(context)
      .hideCurrentSnackBar(); // Hide any previous snackbar
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor:
          Theme.of(context).colorScheme.primary, // Or a neutral color
    ),
  );
}

/// Shows an error SnackBar.
///
/// [context] The BuildContext to show the SnackBar in.
/// [message] The error message to display.
void showErrorSnackBar(BuildContext context, String message) {
  if (!context.mounted) return;
  ScaffoldMessenger.of(context)
      .hideCurrentSnackBar(); // Hide any previous snackbar
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Theme.of(context).colorScheme.error,
    ),
  );
}

/// Helper function to handle the result of a service call.
///
/// [context] The BuildContext for showing SnackBars/dialogs.
/// [result] The ServiceResponse object.
/// [onSuccess] A callback function to execute if the response indicates success.
/// [successMessage] An optional success message for the SnackBar.
/// Returns true if the operation was successful, false otherwise.
bool handleServiceResponse<T>(
  BuildContext context,
  ServiceResult<T> result, {
  VoidCallback? onSuccess,
  void Function(Map<String, List<String>>)? onValidationErrors,
  String? successMessage,
}) {
  if (!context.mounted) return false;

  if (result.data != null) {
    if (successMessage != null) {
      showInfoSnackBar(context, successMessage);
    }
    onSuccess?.call();
    return true;
  } else {
    if (result.error is ProblemDetails) {
      final problem = result.error as ProblemDetails;
      if (problem.fieldFailures != null && problem.fieldFailures!.isNotEmpty) {
        final Map<String, List<String>> fieldErrors = {};
        for (var failure in problem.fieldFailures!) {
          // If a field already has errors, add to its list. Otherwise, create a new list.
          fieldErrors
              .putIfAbsent(failure.field, () => [])
              .add(failure.uiMessage);
        }

        // Pass the extracted field errors to the new callback
        onValidationErrors?.call(fieldErrors);

        // Show a general snackbar that there are validation errors,
        // as inline errors might not cover all cases or be immediately visible.
        showErrorSnackBar(
          context,
          problem.detail.isNotEmpty
              ? problem.detail
              : 'Please correct the highlighted fields.',
        );
        return false;
      }
    }

    final errorMessage = ApiServiceError.getErrorMessage(result.error!);
    showErrorSnackBar(context, errorMessage);
    return false;
  }
}
