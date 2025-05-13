import 'package:mobile/models/campaign.dart';

enum RequestType {
  goalAdjustment("Goal Adjustment"),
  postUpdate("Post Update"),
  endDateExtension("End Date Extension"),
  statusChange("Status Change");

  final String value;
  const RequestType(this.value);
}

abstract class CampaignRequest {
  String? id;
  String campaignId;
  String ownerRecipientId;
  String title;
  String justification;
  DateTime? requestDate;
  DateTime? resolutionDate;

  CampaignRequest(
      {this.id,
      required this.campaignId,
      required this.ownerRecipientId,
      required this.title,
      required this.justification,
      this.requestDate,
      this.resolutionDate});
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
    required this.newGoal,
  });
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
    required this.newStatus,
  });
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
    required this.newPost,
  });
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
    required this.newEndDate,
  });
}
