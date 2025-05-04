import 'package:mobile/models/payment_info.dart';

class Campaign {
  String? id;
  String ownerRecipientId;
  String title;
  String description;
  String fundraisingGoal;
  CampaignStatus? status;
  String category;
  DateTime? launchDate;
  DateTime endDate;
  DateTime? submissionDate;
  DateTime? verificationDate;
  DateTime? denialDate;
  List<CampaignDocument>? documents;
  PaymentInfo? paymentInfo;

  Campaign({
    this.id,
    required this.ownerRecipientId,
    required this.title,
    required this.description,
    required this.fundraisingGoal,
    this.status,
    required this.category,
    this.launchDate,
    required this.endDate,
    this.submissionDate,
    this.verificationDate,
    this.denialDate,
    this.documents,
    this.paymentInfo,
  });
}

enum CampaignStatus {
  pendingReview("Pending Review"),
  verified("Verified"),
  denied("Denied"),
  live("Live"),
  paused("Paused"),
  completed("Completed");

  final String value;
  const CampaignStatus(this.value);
}

class CampaignDocument {
  String campaignId;
  String? documentUrl;
  String? redactedDocumentUrl;

  CampaignDocument({
    required this.campaignId,
    this.documentUrl,
    this.redactedDocumentUrl,
  });
}

class CampaignDonation {
  String id;
  String grossAmount;
  String serviceFee;
  DateTime createdAt;
  String campaignId;

  CampaignDonation({
    required this.id,
    required this.grossAmount,
    required this.serviceFee,
    required this.createdAt,
    required this.campaignId,
  });
}

class CampaignPost {
  String id;
  String title;
  String content;
  DateTime? publicPostDate;
  String campaignId;

  CampaignPost({
    required this.id,
    required this.title,
    required this.content,
    this.publicPostDate,
    required this.campaignId,
  });
}
