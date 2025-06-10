// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'errors.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProblemDetails _$ProblemDetailsFromJson(Map<String, dynamic> json) =>
    ProblemDetails(
      title: $enumDecode(_$ResponseErrorTypeEnumMap, json['title']),
      status: (json['status'] as num).toInt(),
      detail: json['detail'] as String,
      code: $enumDecodeNullable(_$ServerErrorCodeEnumMap, json['code']),
      fieldFailures: (json['fieldFailures'] as List<dynamic>?)
          ?.map(
              (e) => FieldValidationFailure.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ProblemDetailsToJson(ProblemDetails instance) =>
    <String, dynamic>{
      'title': _$ResponseErrorTypeEnumMap[instance.title]!,
      'status': instance.status,
      'detail': instance.detail,
      'code': _$ServerErrorCodeEnumMap[instance.code],
      'fieldFailures': instance.fieldFailures?.map((e) => e.toJson()).toList(),
    };

const _$ResponseErrorTypeEnumMap = {
  ResponseErrorType.internalServerError: 'Internal Server Error',
  ResponseErrorType.validationFailure: 'Validation Failure',
  ResponseErrorType.notFound: 'Not Found',
  ResponseErrorType.permissionDenied: 'Permission Denied',
  ResponseErrorType.serviceUnavailable: 'Service Unavailable',
  ResponseErrorType.authenticationRequired: 'Authentication Required',
};

const _$ServerErrorCodeEnumMap = {
  ServerErrorCode.duplicateEmail: 'DUPLICATE_EMAIL',
  ServerErrorCode.duplicateAuth0User: 'DUPLICATE_AUTH0_USER',
};

FieldValidationFailure _$FieldValidationFailureFromJson(
        Map<String, dynamic> json) =>
    FieldValidationFailure(
      field: json['field'] as String,
      uiMessage: json['uiMessage'] as String,
    );

Map<String, dynamic> _$FieldValidationFailureToJson(
        FieldValidationFailure instance) =>
    <String, dynamic>{
      'field': instance.field,
      'uiMessage': instance.uiMessage,
    };
