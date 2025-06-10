import 'package:flutter/cupertino.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mobile/models/server/errors.dart';

part 'response.g.dart';

typedef ServiceResult<T> = ({T? data, ApiServiceError? error});

@immutable
@JsonSerializable(genericArgumentFactories: true)
class PaginatedList<T> {
  final List<dynamic> items;
  final int pageNo;
  final int pageCount;

  const PaginatedList({
    required this.items,
    required this.pageNo,
    required this.pageCount,
  });

  /// Factory constructor for JSON deserialization
  factory PaginatedList.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) =>
      _$PaginatedListFromJson(json, fromJsonT);

  /// Convert to JSON
  Map<String, dynamic> toJson(Object Function(T value) toJsonT) =>
      _$PaginatedListToJson(this, toJsonT);

  /// Convert dynamic items to List<T> by mapping with fromJsonT
  List<T> toTypedList(T Function(Map<String, dynamic>) fromJsonT) {
    return items.map((e) => fromJsonT(e as Map<String, dynamic>)).toList();
  }
}
