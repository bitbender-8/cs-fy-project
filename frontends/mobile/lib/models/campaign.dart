import 'package:json_annotation/json_annotation.dart';
import 'package:mobile/models/payment_info.dart';
import 'package:mobile/models/recipient.dart';

part 'campaign.g.dart';

@JsonSerializable(explicitToJson: true)
class Campaign {
  String? id;
  String ownerRecipientId;
  String title;
  String description;
  String fundraisingGoal;

  @CampaignStatusConverter()
  CampaignStatus? status;

  String category;
  DateTime? launchDate;
  DateTime? endDate;
  DateTime? submissionDate;
  DateTime? verificationDate;
  DateTime? denialDate;
  List<CampaignDocument> documents;
  PaymentInfo? paymentInfo;
  String? totalDonated;

  @JsonKey(includeToJson: false, includeFromJson: false)
  List<CampaignPost>? campaignPosts;
  @JsonKey(includeToJson: false, includeFromJson: false)
  Recipient? campaignOwner;
  @JsonKey(includeFromJson: true, includeToJson: false)
  bool? isPublic;

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
    this.documents = const [],
    required this.paymentInfo,
    this.campaignPosts,
    this.campaignOwner,
    this.totalDonated,
    this.isPublic,
  });

  factory Campaign.fromJson(Map<String, dynamic> json) =>
      _$CampaignFromJson(json);

  Map<String, dynamic> toJson() => _$CampaignToJson(this);

  Duration? get timeRemaining {
    final now = DateTime.now();
    final difference = endDate?.difference(now);
    return difference != null && difference.isNegative
        ? Duration.zero
        : difference;
  }

  Campaign copyWith(
      {String? id,
      String? ownerRecipientId,
      String? title,
      String? description,
      String? fundraisingGoal,
      CampaignStatus? status,
      String? category,
      DateTime? launchDate,
      DateTime? endDate,
      DateTime? submissionDate,
      DateTime? verificationDate,
      DateTime? denialDate,
      List<CampaignDocument>? documents,
      PaymentInfo? paymentInfo,
      String? totalDonated,
      List<CampaignPost>? campaignPosts,
      Recipient? campaignOwner,
      bool? isPublic}) {
    return Campaign(
      id: id ?? this.id,
      ownerRecipientId: ownerRecipientId ?? this.ownerRecipientId,
      title: title ?? this.title,
      description: description ?? this.description,
      fundraisingGoal: fundraisingGoal ?? this.fundraisingGoal,
      status: status ?? this.status,
      category: category ?? this.category,
      launchDate: launchDate ?? this.launchDate,
      endDate: endDate ?? this.endDate,
      submissionDate: submissionDate ?? this.submissionDate,
      verificationDate: verificationDate ?? this.verificationDate,
      denialDate: denialDate ?? this.denialDate,
      documents: documents ?? this.documents,
      paymentInfo: paymentInfo ?? this.paymentInfo,
      campaignPosts: campaignPosts ?? this.campaignPosts,
      campaignOwner: campaignOwner ?? this.campaignOwner,
      totalDonated: totalDonated ?? this.totalDonated,
      isPublic: isPublic ?? this.isPublic,
    );
  }
}

@JsonEnum(valueField: 'value')
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

class CampaignStatusConverter implements JsonConverter<CampaignStatus, String> {
  const CampaignStatusConverter();

  @override
  CampaignStatus fromJson(String json) {
    return CampaignStatus.values.firstWhere(
      (e) => e.value == json,
      orElse: () => throw ArgumentError('Unknown CampaignStatus: $json'),
    );
  }

  @override
  String toJson(CampaignStatus object) => object.value;
}

@JsonSerializable(explicitToJson: true)
class CampaignDocument {
  String campaignId;
  String? documentUrl;
  String? redactedDocumentUrl;

  CampaignDocument({
    required this.campaignId,
    this.documentUrl,
    this.redactedDocumentUrl,
  });

  factory CampaignDocument.fromJson(Map<String, dynamic> json) =>
      _$CampaignDocumentFromJson(json);

  Map<String, dynamic> toJson() => _$CampaignDocumentToJson(this);
}

@JsonSerializable(explicitToJson: true)
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

  factory CampaignDonation.fromJson(Map<String, dynamic> json) =>
      _$CampaignDonationFromJson(json);

  Map<String, dynamic> toJson() => _$CampaignDonationToJson(this);
}

@JsonSerializable(explicitToJson: true)
class CampaignPost {
  String? id;
  String title;
  String content;
  DateTime? publicPostDate;
  String campaignId;

  CampaignPost({
    this.id,
    required this.title,
    required this.content,
    this.publicPostDate,
    required this.campaignId,
  });

  factory CampaignPost.fromJson(Map<String, dynamic> json) =>
      _$CampaignPostFromJson(json);
  Map<String, dynamic> toJson() => _$CampaignPostToJson(this);
}

enum CampaignCategories {
  charity('Charity'),
  education('Education'),
  health('Health'),
  animalWelfare('Animal Welfare'),
  community('Community'),
  youth('Youth');

  final String value;
  const CampaignCategories(this.value);
}
