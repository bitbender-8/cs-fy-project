import 'package:mobile/config.dart';
import 'package:mobile/models/campaign.dart';
import 'package:mobile/models/campaign_request.dart';

abstract class ListFilter {
  int page;
  int limit;

  ListFilter({this.page = 1, this.limit = pageSize});

  Map<String, String>? toMap();
  ListFilter copyWith({int? page, int? limit});
}

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

  @override
  RecipientFilter copyWith({
    String? auth0UserId,
    String? name,
    String? email,
    DateTime? minBirthDate,
    DateTime? maxBirthDate,
    String? phoneNo,
    int? page,
    int? limit,
  }) {
    return RecipientFilter(
      auth0UserId: auth0UserId ?? this.auth0UserId,
      name: name ?? this.name,
      email: email ?? this.email,
      minBirthDate: minBirthDate ?? this.minBirthDate,
      maxBirthDate: maxBirthDate ?? this.maxBirthDate,
      phoneNo: phoneNo ?? this.phoneNo,
      page: page ?? this.page,
      limit: limit ?? this.limit,
    );
  }
}

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
      'status': status?.toString().split('.').last,
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

  @override
  CampaignFilter copyWith({
    String? title,
    CampaignStatus? status,
    String? category,
    DateTime? minLaunchDate,
    DateTime? maxLaunchDate,
    DateTime? minEndDate,
    DateTime? maxEndDate,
    DateTime? minSubmissionDate,
    DateTime? maxSubmissionDate,
    DateTime? minVerificationDate,
    DateTime? maxVerificationDate,
    DateTime? minDenialDate,
    DateTime? maxDenialDate,
    String? ownerRecipientId,
    bool? isPublic,
    int? page,
    int? limit,
  }) {
    return CampaignFilter(
      title: title ?? this.title,
      status: status ?? this.status,
      category: category ?? this.category,
      minLaunchDate: minLaunchDate ?? this.minLaunchDate,
      maxLaunchDate: maxLaunchDate ?? this.maxLaunchDate,
      minEndDate: minEndDate ?? this.minEndDate,
      maxEndDate: maxEndDate ?? this.maxEndDate,
      minSubmissionDate: minSubmissionDate ?? this.minSubmissionDate,
      maxSubmissionDate: maxSubmissionDate ?? this.maxSubmissionDate,
      minVerificationDate: minVerificationDate ?? this.minVerificationDate,
      maxVerificationDate: maxVerificationDate ?? this.maxVerificationDate,
      minDenialDate: minDenialDate ?? this.minDenialDate,
      maxDenialDate: maxDenialDate ?? this.maxDenialDate,
      ownerRecipientId: ownerRecipientId ?? this.ownerRecipientId,
      isPublic: isPublic ?? this.isPublic,
      page: page ?? this.page,
      limit: limit ?? this.limit,
    );
  }
}

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

  @override
  NotificationFilter copyWith({
    bool? isRead,
    DateTime? minCreatedAt,
    DateTime? maxCreatedAt,
    int? page,
    int? limit,
  }) {
    return NotificationFilter(
      isRead: isRead ?? this.isRead,
      minCreatedAt: minCreatedAt ?? this.minCreatedAt,
      maxCreatedAt: maxCreatedAt ?? this.maxCreatedAt,
      page: page ?? this.page,
      limit: limit ?? this.limit,
    );
  }
}

class CampaignRequestFilter extends ListFilter {
  String? ownerRecipientId;
  String? campaignId;
  CampaignRequestType? campaignRequestType;
  bool? isResolved;
  ResolutionType? resolutionType;
  DateTime? minRequestDate;
  DateTime? maxRequestDate;
  DateTime? minResolutionDate;
  DateTime? maxResolutionDate;
  String? title;

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
      'requestType': campaignRequestType?.toString().split('.').last,
      'isResolved': isResolved?.toString(),
      'resolutionType': resolutionType?.toString().split('.').last,
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

  @override
  CampaignRequestFilter copyWith({
    String? ownerRecipientId,
    String? campaignId,
    CampaignRequestType? campaignRequestType,
    bool? isResolved,
    ResolutionType? resolutionType,
    DateTime? minRequestDate,
    DateTime? maxRequestDate,
    DateTime? minResolutionDate,
    DateTime? maxResolutionDate,
    String? title,
    int? page,
    int? limit,
  }) {
    return CampaignRequestFilter(
      ownerRecipientId: ownerRecipientId ?? this.ownerRecipientId,
      campaignId: campaignId ?? this.campaignId,
      campaignRequestType: campaignRequestType ?? this.campaignRequestType,
      isResolved: isResolved ?? this.isResolved,
      resolutionType: resolutionType ?? this.resolutionType,
      minRequestDate: minRequestDate ?? this.minRequestDate,
      maxRequestDate: maxRequestDate ?? this.maxRequestDate,
      minResolutionDate: minResolutionDate ?? this.minResolutionDate,
      maxResolutionDate: maxResolutionDate ?? this.maxResolutionDate,
      title: title ?? this.title,
      page: page ?? this.page,
      limit: limit ?? this.limit,
    );
  }
}
