import 'package:json_annotation/json_annotation.dart';

part 'errors.g.dart';

sealed class ApiServiceError {}

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
