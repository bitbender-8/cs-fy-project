import 'package:mobile/config.dart';
import 'package:mobile/models/campaign.dart';

abstract class ListFilter {
  int page;
  int limit;

  ListFilter({this.page = 1, this.limit = pageSize});

  Map<String, String>? toMap();
}

class RecipientFilters extends ListFilter {
  String? auth0UserId;
  String? name;
  String? email;

  DateTime? minBirthDate;
  DateTime? maxBirthDate;
  String? phoneNo;

  RecipientFilters({
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
      'isPublic': isPublic?.toString(),
      'page': page.toString(),
      'limit': limit.toString(),
    };

    map.removeWhere((key, value) => value == null);
    return map.isEmpty ? null : Map<String, String>.from(map);
  }

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
      isPublic: isPublic ?? this.isPublic,
      page: page ?? this.page,
      limit: limit ?? this.limit,
    );
  }
}
