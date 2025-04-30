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
  DateTime? resolutionDate;
  RequestType requestType;

  CampaignRequest({
    this.id,
    required this.campaignId,
    required this.ownerRecipientId,
    required this.title,
    required this.justification,
    required this.requestType,
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
    required this.newEndDate,
  }) : super(requestType: RequestType.endDateExtension);
}
