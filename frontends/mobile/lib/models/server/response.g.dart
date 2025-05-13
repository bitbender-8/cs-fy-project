// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaginatedList<T> _$PaginatedListFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) =>
    PaginatedList<T>(
      items: json['items'] as List<dynamic>,
      pageNo: (json['pageNo'] as num).toInt(),
      pageCount: (json['pageCount'] as num).toInt(),
    );

Map<String, dynamic> _$PaginatedListToJson<T>(
  PaginatedList<T> instance,
  Object? Function(T value) toJsonT,
) =>
    <String, dynamic>{
      'items': instance.items,
      'pageNo': instance.pageNo,
      'pageCount': instance.pageCount,
    };
