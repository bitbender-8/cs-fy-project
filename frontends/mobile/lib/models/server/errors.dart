import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mobile/models/server/response.dart';

part 'errors.g.dart';

sealed class ApiServiceError {
  static ApiServiceError handleException(Object e) {
    debugPrint("[REQUEST_ERROR]: $e");

    if (e is SocketException) {
      return SimpleError('No Internet connection. Please check your network.');
    }
    if (e is TimeoutException) {
      return SimpleError('Request timed out. Please try again later.');
    }
    if (e is SimpleError) {
      return e;
    }

    return SimpleError('An unexpected error occurred: $e');
  }

  /// Extracts a user-friendly error message from a service response error.
  ///
  /// [error] The error object received from a service response (ApiServiceError).
  /// Returns a string message suitable for display.
  static String getErrorMessage(ApiServiceError error) {
    if (error is ProblemDetails) {
      if (error.fieldFailures != null && error.fieldFailures!.isNotEmpty) {
        return 'One or more fields have validation errors.';
      }
      return error.detail.isNotEmpty ? error.detail : 'An API error occurred.';
    } else if (error is SimpleError) {
      return error.message.isNotEmpty
          ? error.message
          : 'An unexpected error occurred.';
    }
    // Fallback for any other unhandled error types
    return 'An unknown error occurred. Please try again.';
  }
}

final class SimpleError extends ApiServiceError {
  final String message;
  SimpleError(this.message);
}

@JsonSerializable(explicitToJson: true)
final class ProblemDetails extends ApiServiceError {
  final ResponseErrorType title;
  final int status;
  final String detail;
  final ServerErrorCode? code;

  final List<FieldValidationFailure>? fieldFailures;

  ProblemDetails({
    required this.title,
    required this.status,
    required this.detail,
    this.code,
    this.fieldFailures,
  });

  factory ProblemDetails.fromJson(Map<String, dynamic> json) =>
      _$ProblemDetailsFromJson(json);

  Map<String, dynamic> toJson() => _$ProblemDetailsToJson(this);
}

@JsonSerializable()
class FieldValidationFailure {
  final String field;
  final String uiMessage;

  FieldValidationFailure({
    required this.field,
    required this.uiMessage,
  });

  factory FieldValidationFailure.fromJson(Map<String, dynamic> json) =>
      _$FieldValidationFailureFromJson(json);

  Map<String, dynamic> toJson() => _$FieldValidationFailureToJson(this);
}

enum ResponseErrorType {
  @JsonValue("Internal Server Error")
  internalServerError("Internal Server Error"),

  @JsonValue("Validation Failure")
  validationFailure("Validation Failure"),

  @JsonValue("Not Found")
  notFound("Not Found"),

  @JsonValue("Permission Denied")
  permissionDenied("Permission Denied"),

  @JsonValue("Service Unavailable")
  serviceUnavailable("Service Unavailable"),

  @JsonValue("Authentication Required")
  authenticationRequired("Authentication Required"),

  @JsonValue("Payment Failure")
  paymentFailure("Payment Failure");

  final String value;
  const ResponseErrorType(this.value);
}

enum ServerErrorCode {
  @JsonValue("DUPLICATE_EMAIL")
  duplicateEmail,

  @JsonValue("DUPLICATE_AUTH0_USER")
  duplicateAuth0User
}

/// This mixin is designed to be used with State classes.
mixin FormErrorHelpers<T extends StatefulWidget> on State<T> {
  Map<String, List<String>> _serverErrors = {};

  /// Helper to get the first error message for a given field
  String? getServerError(String fieldName) {
    if (_serverErrors.containsKey(fieldName) &&
        _serverErrors[fieldName]!.isNotEmpty) {
      return _serverErrors[fieldName]!.first;
    }
    return null;
  }

  /// Helper to clear server errors when user starts typing or when a field changes
  void clearServerError(String fieldName) {
    if (_serverErrors.containsKey(fieldName)) {
      setState(() {
        // Directly call setState, as it's guaranteed to be available by 'on State<T>'
        _serverErrors.remove(fieldName);
      });
    }
  }

  /// Method to set server errors from an external source (e.g., API response)
  /// This should be called to update the errors and trigger a rebuild.
  void setServerErrors(Map<String, List<String>> newErrors) {
    setState(() {
      _serverErrors = newErrors;
    });
  }

  /// Method to clear all server errors, typically after a successful submission
  void clearAllServerErrors() {
    setState(() {
      _serverErrors = {};
    });
  }
}

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

  final errorColor = Theme.of(context).colorScheme.error;
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: errorColor,
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
Future<bool> handleServiceResponse<T>(
  BuildContext context,
  ServiceResult<T> result, {
  FutureOr<void> Function()? onSuccess,
  void Function(Map<String, List<String>>)? onValidationErrors,
  String? successMessage,
}) async {
  if (!context.mounted) return false;

  if (result.error == null) {
    if (successMessage != null) {
      showInfoSnackBar(context, successMessage);
    }
    if (onSuccess != null) {
      await onSuccess();
    }
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
