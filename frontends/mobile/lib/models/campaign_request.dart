import 'package:mobile/models/campaign.dart';

enum RequestType {
  goalAdjustment("Goal Adjustment"),
  postUpdate("Post Update"),
  endDateExtension("End Date Extension"),
  statusChange("Status Change");

  final String value;
  const RequestType(this.value);
}

enum ResolutionType {
  accepted,
  rejected;

  static ResolutionType? fromString(String? value) {
    if (value == null) return null;
    try {
      return ResolutionType.values.byName(value);
    } catch (e) {
      for (var entry in ResolutionType.values) {
        if (entry.name.toLowerCase() == value.toLowerCase()) {
          return entry;
        }
      }
      return null;
    }
  }
}

abstract class CampaignRequest {
  String? id;
  String campaignId;
  String ownerRecipientId;
  String title;
  String justification;
  DateTime? requestDate;
  DateTime? resolutionDate;
  RequestType requestType;
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
    this.resolutionType
  });
}

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
  }) : super(requestType: RequestType.goalAdjustment);
}

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
  }) : super(requestType: RequestType.statusChange);
}

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
  }) : super(requestType: RequestType.postUpdate);
}

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
  }) : super(requestType: RequestType.endDateExtension);
}
