// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'errors.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProblemDetails _$ProblemDetailsFromJson(Map<String, dynamic> json) =>
    ProblemDetails(
      title: $enumDecode(_$ServerErrorTypeEnumMap, json['title']),
      status: (json['status'] as num).toInt(),
      detail: json['detail'] as String,
      fieldFailures: (json['fieldFailures'] as List<dynamic>?)
          ?.map(
              (e) => FieldValidationFailure.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ProblemDetailsToJson(ProblemDetails instance) =>
    <String, dynamic>{
      'title': _$ServerErrorTypeEnumMap[instance.title]!,
      'status': instance.status,
      'detail': instance.detail,
      'fieldFailures': instance.fieldFailures?.map((e) => e.toJson()).toList(),
    };

const _$ServerErrorTypeEnumMap = {
  ServerErrorType.internalServerError: 'Internal Server Error',
  ServerErrorType.validationFailure: 'Validation Failure',
  ServerErrorType.notFound: 'Not Found',
  ServerErrorType.permissionDenied: 'Permission Denied',
  ServerErrorType.serviceUnavailable: 'Service Unavailable',
  ServerErrorType.authenticationRequired: 'Authentication Required',
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
