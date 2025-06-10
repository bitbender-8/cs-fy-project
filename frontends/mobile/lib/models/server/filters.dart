import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:mobile/config.dart';
import 'package:mobile/models/campaign.dart';
import 'package:mobile/models/campaign_request.dart';

part 'filters.g.dart';

abstract class ListFilter {
  int page;
  int limit;

  ListFilter({this.page = 1, this.limit = AppConfig.pageSize});

  Map<String, String>? toMap();
}

@CopyWith()
class RecipientFilter extends ListFilter {
  String? auth0UserId;
  String? name;
  String? email;

  DateTime? minBirthDate;
  DateTime? maxBirthDate;
  String? phoneNo;

  RecipientFilter({
    this.auth0UserId,
    this.name,
    this.email,
    this.minBirthDate,
    this.maxBirthDate,
    this.phoneNo,
    super.page,
    super.limit,
  });

  @override
  Map<String, String>? toMap() {
    final map = <String, String?>{
      'auth0UserId': auth0UserId,
      'name': name,
      'email': email,
      'minBirthDate': minBirthDate?.toIso8601String(),
      'maxBirthDate': maxBirthDate?.toIso8601String(),
      'phoneNo': phoneNo,
      'page': page.toString(),
      'limit': limit.toString(),
    };

    map.removeWhere((key, value) => value == null);
    return map.isEmpty ? null : Map<String, String>.from(map);
  }
}

@CopyWith()
class CampaignFilter extends ListFilter {
  String? title;
  CampaignStatus? status;
  String? category;
  DateTime? minLaunchDate;
  DateTime? maxLaunchDate;
  DateTime? minEndDate;
  DateTime? maxEndDate;
  DateTime? minSubmissionDate;
  DateTime? maxSubmissionDate;
  DateTime? minVerificationDate;
  DateTime? maxVerificationDate;
  DateTime? minDenialDate;
  DateTime? maxDenialDate;
  String? ownerRecipientId;
  bool? isPublic;

  CampaignFilter({
    this.title,
    this.status,
    this.category,
    this.minLaunchDate,
    this.maxLaunchDate,
    this.minEndDate,
    this.maxEndDate,
    this.minSubmissionDate,
    this.maxSubmissionDate,
    this.minVerificationDate,
    this.maxVerificationDate,
    this.minDenialDate,
    this.maxDenialDate,
    this.ownerRecipientId,
    this.isPublic,
    super.page,
    super.limit,
  });

  @override
  Map<String, String>? toMap() {
    final map = <String, String?>{
      'title': title,
      'status': status?.value,
      'category': category,
      'minLaunchDate': minLaunchDate?.toIso8601String(),
      'maxLaunchDate': maxLaunchDate?.toIso8601String(),
      'minEndDate': minEndDate?.toIso8601String(),
      'maxEndDate': maxEndDate?.toIso8601String(),
      'minSubmissionDate': minSubmissionDate?.toIso8601String(),
      'maxSubmissionDate': maxSubmissionDate?.toIso8601String(),
      'minVerificationDate': minVerificationDate?.toIso8601String(),
      'maxVerificationDate': maxVerificationDate?.toIso8601String(),
      'minDenialDate': minDenialDate?.toIso8601String(),
      'maxDenialDate': maxDenialDate?.toIso8601String(),
      'ownerRecipientId': ownerRecipientId,
      'isPublic': isPublic?.toString(),
      'page': page.toString(),
      'limit': limit.toString(),
    };

    map.removeWhere((key, value) => value == null);
    return map.isEmpty ? null : Map<String, String>.from(map);
  }
}

@CopyWith()
class NotificationFilter extends ListFilter {
  bool? isRead;
  DateTime? minCreatedAt;
  DateTime? maxCreatedAt;

  NotificationFilter({
    this.isRead,
    this.minCreatedAt,
    this.maxCreatedAt,
    super.page,
    super.limit,
  });

  @override
  Map<String, String>? toMap() {
    final map = <String, String?>{
      'isRead': isRead?.toString(),
      'minCreatedAt': minCreatedAt?.toIso8601String(),
      'maxCreatedAt': maxCreatedAt?.toIso8601String(),
      'page': page.toString(),
      'limit': limit.toString(),
    };

    map.removeWhere((key, value) => value == null);
    return map.isEmpty ? null : Map<String, String>.from(map);
  }
}

@CopyWith()
class CampaignRequestFilter extends ListFilter {
  String? ownerRecipientId;
  String? campaignId;
  String? title;
  CampaignRequestType? campaignRequestType;
  DateTime? minRequestDate;
  DateTime? maxRequestDate;
  DateTime? minResolutionDate;
  DateTime? maxResolutionDate;
  ResolutionType? resolutionType;
  bool? isResolved;

  CampaignRequestFilter({
    this.ownerRecipientId,
    this.campaignId,
    this.campaignRequestType,
    this.isResolved,
    this.resolutionType,
    this.minRequestDate,
    this.maxRequestDate,
    this.minResolutionDate,
    this.maxResolutionDate,
    this.title,
    super.page,
    super.limit,
  });

  @override
  Map<String, String>? toMap() {
    final map = <String, String?>{
      'ownerRecipientId': ownerRecipientId,
      'campaignId': campaignId,
      'requestType': campaignRequestType?.value,
      'isResolved': isResolved?.toString(),
      'resolutionType': resolutionType?.value,
      'minRequestDate': minRequestDate?.toIso8601String(),
      'maxRequestDate': maxRequestDate?.toIso8601String(),
      'minResolutionDate': minResolutionDate?.toIso8601String(),
      'maxResolutionDate': maxResolutionDate?.toIso8601String(),
      'title': title,
      'page': page.toString(),
      'limit': limit.toString(),
    };

    map.removeWhere((key, value) => value == null);
    return map.isEmpty ? null : Map<String, String>.from(map);
  }
}

@CopyWith()
class CampaignPostFilter extends ListFilter {
  String? title;
  String? campaignId;
  bool? isPublic;
  DateTime? minPublicPostDate;
  DateTime? maxPublicPostDate;

  CampaignPostFilter({
    this.title,
    this.campaignId,
    this.isPublic,
    this.minPublicPostDate,
    this.maxPublicPostDate,
  });

  @override
  Map<String, String>? toMap() {
    final map = <String, String?>{
      'title': title,
      'campaignId': campaignId,
      'isPublic': isPublic?.toString(),
      'minPublicPostDate': minPublicPostDate?.toIso8601String(),
      'maxPublicPostDate': maxPublicPostDate?.toIso8601String(),
    };

    map.removeWhere((key, value) => value == null);
    return map.isEmpty ? null : Map<String, String>.from(map);
  }
}
