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
  List<CampaignDocument>? documents;
  PaymentInfo? paymentInfo;

  @JsonKey(includeToJson: false, includeFromJson: false)
  List<CampaignDonation>? campaignDonations;
  @JsonKey(includeToJson: false, includeFromJson: false)
  List<CampaignPost>? campaignPosts;
  @JsonKey(includeToJson: false, includeFromJson: false)
  Recipient? ownerRecipient;

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
    required this.paymentInfo,
    this.campaignDonations,
    this.campaignPosts,
    this.ownerRecipient,
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

  double get totalDonated {
    final donations = campaignDonations ?? [];
    final goalAmount = double.tryParse(fundraisingGoal) ?? 0.0;

    if (goalAmount == 0) {
      return 0.0;
    }

    return donations.fold<double>(0.0, (sum, donation) {
      final amount = double.tryParse(donation.grossAmount) ?? 0.0;
      return sum + amount;
    });
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

  @override
  String toString() => value;
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

  factory CampaignPost.fromJson(Map<String, dynamic> json) =>
      _$CampaignPostFromJson(json);
  Map<String, dynamic> toJson() => _$CampaignPostToJson(this);
}

enum CampaignCategories {
  charity('Charity'),
  education('Education'),
  health('Health'),
  environment('Environment'),
  animalWelfare('Animal Welfare'),
  community('Community'),
  artsAndCulture('Arts and Culture'),
  youth('Youth');

  final String value;
  const CampaignCategories(this.value);
}
