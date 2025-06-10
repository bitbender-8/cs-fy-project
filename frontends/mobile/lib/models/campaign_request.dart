import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mobile/models/campaign.dart';

part 'campaign_request.g.dart';

enum CampaignRequestType {
  @JsonValue("Goal Adjustment")
  goalAdjustment("Goal Adjustment"),

  @JsonValue("Post Update")
  postUpdate("Post Update"),

  @JsonValue("End Date Extension")
  endDateExtension("End Date Extension"),

  @JsonValue("Status Change")
  statusChange("Status Change");

  final String value;
  const CampaignRequestType(this.value);

  static Color getBackgroundColor(
    CampaignRequestType type,
    ColorScheme colorScheme,
  ) {
    switch (type) {
      case CampaignRequestType.goalAdjustment:
        return colorScheme.tertiaryContainer;
      case CampaignRequestType.postUpdate:
        return colorScheme.primaryContainer;
      case CampaignRequestType.endDateExtension:
        return colorScheme.secondaryContainer;
      case CampaignRequestType.statusChange:
        return colorScheme.errorContainer;
    }
  }

  static Color getTextColor(
    CampaignRequestType type,
    ColorScheme colorScheme,
  ) {
    switch (type) {
      case CampaignRequestType.goalAdjustment:
        return colorScheme.onTertiaryContainer;
      case CampaignRequestType.postUpdate:
        return colorScheme.onPrimaryContainer;
      case CampaignRequestType.endDateExtension:
        return colorScheme.onSecondaryContainer;
      case CampaignRequestType.statusChange:
        return colorScheme.onErrorContainer;
    }
  }
}

enum ResolutionType {
  @JsonValue("Accepted")
  accepted("Accepted"),

  @JsonValue("Rejected")
  rejected("Rejected");

  final String value;
  const ResolutionType(this.value);

  static Color getBackgroundColor(
    ResolutionType? resolutionType,
    ColorScheme colorScheme,
  ) {
    if (resolutionType == null) return colorScheme.secondaryContainer;

    switch (resolutionType) {
      case ResolutionType.accepted:
        return colorScheme.primaryContainer;
      case ResolutionType.rejected:
        return colorScheme.errorContainer;
    }
  }

  static Color getTextColor(
    ResolutionType? resolutionType,
    ColorScheme colorScheme,
  ) {
    if (resolutionType == null) return colorScheme.onSecondaryContainer;

    switch (resolutionType) {
      case ResolutionType.accepted:
        return colorScheme.onPrimaryContainer;
      case ResolutionType.rejected:
        return colorScheme.onErrorContainer;
    }
  }
}

@JsonSerializable(explicitToJson: true, createFactory: false)
abstract class CampaignRequest {
  String? id;
  String campaignId;
  String ownerRecipientId;
  String title;
  String justification;
  DateTime? requestDate;
  DateTime? resolutionDate;
  CampaignRequestType requestType;
  ResolutionType? resolutionType;

  CampaignRequest({
    this.id,
    required this.campaignId,
    required this.ownerRecipientId,
    required this.title,
    required this.justification,
    required this.requestType,
    this.requestDate,
    this.resolutionDate,
    this.resolutionType,
  });

  factory CampaignRequest.fromJson(Map<String, dynamic> json) {
    final String? apiRequestTypeString = json['requestType'] as String?;
    if (apiRequestTypeString == null) {
      throw Exception('Missing "requestType" in CampaignRequest JSON: $json');
    }

    CampaignRequestType requestType;
    try {
      requestType = CampaignRequestType.values.firstWhere(
        (type) =>
            type.value.toLowerCase() == apiRequestTypeString.toLowerCase(),
        orElse: () => CampaignRequestType.values.firstWhere(
            (type) =>
                type.name.toLowerCase() == apiRequestTypeString.toLowerCase(),
            orElse: () => throw Exception(
                'Unknown or unmatchable campaign request type string from API: $apiRequestTypeString')),
      );
    } catch (e) {
      throw Exception(
          'Failed to parse campaign request type "$apiRequestTypeString": $e');
    }

    switch (requestType) {
      case CampaignRequestType.goalAdjustment:
        return GoalAdjustmentRequest.fromJson(json);
      case CampaignRequestType.statusChange:
        return StatusChangeRequest.fromJson(json);
      case CampaignRequestType.postUpdate:
        return PostUpdateRequest.fromJson(json);
      case CampaignRequestType.endDateExtension:
        return EndDateExtensionRequest.fromJson(json);
    }
  }

  // Define the base toJson method that includes common fields
  Map<String, dynamic> toJson() => _$CampaignRequestToJson(this);
}

@CopyWith()
@JsonSerializable(explicitToJson: true)
class GoalAdjustmentRequest extends CampaignRequest {
  String newGoal;

  GoalAdjustmentRequest({
    super.id,
    required super.campaignId,
    required super.ownerRecipientId,
    required super.title,
    required super.justification,
    super.requestDate,
    super.resolutionDate,
    super.resolutionType,
    required this.newGoal,
  }) : super(requestType: CampaignRequestType.goalAdjustment);

  factory GoalAdjustmentRequest.fromJson(Map<String, dynamic> json) =>
      _$GoalAdjustmentRequestFromJson(json);

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{}
    ..addAll(super.toJson())
    ..addAll(_$GoalAdjustmentRequestToJson(this));
}

@CopyWith()
@JsonSerializable(explicitToJson: true)
class StatusChangeRequest extends CampaignRequest {
  CampaignStatus newStatus;

  StatusChangeRequest({
    super.id,
    required super.campaignId,
    required super.ownerRecipientId,
    required super.title,
    required super.justification,
    super.requestDate,
    super.resolutionDate,
    super.resolutionType,
    required this.newStatus,
  }) : super(requestType: CampaignRequestType.statusChange);

  factory StatusChangeRequest.fromJson(Map<String, dynamic> json) =>
      _$StatusChangeRequestFromJson(json);

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{}
    ..addAll(super.toJson())
    ..addAll(_$StatusChangeRequestToJson(this));
}

@CopyWith()
@JsonSerializable(explicitToJson: true)
class PostUpdateRequest extends CampaignRequest {
  CampaignPost newPost;

  PostUpdateRequest({
    super.id,
    required super.campaignId,
    required super.ownerRecipientId,
    required super.title,
    required super.justification,
    super.requestDate,
    super.resolutionDate,
    super.resolutionType,
    required this.newPost,
  }) : super(requestType: CampaignRequestType.postUpdate);

  factory PostUpdateRequest.fromJson(Map<String, dynamic> json) =>
      _$PostUpdateRequestFromJson(json);

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{}
    ..addAll(super.toJson())
    ..addAll(_$PostUpdateRequestToJson(this));
}

@CopyWith()
@JsonSerializable(explicitToJson: true)
class EndDateExtensionRequest extends CampaignRequest {
  DateTime newEndDate;

  EndDateExtensionRequest({
    super.id,
    required super.campaignId,
    required super.ownerRecipientId,
    required super.title,
    required super.justification,
    super.requestDate,
    super.resolutionDate,
    super.resolutionType,
    required this.newEndDate,
  }) : super(requestType: CampaignRequestType.endDateExtension);

  factory EndDateExtensionRequest.fromJson(Map<String, dynamic> json) =>
      _$EndDateExtensionRequestFromJson(json);

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{}
    ..addAll(super.toJson())
    ..addAll(_$EndDateExtensionRequestToJson(this));
}
