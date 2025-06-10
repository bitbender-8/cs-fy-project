// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'campaign_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$GoalAdjustmentRequestCWProxy {
  GoalAdjustmentRequest id(String? id);

  GoalAdjustmentRequest campaignId(String campaignId);

  GoalAdjustmentRequest ownerRecipientId(String ownerRecipientId);

  GoalAdjustmentRequest title(String title);

  GoalAdjustmentRequest justification(String justification);

  GoalAdjustmentRequest requestDate(DateTime? requestDate);

  GoalAdjustmentRequest resolutionDate(DateTime? resolutionDate);

  GoalAdjustmentRequest resolutionType(ResolutionType? resolutionType);

  GoalAdjustmentRequest newGoal(String newGoal);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GoalAdjustmentRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GoalAdjustmentRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  GoalAdjustmentRequest call({
    String? id,
    String campaignId,
    String ownerRecipientId,
    String title,
    String justification,
    DateTime? requestDate,
    DateTime? resolutionDate,
    ResolutionType? resolutionType,
    String newGoal,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfGoalAdjustmentRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfGoalAdjustmentRequest.copyWith.fieldName(...)`
class _$GoalAdjustmentRequestCWProxyImpl
    implements _$GoalAdjustmentRequestCWProxy {
  const _$GoalAdjustmentRequestCWProxyImpl(this._value);

  final GoalAdjustmentRequest _value;

  @override
  GoalAdjustmentRequest id(String? id) => this(id: id);

  @override
  GoalAdjustmentRequest campaignId(String campaignId) =>
      this(campaignId: campaignId);

  @override
  GoalAdjustmentRequest ownerRecipientId(String ownerRecipientId) =>
      this(ownerRecipientId: ownerRecipientId);

  @override
  GoalAdjustmentRequest title(String title) => this(title: title);

  @override
  GoalAdjustmentRequest justification(String justification) =>
      this(justification: justification);

  @override
  GoalAdjustmentRequest requestDate(DateTime? requestDate) =>
      this(requestDate: requestDate);

  @override
  GoalAdjustmentRequest resolutionDate(DateTime? resolutionDate) =>
      this(resolutionDate: resolutionDate);

  @override
  GoalAdjustmentRequest resolutionType(ResolutionType? resolutionType) =>
      this(resolutionType: resolutionType);

  @override
  GoalAdjustmentRequest newGoal(String newGoal) => this(newGoal: newGoal);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GoalAdjustmentRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GoalAdjustmentRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  GoalAdjustmentRequest call({
    Object? id = const $CopyWithPlaceholder(),
    Object? campaignId = const $CopyWithPlaceholder(),
    Object? ownerRecipientId = const $CopyWithPlaceholder(),
    Object? title = const $CopyWithPlaceholder(),
    Object? justification = const $CopyWithPlaceholder(),
    Object? requestDate = const $CopyWithPlaceholder(),
    Object? resolutionDate = const $CopyWithPlaceholder(),
    Object? resolutionType = const $CopyWithPlaceholder(),
    Object? newGoal = const $CopyWithPlaceholder(),
  }) {
    return GoalAdjustmentRequest(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String?,
      campaignId: campaignId == const $CopyWithPlaceholder()
          ? _value.campaignId
          // ignore: cast_nullable_to_non_nullable
          : campaignId as String,
      ownerRecipientId: ownerRecipientId == const $CopyWithPlaceholder()
          ? _value.ownerRecipientId
          // ignore: cast_nullable_to_non_nullable
          : ownerRecipientId as String,
      title: title == const $CopyWithPlaceholder()
          ? _value.title
          // ignore: cast_nullable_to_non_nullable
          : title as String,
      justification: justification == const $CopyWithPlaceholder()
          ? _value.justification
          // ignore: cast_nullable_to_non_nullable
          : justification as String,
      requestDate: requestDate == const $CopyWithPlaceholder()
          ? _value.requestDate
          // ignore: cast_nullable_to_non_nullable
          : requestDate as DateTime?,
      resolutionDate: resolutionDate == const $CopyWithPlaceholder()
          ? _value.resolutionDate
          // ignore: cast_nullable_to_non_nullable
          : resolutionDate as DateTime?,
      resolutionType: resolutionType == const $CopyWithPlaceholder()
          ? _value.resolutionType
          // ignore: cast_nullable_to_non_nullable
          : resolutionType as ResolutionType?,
      newGoal: newGoal == const $CopyWithPlaceholder()
          ? _value.newGoal
          // ignore: cast_nullable_to_non_nullable
          : newGoal as String,
    );
  }
}

extension $GoalAdjustmentRequestCopyWith on GoalAdjustmentRequest {
  /// Returns a callable class that can be used as follows: `instanceOfGoalAdjustmentRequest.copyWith(...)` or like so:`instanceOfGoalAdjustmentRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$GoalAdjustmentRequestCWProxy get copyWith =>
      _$GoalAdjustmentRequestCWProxyImpl(this);
}

abstract class _$StatusChangeRequestCWProxy {
  StatusChangeRequest id(String? id);

  StatusChangeRequest campaignId(String campaignId);

  StatusChangeRequest ownerRecipientId(String ownerRecipientId);

  StatusChangeRequest title(String title);

  StatusChangeRequest justification(String justification);

  StatusChangeRequest requestDate(DateTime? requestDate);

  StatusChangeRequest resolutionDate(DateTime? resolutionDate);

  StatusChangeRequest resolutionType(ResolutionType? resolutionType);

  StatusChangeRequest newStatus(CampaignStatus newStatus);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `StatusChangeRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// StatusChangeRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  StatusChangeRequest call({
    String? id,
    String campaignId,
    String ownerRecipientId,
    String title,
    String justification,
    DateTime? requestDate,
    DateTime? resolutionDate,
    ResolutionType? resolutionType,
    CampaignStatus newStatus,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfStatusChangeRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfStatusChangeRequest.copyWith.fieldName(...)`
class _$StatusChangeRequestCWProxyImpl implements _$StatusChangeRequestCWProxy {
  const _$StatusChangeRequestCWProxyImpl(this._value);

  final StatusChangeRequest _value;

  @override
  StatusChangeRequest id(String? id) => this(id: id);

  @override
  StatusChangeRequest campaignId(String campaignId) =>
      this(campaignId: campaignId);

  @override
  StatusChangeRequest ownerRecipientId(String ownerRecipientId) =>
      this(ownerRecipientId: ownerRecipientId);

  @override
  StatusChangeRequest title(String title) => this(title: title);

  @override
  StatusChangeRequest justification(String justification) =>
      this(justification: justification);

  @override
  StatusChangeRequest requestDate(DateTime? requestDate) =>
      this(requestDate: requestDate);

  @override
  StatusChangeRequest resolutionDate(DateTime? resolutionDate) =>
      this(resolutionDate: resolutionDate);

  @override
  StatusChangeRequest resolutionType(ResolutionType? resolutionType) =>
      this(resolutionType: resolutionType);

  @override
  StatusChangeRequest newStatus(CampaignStatus newStatus) =>
      this(newStatus: newStatus);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `StatusChangeRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// StatusChangeRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  StatusChangeRequest call({
    Object? id = const $CopyWithPlaceholder(),
    Object? campaignId = const $CopyWithPlaceholder(),
    Object? ownerRecipientId = const $CopyWithPlaceholder(),
    Object? title = const $CopyWithPlaceholder(),
    Object? justification = const $CopyWithPlaceholder(),
    Object? requestDate = const $CopyWithPlaceholder(),
    Object? resolutionDate = const $CopyWithPlaceholder(),
    Object? resolutionType = const $CopyWithPlaceholder(),
    Object? newStatus = const $CopyWithPlaceholder(),
  }) {
    return StatusChangeRequest(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String?,
      campaignId: campaignId == const $CopyWithPlaceholder()
          ? _value.campaignId
          // ignore: cast_nullable_to_non_nullable
          : campaignId as String,
      ownerRecipientId: ownerRecipientId == const $CopyWithPlaceholder()
          ? _value.ownerRecipientId
          // ignore: cast_nullable_to_non_nullable
          : ownerRecipientId as String,
      title: title == const $CopyWithPlaceholder()
          ? _value.title
          // ignore: cast_nullable_to_non_nullable
          : title as String,
      justification: justification == const $CopyWithPlaceholder()
          ? _value.justification
          // ignore: cast_nullable_to_non_nullable
          : justification as String,
      requestDate: requestDate == const $CopyWithPlaceholder()
          ? _value.requestDate
          // ignore: cast_nullable_to_non_nullable
          : requestDate as DateTime?,
      resolutionDate: resolutionDate == const $CopyWithPlaceholder()
          ? _value.resolutionDate
          // ignore: cast_nullable_to_non_nullable
          : resolutionDate as DateTime?,
      resolutionType: resolutionType == const $CopyWithPlaceholder()
          ? _value.resolutionType
          // ignore: cast_nullable_to_non_nullable
          : resolutionType as ResolutionType?,
      newStatus: newStatus == const $CopyWithPlaceholder()
          ? _value.newStatus
          // ignore: cast_nullable_to_non_nullable
          : newStatus as CampaignStatus,
    );
  }
}

extension $StatusChangeRequestCopyWith on StatusChangeRequest {
  /// Returns a callable class that can be used as follows: `instanceOfStatusChangeRequest.copyWith(...)` or like so:`instanceOfStatusChangeRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$StatusChangeRequestCWProxy get copyWith =>
      _$StatusChangeRequestCWProxyImpl(this);
}

abstract class _$PostUpdateRequestCWProxy {
  PostUpdateRequest id(String? id);

  PostUpdateRequest campaignId(String campaignId);

  PostUpdateRequest ownerRecipientId(String ownerRecipientId);

  PostUpdateRequest title(String title);

  PostUpdateRequest justification(String justification);

  PostUpdateRequest requestDate(DateTime? requestDate);

  PostUpdateRequest resolutionDate(DateTime? resolutionDate);

  PostUpdateRequest resolutionType(ResolutionType? resolutionType);

  PostUpdateRequest newPost(CampaignPost newPost);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PostUpdateRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PostUpdateRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  PostUpdateRequest call({
    String? id,
    String campaignId,
    String ownerRecipientId,
    String title,
    String justification,
    DateTime? requestDate,
    DateTime? resolutionDate,
    ResolutionType? resolutionType,
    CampaignPost newPost,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPostUpdateRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPostUpdateRequest.copyWith.fieldName(...)`
class _$PostUpdateRequestCWProxyImpl implements _$PostUpdateRequestCWProxy {
  const _$PostUpdateRequestCWProxyImpl(this._value);

  final PostUpdateRequest _value;

  @override
  PostUpdateRequest id(String? id) => this(id: id);

  @override
  PostUpdateRequest campaignId(String campaignId) =>
      this(campaignId: campaignId);

  @override
  PostUpdateRequest ownerRecipientId(String ownerRecipientId) =>
      this(ownerRecipientId: ownerRecipientId);

  @override
  PostUpdateRequest title(String title) => this(title: title);

  @override
  PostUpdateRequest justification(String justification) =>
      this(justification: justification);

  @override
  PostUpdateRequest requestDate(DateTime? requestDate) =>
      this(requestDate: requestDate);

  @override
  PostUpdateRequest resolutionDate(DateTime? resolutionDate) =>
      this(resolutionDate: resolutionDate);

  @override
  PostUpdateRequest resolutionType(ResolutionType? resolutionType) =>
      this(resolutionType: resolutionType);

  @override
  PostUpdateRequest newPost(CampaignPost newPost) => this(newPost: newPost);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PostUpdateRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PostUpdateRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  PostUpdateRequest call({
    Object? id = const $CopyWithPlaceholder(),
    Object? campaignId = const $CopyWithPlaceholder(),
    Object? ownerRecipientId = const $CopyWithPlaceholder(),
    Object? title = const $CopyWithPlaceholder(),
    Object? justification = const $CopyWithPlaceholder(),
    Object? requestDate = const $CopyWithPlaceholder(),
    Object? resolutionDate = const $CopyWithPlaceholder(),
    Object? resolutionType = const $CopyWithPlaceholder(),
    Object? newPost = const $CopyWithPlaceholder(),
  }) {
    return PostUpdateRequest(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String?,
      campaignId: campaignId == const $CopyWithPlaceholder()
          ? _value.campaignId
          // ignore: cast_nullable_to_non_nullable
          : campaignId as String,
      ownerRecipientId: ownerRecipientId == const $CopyWithPlaceholder()
          ? _value.ownerRecipientId
          // ignore: cast_nullable_to_non_nullable
          : ownerRecipientId as String,
      title: title == const $CopyWithPlaceholder()
          ? _value.title
          // ignore: cast_nullable_to_non_nullable
          : title as String,
      justification: justification == const $CopyWithPlaceholder()
          ? _value.justification
          // ignore: cast_nullable_to_non_nullable
          : justification as String,
      requestDate: requestDate == const $CopyWithPlaceholder()
          ? _value.requestDate
          // ignore: cast_nullable_to_non_nullable
          : requestDate as DateTime?,
      resolutionDate: resolutionDate == const $CopyWithPlaceholder()
          ? _value.resolutionDate
          // ignore: cast_nullable_to_non_nullable
          : resolutionDate as DateTime?,
      resolutionType: resolutionType == const $CopyWithPlaceholder()
          ? _value.resolutionType
          // ignore: cast_nullable_to_non_nullable
          : resolutionType as ResolutionType?,
      newPost: newPost == const $CopyWithPlaceholder()
          ? _value.newPost
          // ignore: cast_nullable_to_non_nullable
          : newPost as CampaignPost,
    );
  }
}

extension $PostUpdateRequestCopyWith on PostUpdateRequest {
  /// Returns a callable class that can be used as follows: `instanceOfPostUpdateRequest.copyWith(...)` or like so:`instanceOfPostUpdateRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PostUpdateRequestCWProxy get copyWith =>
      _$PostUpdateRequestCWProxyImpl(this);
}

abstract class _$EndDateExtensionRequestCWProxy {
  EndDateExtensionRequest id(String? id);

  EndDateExtensionRequest campaignId(String campaignId);

  EndDateExtensionRequest ownerRecipientId(String ownerRecipientId);

  EndDateExtensionRequest title(String title);

  EndDateExtensionRequest justification(String justification);

  EndDateExtensionRequest requestDate(DateTime? requestDate);

  EndDateExtensionRequest resolutionDate(DateTime? resolutionDate);

  EndDateExtensionRequest resolutionType(ResolutionType? resolutionType);

  EndDateExtensionRequest newEndDate(DateTime newEndDate);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `EndDateExtensionRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// EndDateExtensionRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  EndDateExtensionRequest call({
    String? id,
    String campaignId,
    String ownerRecipientId,
    String title,
    String justification,
    DateTime? requestDate,
    DateTime? resolutionDate,
    ResolutionType? resolutionType,
    DateTime newEndDate,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfEndDateExtensionRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfEndDateExtensionRequest.copyWith.fieldName(...)`
class _$EndDateExtensionRequestCWProxyImpl
    implements _$EndDateExtensionRequestCWProxy {
  const _$EndDateExtensionRequestCWProxyImpl(this._value);

  final EndDateExtensionRequest _value;

  @override
  EndDateExtensionRequest id(String? id) => this(id: id);

  @override
  EndDateExtensionRequest campaignId(String campaignId) =>
      this(campaignId: campaignId);

  @override
  EndDateExtensionRequest ownerRecipientId(String ownerRecipientId) =>
      this(ownerRecipientId: ownerRecipientId);

  @override
  EndDateExtensionRequest title(String title) => this(title: title);

  @override
  EndDateExtensionRequest justification(String justification) =>
      this(justification: justification);

  @override
  EndDateExtensionRequest requestDate(DateTime? requestDate) =>
      this(requestDate: requestDate);

  @override
  EndDateExtensionRequest resolutionDate(DateTime? resolutionDate) =>
      this(resolutionDate: resolutionDate);

  @override
  EndDateExtensionRequest resolutionType(ResolutionType? resolutionType) =>
      this(resolutionType: resolutionType);

  @override
  EndDateExtensionRequest newEndDate(DateTime newEndDate) =>
      this(newEndDate: newEndDate);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `EndDateExtensionRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// EndDateExtensionRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  EndDateExtensionRequest call({
    Object? id = const $CopyWithPlaceholder(),
    Object? campaignId = const $CopyWithPlaceholder(),
    Object? ownerRecipientId = const $CopyWithPlaceholder(),
    Object? title = const $CopyWithPlaceholder(),
    Object? justification = const $CopyWithPlaceholder(),
    Object? requestDate = const $CopyWithPlaceholder(),
    Object? resolutionDate = const $CopyWithPlaceholder(),
    Object? resolutionType = const $CopyWithPlaceholder(),
    Object? newEndDate = const $CopyWithPlaceholder(),
  }) {
    return EndDateExtensionRequest(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String?,
      campaignId: campaignId == const $CopyWithPlaceholder()
          ? _value.campaignId
          // ignore: cast_nullable_to_non_nullable
          : campaignId as String,
      ownerRecipientId: ownerRecipientId == const $CopyWithPlaceholder()
          ? _value.ownerRecipientId
          // ignore: cast_nullable_to_non_nullable
          : ownerRecipientId as String,
      title: title == const $CopyWithPlaceholder()
          ? _value.title
          // ignore: cast_nullable_to_non_nullable
          : title as String,
      justification: justification == const $CopyWithPlaceholder()
          ? _value.justification
          // ignore: cast_nullable_to_non_nullable
          : justification as String,
      requestDate: requestDate == const $CopyWithPlaceholder()
          ? _value.requestDate
          // ignore: cast_nullable_to_non_nullable
          : requestDate as DateTime?,
      resolutionDate: resolutionDate == const $CopyWithPlaceholder()
          ? _value.resolutionDate
          // ignore: cast_nullable_to_non_nullable
          : resolutionDate as DateTime?,
      resolutionType: resolutionType == const $CopyWithPlaceholder()
          ? _value.resolutionType
          // ignore: cast_nullable_to_non_nullable
          : resolutionType as ResolutionType?,
      newEndDate: newEndDate == const $CopyWithPlaceholder()
          ? _value.newEndDate
          // ignore: cast_nullable_to_non_nullable
          : newEndDate as DateTime,
    );
  }
}

extension $EndDateExtensionRequestCopyWith on EndDateExtensionRequest {
  /// Returns a callable class that can be used as follows: `instanceOfEndDateExtensionRequest.copyWith(...)` or like so:`instanceOfEndDateExtensionRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$EndDateExtensionRequestCWProxy get copyWith =>
      _$EndDateExtensionRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Map<String, dynamic> _$CampaignRequestToJson(CampaignRequest instance) =>
    <String, dynamic>{
      'id': instance.id,
      'campaignId': instance.campaignId,
      'ownerRecipientId': instance.ownerRecipientId,
      'title': instance.title,
      'justification': instance.justification,
      'requestDate': instance.requestDate?.toIso8601String(),
      'resolutionDate': instance.resolutionDate?.toIso8601String(),
      'requestType': _$CampaignRequestTypeEnumMap[instance.requestType]!,
      'resolutionType': _$ResolutionTypeEnumMap[instance.resolutionType],
    };

const _$CampaignRequestTypeEnumMap = {
  CampaignRequestType.goalAdjustment: 'Goal Adjustment',
  CampaignRequestType.postUpdate: 'Post Update',
  CampaignRequestType.endDateExtension: 'End Date Extension',
  CampaignRequestType.statusChange: 'Status Change',
};

const _$ResolutionTypeEnumMap = {
  ResolutionType.accepted: 'Accepted',
  ResolutionType.rejected: 'Rejected',
};

GoalAdjustmentRequest _$GoalAdjustmentRequestFromJson(
        Map<String, dynamic> json) =>
    GoalAdjustmentRequest(
      id: json['id'] as String?,
      campaignId: json['campaignId'] as String,
      ownerRecipientId: json['ownerRecipientId'] as String,
      title: json['title'] as String,
      justification: json['justification'] as String,
      requestDate: json['requestDate'] == null
          ? null
          : DateTime.parse(json['requestDate'] as String),
      resolutionDate: json['resolutionDate'] == null
          ? null
          : DateTime.parse(json['resolutionDate'] as String),
      resolutionType:
          $enumDecodeNullable(_$ResolutionTypeEnumMap, json['resolutionType']),
      newGoal: json['newGoal'] as String,
    )..requestType =
        $enumDecode(_$CampaignRequestTypeEnumMap, json['requestType']);

Map<String, dynamic> _$GoalAdjustmentRequestToJson(
        GoalAdjustmentRequest instance) =>
    <String, dynamic>{
      'id': instance.id,
      'campaignId': instance.campaignId,
      'ownerRecipientId': instance.ownerRecipientId,
      'title': instance.title,
      'justification': instance.justification,
      'requestDate': instance.requestDate?.toIso8601String(),
      'resolutionDate': instance.resolutionDate?.toIso8601String(),
      'requestType': _$CampaignRequestTypeEnumMap[instance.requestType]!,
      'resolutionType': _$ResolutionTypeEnumMap[instance.resolutionType],
      'newGoal': instance.newGoal,
    };

StatusChangeRequest _$StatusChangeRequestFromJson(Map<String, dynamic> json) =>
    StatusChangeRequest(
      id: json['id'] as String?,
      campaignId: json['campaignId'] as String,
      ownerRecipientId: json['ownerRecipientId'] as String,
      title: json['title'] as String,
      justification: json['justification'] as String,
      requestDate: json['requestDate'] == null
          ? null
          : DateTime.parse(json['requestDate'] as String),
      resolutionDate: json['resolutionDate'] == null
          ? null
          : DateTime.parse(json['resolutionDate'] as String),
      resolutionType:
          $enumDecodeNullable(_$ResolutionTypeEnumMap, json['resolutionType']),
      newStatus: $enumDecode(_$CampaignStatusEnumMap, json['newStatus']),
    )..requestType =
        $enumDecode(_$CampaignRequestTypeEnumMap, json['requestType']);

Map<String, dynamic> _$StatusChangeRequestToJson(
        StatusChangeRequest instance) =>
    <String, dynamic>{
      'id': instance.id,
      'campaignId': instance.campaignId,
      'ownerRecipientId': instance.ownerRecipientId,
      'title': instance.title,
      'justification': instance.justification,
      'requestDate': instance.requestDate?.toIso8601String(),
      'resolutionDate': instance.resolutionDate?.toIso8601String(),
      'requestType': _$CampaignRequestTypeEnumMap[instance.requestType]!,
      'resolutionType': _$ResolutionTypeEnumMap[instance.resolutionType],
      'newStatus': _$CampaignStatusEnumMap[instance.newStatus]!,
    };

const _$CampaignStatusEnumMap = {
  CampaignStatus.pendingReview: 'Pending Review',
  CampaignStatus.verified: 'Verified',
  CampaignStatus.denied: 'Denied',
  CampaignStatus.live: 'Live',
  CampaignStatus.paused: 'Paused',
  CampaignStatus.completed: 'Completed',
};

PostUpdateRequest _$PostUpdateRequestFromJson(Map<String, dynamic> json) =>
    PostUpdateRequest(
      id: json['id'] as String?,
      campaignId: json['campaignId'] as String,
      ownerRecipientId: json['ownerRecipientId'] as String,
      title: json['title'] as String,
      justification: json['justification'] as String,
      requestDate: json['requestDate'] == null
          ? null
          : DateTime.parse(json['requestDate'] as String),
      resolutionDate: json['resolutionDate'] == null
          ? null
          : DateTime.parse(json['resolutionDate'] as String),
      resolutionType:
          $enumDecodeNullable(_$ResolutionTypeEnumMap, json['resolutionType']),
      newPost: CampaignPost.fromJson(json['newPost'] as Map<String, dynamic>),
    )..requestType =
        $enumDecode(_$CampaignRequestTypeEnumMap, json['requestType']);

Map<String, dynamic> _$PostUpdateRequestToJson(PostUpdateRequest instance) =>
    <String, dynamic>{
      'id': instance.id,
      'campaignId': instance.campaignId,
      'ownerRecipientId': instance.ownerRecipientId,
      'title': instance.title,
      'justification': instance.justification,
      'requestDate': instance.requestDate?.toIso8601String(),
      'resolutionDate': instance.resolutionDate?.toIso8601String(),
      'requestType': _$CampaignRequestTypeEnumMap[instance.requestType]!,
      'resolutionType': _$ResolutionTypeEnumMap[instance.resolutionType],
      'newPost': instance.newPost.toJson(),
    };

EndDateExtensionRequest _$EndDateExtensionRequestFromJson(
        Map<String, dynamic> json) =>
    EndDateExtensionRequest(
      id: json['id'] as String?,
      campaignId: json['campaignId'] as String,
      ownerRecipientId: json['ownerRecipientId'] as String,
      title: json['title'] as String,
      justification: json['justification'] as String,
      requestDate: json['requestDate'] == null
          ? null
          : DateTime.parse(json['requestDate'] as String),
      resolutionDate: json['resolutionDate'] == null
          ? null
          : DateTime.parse(json['resolutionDate'] as String),
      resolutionType:
          $enumDecodeNullable(_$ResolutionTypeEnumMap, json['resolutionType']),
      newEndDate: DateTime.parse(json['newEndDate'] as String),
    )..requestType =
        $enumDecode(_$CampaignRequestTypeEnumMap, json['requestType']);

Map<String, dynamic> _$EndDateExtensionRequestToJson(
        EndDateExtensionRequest instance) =>
    <String, dynamic>{
      'id': instance.id,
      'campaignId': instance.campaignId,
      'ownerRecipientId': instance.ownerRecipientId,
      'title': instance.title,
      'justification': instance.justification,
      'requestDate': instance.requestDate?.toIso8601String(),
      'resolutionDate': instance.resolutionDate?.toIso8601String(),
      'requestType': _$CampaignRequestTypeEnumMap[instance.requestType]!,
      'resolutionType': _$ResolutionTypeEnumMap[instance.resolutionType],
      'newEndDate': instance.newEndDate.toIso8601String(),
    };
