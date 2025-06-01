import 'package:mobile/models/payment_info.dart';
import 'package:mobile/models/recipient.dart';

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

  //TODO: Not Json serialized
  List<CampaignDonation>? campaignDonations;
  List<CampaignPost>? campaignPosts;
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
    this.paymentInfo,
    this.campaignDonations,
    this.campaignPosts,
    this.ownerRecipient,
  });

  Duration get timeRemaining {
    final now = DateTime.now();
    final difference = endDate.difference(now);
    return difference.isNegative ? Duration.zero : difference;
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

  // Add the fromJson method for deserialization
  factory CampaignPost.fromJson(Map<String, dynamic> json) {
    return CampaignPost(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      publicPostDate: json['publicPostDate'] != null
          ? DateTime.parse(json['publicPostDate'])
          : null,
      campaignId: json['campaignId'],
    );
  }
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

enum PaymentMethods {
  bankTransfer('Bank Transfer'),
  mobileMoney('Mobile Money'),
  creditCard('Credit Card');

  final String value;
  const PaymentMethods(this.value);
}
