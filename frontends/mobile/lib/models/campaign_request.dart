import 'package:json_annotation/json_annotation.dart';
import 'package:mobile/models/campaign.dart';

part 'campaign_request.g.dart';

@JsonEnum(valueField: 'value')
enum CampaignRequestType {
  goalAdjustment("Goal Adjustment"),
  postUpdate("Post Update"),
  endDateExtension("End Date Extension"),
  statusChange("Status Change");

  final String value;
  const CampaignRequestType(this.value);

  static CampaignRequestType fromValue(String value) {
    return CampaignRequestType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => throw ArgumentError(
        "Unknown CampaignRequestType value: $value",
      ),
    );
  }
}

@JsonEnum(valueField: 'value')
enum ResolutionType {
  accepted("Accepted"),
  rejected("Rejected");

  final String value;
  const ResolutionType(this.value);
}

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

  Map<String, dynamic> toJson();
}

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
  Map<String, dynamic> toJson() => _$GoalAdjustmentRequestToJson(this);
}

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
  Map<String, dynamic> toJson() => _$StatusChangeRequestToJson(this);
}

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
  Map<String, dynamic> toJson() => _$PostUpdateRequestToJson(this);
}

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
  Map<String, dynamic> toJson() => _$EndDateExtensionRequestToJson(this);
}
