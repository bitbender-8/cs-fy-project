// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'campaign_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

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

const _$ResolutionTypeEnumMap = {
  ResolutionType.accepted: 'Accepted',
  ResolutionType.rejected: 'Rejected',
};

const _$CampaignRequestTypeEnumMap = {
  CampaignRequestType.goalAdjustment: 'Goal Adjustment',
  CampaignRequestType.postUpdate: 'Post Update',
  CampaignRequestType.endDateExtension: 'End Date Extension',
  CampaignRequestType.statusChange: 'Status Change',
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
