import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

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
  final ServerErrorType title;
  final int status;
  final String detail;

  final List<FieldValidationFailure>? fieldFailures;

  ProblemDetails({
    required this.title,
    required this.status,
    required this.detail,
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

enum ServerErrorType {
  @JsonValue("Internal Server Error")
  internalServerError,

  @JsonValue("Validation Failure")
  validationFailure,

  @JsonValue("Not Found")
  notFound,

  @JsonValue("Permission Denied")
  permissionDenied,

  @JsonValue("Service Unavailable")
  serviceUnavailable,

  @JsonValue("Authentication Required")
  authenticationRequired,
}
