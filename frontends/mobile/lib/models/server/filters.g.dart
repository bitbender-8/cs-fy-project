// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'filters.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$RecipientFilterCWProxy {
  RecipientFilter auth0UserId(String? auth0UserId);

  RecipientFilter name(String? name);

  RecipientFilter email(String? email);

  RecipientFilter minBirthDate(DateTime? minBirthDate);

  RecipientFilter maxBirthDate(DateTime? maxBirthDate);

  RecipientFilter phoneNo(String? phoneNo);

  RecipientFilter page(int page);

  RecipientFilter limit(int limit);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RecipientFilter(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RecipientFilter(...).copyWith(id: 12, name: "My name")
  /// ````
  RecipientFilter call({
    String? auth0UserId,
    String? name,
    String? email,
    DateTime? minBirthDate,
    DateTime? maxBirthDate,
    String? phoneNo,
    int page,
    int limit,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfRecipientFilter.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfRecipientFilter.copyWith.fieldName(...)`
class _$RecipientFilterCWProxyImpl implements _$RecipientFilterCWProxy {
  const _$RecipientFilterCWProxyImpl(this._value);

  final RecipientFilter _value;

  @override
  RecipientFilter auth0UserId(String? auth0UserId) =>
      this(auth0UserId: auth0UserId);

  @override
  RecipientFilter name(String? name) => this(name: name);

  @override
  RecipientFilter email(String? email) => this(email: email);

  @override
  RecipientFilter minBirthDate(DateTime? minBirthDate) =>
      this(minBirthDate: minBirthDate);

  @override
  RecipientFilter maxBirthDate(DateTime? maxBirthDate) =>
      this(maxBirthDate: maxBirthDate);

  @override
  RecipientFilter phoneNo(String? phoneNo) => this(phoneNo: phoneNo);

  @override
  RecipientFilter page(int page) => this(page: page);

  @override
  RecipientFilter limit(int limit) => this(limit: limit);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RecipientFilter(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RecipientFilter(...).copyWith(id: 12, name: "My name")
  /// ````
  RecipientFilter call({
    Object? auth0UserId = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? email = const $CopyWithPlaceholder(),
    Object? minBirthDate = const $CopyWithPlaceholder(),
    Object? maxBirthDate = const $CopyWithPlaceholder(),
    Object? phoneNo = const $CopyWithPlaceholder(),
    Object? page = const $CopyWithPlaceholder(),
    Object? limit = const $CopyWithPlaceholder(),
  }) {
    return RecipientFilter(
      auth0UserId: auth0UserId == const $CopyWithPlaceholder()
          ? _value.auth0UserId
          // ignore: cast_nullable_to_non_nullable
          : auth0UserId as String?,
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String?,
      email: email == const $CopyWithPlaceholder()
          ? _value.email
          // ignore: cast_nullable_to_non_nullable
          : email as String?,
      minBirthDate: minBirthDate == const $CopyWithPlaceholder()
          ? _value.minBirthDate
          // ignore: cast_nullable_to_non_nullable
          : minBirthDate as DateTime?,
      maxBirthDate: maxBirthDate == const $CopyWithPlaceholder()
          ? _value.maxBirthDate
          // ignore: cast_nullable_to_non_nullable
          : maxBirthDate as DateTime?,
      phoneNo: phoneNo == const $CopyWithPlaceholder()
          ? _value.phoneNo
          // ignore: cast_nullable_to_non_nullable
          : phoneNo as String?,
      page: page == const $CopyWithPlaceholder()
          ? _value.page
          // ignore: cast_nullable_to_non_nullable
          : page as int,
      limit: limit == const $CopyWithPlaceholder()
          ? _value.limit
          // ignore: cast_nullable_to_non_nullable
          : limit as int,
    );
  }
}

extension $RecipientFilterCopyWith on RecipientFilter {
  /// Returns a callable class that can be used as follows: `instanceOfRecipientFilter.copyWith(...)` or like so:`instanceOfRecipientFilter.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$RecipientFilterCWProxy get copyWith => _$RecipientFilterCWProxyImpl(this);
}

abstract class _$CampaignFilterCWProxy {
  CampaignFilter title(String? title);

  CampaignFilter status(CampaignStatus? status);

  CampaignFilter category(String? category);

  CampaignFilter minLaunchDate(DateTime? minLaunchDate);

  CampaignFilter maxLaunchDate(DateTime? maxLaunchDate);

  CampaignFilter minEndDate(DateTime? minEndDate);

  CampaignFilter maxEndDate(DateTime? maxEndDate);

  CampaignFilter minSubmissionDate(DateTime? minSubmissionDate);

  CampaignFilter maxSubmissionDate(DateTime? maxSubmissionDate);

  CampaignFilter minVerificationDate(DateTime? minVerificationDate);

  CampaignFilter maxVerificationDate(DateTime? maxVerificationDate);

  CampaignFilter minDenialDate(DateTime? minDenialDate);

  CampaignFilter maxDenialDate(DateTime? maxDenialDate);

  CampaignFilter ownerRecipientId(String? ownerRecipientId);

  CampaignFilter isPublic(bool? isPublic);

  CampaignFilter page(int page);

  CampaignFilter limit(int limit);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CampaignFilter(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CampaignFilter(...).copyWith(id: 12, name: "My name")
  /// ````
  CampaignFilter call({
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
    int page,
    int limit,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCampaignFilter.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCampaignFilter.copyWith.fieldName(...)`
class _$CampaignFilterCWProxyImpl implements _$CampaignFilterCWProxy {
  const _$CampaignFilterCWProxyImpl(this._value);

  final CampaignFilter _value;

  @override
  CampaignFilter title(String? title) => this(title: title);

  @override
  CampaignFilter status(CampaignStatus? status) => this(status: status);

  @override
  CampaignFilter category(String? category) => this(category: category);

  @override
  CampaignFilter minLaunchDate(DateTime? minLaunchDate) =>
      this(minLaunchDate: minLaunchDate);

  @override
  CampaignFilter maxLaunchDate(DateTime? maxLaunchDate) =>
      this(maxLaunchDate: maxLaunchDate);

  @override
  CampaignFilter minEndDate(DateTime? minEndDate) =>
      this(minEndDate: minEndDate);

  @override
  CampaignFilter maxEndDate(DateTime? maxEndDate) =>
      this(maxEndDate: maxEndDate);

  @override
  CampaignFilter minSubmissionDate(DateTime? minSubmissionDate) =>
      this(minSubmissionDate: minSubmissionDate);

  @override
  CampaignFilter maxSubmissionDate(DateTime? maxSubmissionDate) =>
      this(maxSubmissionDate: maxSubmissionDate);

  @override
  CampaignFilter minVerificationDate(DateTime? minVerificationDate) =>
      this(minVerificationDate: minVerificationDate);

  @override
  CampaignFilter maxVerificationDate(DateTime? maxVerificationDate) =>
      this(maxVerificationDate: maxVerificationDate);

  @override
  CampaignFilter minDenialDate(DateTime? minDenialDate) =>
      this(minDenialDate: minDenialDate);

  @override
  CampaignFilter maxDenialDate(DateTime? maxDenialDate) =>
      this(maxDenialDate: maxDenialDate);

  @override
  CampaignFilter ownerRecipientId(String? ownerRecipientId) =>
      this(ownerRecipientId: ownerRecipientId);

  @override
  CampaignFilter isPublic(bool? isPublic) => this(isPublic: isPublic);

  @override
  CampaignFilter page(int page) => this(page: page);

  @override
  CampaignFilter limit(int limit) => this(limit: limit);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CampaignFilter(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CampaignFilter(...).copyWith(id: 12, name: "My name")
  /// ````
  CampaignFilter call({
    Object? title = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
    Object? category = const $CopyWithPlaceholder(),
    Object? minLaunchDate = const $CopyWithPlaceholder(),
    Object? maxLaunchDate = const $CopyWithPlaceholder(),
    Object? minEndDate = const $CopyWithPlaceholder(),
    Object? maxEndDate = const $CopyWithPlaceholder(),
    Object? minSubmissionDate = const $CopyWithPlaceholder(),
    Object? maxSubmissionDate = const $CopyWithPlaceholder(),
    Object? minVerificationDate = const $CopyWithPlaceholder(),
    Object? maxVerificationDate = const $CopyWithPlaceholder(),
    Object? minDenialDate = const $CopyWithPlaceholder(),
    Object? maxDenialDate = const $CopyWithPlaceholder(),
    Object? ownerRecipientId = const $CopyWithPlaceholder(),
    Object? isPublic = const $CopyWithPlaceholder(),
    Object? page = const $CopyWithPlaceholder(),
    Object? limit = const $CopyWithPlaceholder(),
  }) {
    return CampaignFilter(
      title: title == const $CopyWithPlaceholder()
          ? _value.title
          // ignore: cast_nullable_to_non_nullable
          : title as String?,
      status: status == const $CopyWithPlaceholder()
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as CampaignStatus?,
      category: category == const $CopyWithPlaceholder()
          ? _value.category
          // ignore: cast_nullable_to_non_nullable
          : category as String?,
      minLaunchDate: minLaunchDate == const $CopyWithPlaceholder()
          ? _value.minLaunchDate
          // ignore: cast_nullable_to_non_nullable
          : minLaunchDate as DateTime?,
      maxLaunchDate: maxLaunchDate == const $CopyWithPlaceholder()
          ? _value.maxLaunchDate
          // ignore: cast_nullable_to_non_nullable
          : maxLaunchDate as DateTime?,
      minEndDate: minEndDate == const $CopyWithPlaceholder()
          ? _value.minEndDate
          // ignore: cast_nullable_to_non_nullable
          : minEndDate as DateTime?,
      maxEndDate: maxEndDate == const $CopyWithPlaceholder()
          ? _value.maxEndDate
          // ignore: cast_nullable_to_non_nullable
          : maxEndDate as DateTime?,
      minSubmissionDate: minSubmissionDate == const $CopyWithPlaceholder()
          ? _value.minSubmissionDate
          // ignore: cast_nullable_to_non_nullable
          : minSubmissionDate as DateTime?,
      maxSubmissionDate: maxSubmissionDate == const $CopyWithPlaceholder()
          ? _value.maxSubmissionDate
          // ignore: cast_nullable_to_non_nullable
          : maxSubmissionDate as DateTime?,
      minVerificationDate: minVerificationDate == const $CopyWithPlaceholder()
          ? _value.minVerificationDate
          // ignore: cast_nullable_to_non_nullable
          : minVerificationDate as DateTime?,
      maxVerificationDate: maxVerificationDate == const $CopyWithPlaceholder()
          ? _value.maxVerificationDate
          // ignore: cast_nullable_to_non_nullable
          : maxVerificationDate as DateTime?,
      minDenialDate: minDenialDate == const $CopyWithPlaceholder()
          ? _value.minDenialDate
          // ignore: cast_nullable_to_non_nullable
          : minDenialDate as DateTime?,
      maxDenialDate: maxDenialDate == const $CopyWithPlaceholder()
          ? _value.maxDenialDate
          // ignore: cast_nullable_to_non_nullable
          : maxDenialDate as DateTime?,
      ownerRecipientId: ownerRecipientId == const $CopyWithPlaceholder()
          ? _value.ownerRecipientId
          // ignore: cast_nullable_to_non_nullable
          : ownerRecipientId as String?,
      isPublic: isPublic == const $CopyWithPlaceholder()
          ? _value.isPublic
          // ignore: cast_nullable_to_non_nullable
          : isPublic as bool?,
      page: page == const $CopyWithPlaceholder()
          ? _value.page
          // ignore: cast_nullable_to_non_nullable
          : page as int,
      limit: limit == const $CopyWithPlaceholder()
          ? _value.limit
          // ignore: cast_nullable_to_non_nullable
          : limit as int,
    );
  }
}

extension $CampaignFilterCopyWith on CampaignFilter {
  /// Returns a callable class that can be used as follows: `instanceOfCampaignFilter.copyWith(...)` or like so:`instanceOfCampaignFilter.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CampaignFilterCWProxy get copyWith => _$CampaignFilterCWProxyImpl(this);
}

abstract class _$NotificationFilterCWProxy {
  NotificationFilter isRead(bool? isRead);

  NotificationFilter minCreatedAt(DateTime? minCreatedAt);

  NotificationFilter maxCreatedAt(DateTime? maxCreatedAt);

  NotificationFilter page(int page);

  NotificationFilter limit(int limit);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `NotificationFilter(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// NotificationFilter(...).copyWith(id: 12, name: "My name")
  /// ````
  NotificationFilter call({
    bool? isRead,
    DateTime? minCreatedAt,
    DateTime? maxCreatedAt,
    int page,
    int limit,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfNotificationFilter.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfNotificationFilter.copyWith.fieldName(...)`
class _$NotificationFilterCWProxyImpl implements _$NotificationFilterCWProxy {
  const _$NotificationFilterCWProxyImpl(this._value);

  final NotificationFilter _value;

  @override
  NotificationFilter isRead(bool? isRead) => this(isRead: isRead);

  @override
  NotificationFilter minCreatedAt(DateTime? minCreatedAt) =>
      this(minCreatedAt: minCreatedAt);

  @override
  NotificationFilter maxCreatedAt(DateTime? maxCreatedAt) =>
      this(maxCreatedAt: maxCreatedAt);

  @override
  NotificationFilter page(int page) => this(page: page);

  @override
  NotificationFilter limit(int limit) => this(limit: limit);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `NotificationFilter(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// NotificationFilter(...).copyWith(id: 12, name: "My name")
  /// ````
  NotificationFilter call({
    Object? isRead = const $CopyWithPlaceholder(),
    Object? minCreatedAt = const $CopyWithPlaceholder(),
    Object? maxCreatedAt = const $CopyWithPlaceholder(),
    Object? page = const $CopyWithPlaceholder(),
    Object? limit = const $CopyWithPlaceholder(),
  }) {
    return NotificationFilter(
      isRead: isRead == const $CopyWithPlaceholder()
          ? _value.isRead
          // ignore: cast_nullable_to_non_nullable
          : isRead as bool?,
      minCreatedAt: minCreatedAt == const $CopyWithPlaceholder()
          ? _value.minCreatedAt
          // ignore: cast_nullable_to_non_nullable
          : minCreatedAt as DateTime?,
      maxCreatedAt: maxCreatedAt == const $CopyWithPlaceholder()
          ? _value.maxCreatedAt
          // ignore: cast_nullable_to_non_nullable
          : maxCreatedAt as DateTime?,
      page: page == const $CopyWithPlaceholder()
          ? _value.page
          // ignore: cast_nullable_to_non_nullable
          : page as int,
      limit: limit == const $CopyWithPlaceholder()
          ? _value.limit
          // ignore: cast_nullable_to_non_nullable
          : limit as int,
    );
  }
}

extension $NotificationFilterCopyWith on NotificationFilter {
  /// Returns a callable class that can be used as follows: `instanceOfNotificationFilter.copyWith(...)` or like so:`instanceOfNotificationFilter.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$NotificationFilterCWProxy get copyWith =>
      _$NotificationFilterCWProxyImpl(this);
}

abstract class _$CampaignRequestFilterCWProxy {
  CampaignRequestFilter ownerRecipientId(String? ownerRecipientId);

  CampaignRequestFilter campaignId(String? campaignId);

  CampaignRequestFilter campaignRequestType(
      CampaignRequestType? campaignRequestType);

  CampaignRequestFilter isResolved(bool? isResolved);

  CampaignRequestFilter resolutionType(ResolutionType? resolutionType);

  CampaignRequestFilter minRequestDate(DateTime? minRequestDate);

  CampaignRequestFilter maxRequestDate(DateTime? maxRequestDate);

  CampaignRequestFilter minResolutionDate(DateTime? minResolutionDate);

  CampaignRequestFilter maxResolutionDate(DateTime? maxResolutionDate);

  CampaignRequestFilter title(String? title);

  CampaignRequestFilter page(int page);

  CampaignRequestFilter limit(int limit);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CampaignRequestFilter(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CampaignRequestFilter(...).copyWith(id: 12, name: "My name")
  /// ````
  CampaignRequestFilter call({
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
    int page,
    int limit,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCampaignRequestFilter.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCampaignRequestFilter.copyWith.fieldName(...)`
class _$CampaignRequestFilterCWProxyImpl
    implements _$CampaignRequestFilterCWProxy {
  const _$CampaignRequestFilterCWProxyImpl(this._value);

  final CampaignRequestFilter _value;

  @override
  CampaignRequestFilter ownerRecipientId(String? ownerRecipientId) =>
      this(ownerRecipientId: ownerRecipientId);

  @override
  CampaignRequestFilter campaignId(String? campaignId) =>
      this(campaignId: campaignId);

  @override
  CampaignRequestFilter campaignRequestType(
          CampaignRequestType? campaignRequestType) =>
      this(campaignRequestType: campaignRequestType);

  @override
  CampaignRequestFilter isResolved(bool? isResolved) =>
      this(isResolved: isResolved);

  @override
  CampaignRequestFilter resolutionType(ResolutionType? resolutionType) =>
      this(resolutionType: resolutionType);

  @override
  CampaignRequestFilter minRequestDate(DateTime? minRequestDate) =>
      this(minRequestDate: minRequestDate);

  @override
  CampaignRequestFilter maxRequestDate(DateTime? maxRequestDate) =>
      this(maxRequestDate: maxRequestDate);

  @override
  CampaignRequestFilter minResolutionDate(DateTime? minResolutionDate) =>
      this(minResolutionDate: minResolutionDate);

  @override
  CampaignRequestFilter maxResolutionDate(DateTime? maxResolutionDate) =>
      this(maxResolutionDate: maxResolutionDate);

  @override
  CampaignRequestFilter title(String? title) => this(title: title);

  @override
  CampaignRequestFilter page(int page) => this(page: page);

  @override
  CampaignRequestFilter limit(int limit) => this(limit: limit);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CampaignRequestFilter(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CampaignRequestFilter(...).copyWith(id: 12, name: "My name")
  /// ````
  CampaignRequestFilter call({
    Object? ownerRecipientId = const $CopyWithPlaceholder(),
    Object? campaignId = const $CopyWithPlaceholder(),
    Object? campaignRequestType = const $CopyWithPlaceholder(),
    Object? isResolved = const $CopyWithPlaceholder(),
    Object? resolutionType = const $CopyWithPlaceholder(),
    Object? minRequestDate = const $CopyWithPlaceholder(),
    Object? maxRequestDate = const $CopyWithPlaceholder(),
    Object? minResolutionDate = const $CopyWithPlaceholder(),
    Object? maxResolutionDate = const $CopyWithPlaceholder(),
    Object? title = const $CopyWithPlaceholder(),
    Object? page = const $CopyWithPlaceholder(),
    Object? limit = const $CopyWithPlaceholder(),
  }) {
    return CampaignRequestFilter(
      ownerRecipientId: ownerRecipientId == const $CopyWithPlaceholder()
          ? _value.ownerRecipientId
          // ignore: cast_nullable_to_non_nullable
          : ownerRecipientId as String?,
      campaignId: campaignId == const $CopyWithPlaceholder()
          ? _value.campaignId
          // ignore: cast_nullable_to_non_nullable
          : campaignId as String?,
      campaignRequestType: campaignRequestType == const $CopyWithPlaceholder()
          ? _value.campaignRequestType
          // ignore: cast_nullable_to_non_nullable
          : campaignRequestType as CampaignRequestType?,
      isResolved: isResolved == const $CopyWithPlaceholder()
          ? _value.isResolved
          // ignore: cast_nullable_to_non_nullable
          : isResolved as bool?,
      resolutionType: resolutionType == const $CopyWithPlaceholder()
          ? _value.resolutionType
          // ignore: cast_nullable_to_non_nullable
          : resolutionType as ResolutionType?,
      minRequestDate: minRequestDate == const $CopyWithPlaceholder()
          ? _value.minRequestDate
          // ignore: cast_nullable_to_non_nullable
          : minRequestDate as DateTime?,
      maxRequestDate: maxRequestDate == const $CopyWithPlaceholder()
          ? _value.maxRequestDate
          // ignore: cast_nullable_to_non_nullable
          : maxRequestDate as DateTime?,
      minResolutionDate: minResolutionDate == const $CopyWithPlaceholder()
          ? _value.minResolutionDate
          // ignore: cast_nullable_to_non_nullable
          : minResolutionDate as DateTime?,
      maxResolutionDate: maxResolutionDate == const $CopyWithPlaceholder()
          ? _value.maxResolutionDate
          // ignore: cast_nullable_to_non_nullable
          : maxResolutionDate as DateTime?,
      title: title == const $CopyWithPlaceholder()
          ? _value.title
          // ignore: cast_nullable_to_non_nullable
          : title as String?,
      page: page == const $CopyWithPlaceholder()
          ? _value.page
          // ignore: cast_nullable_to_non_nullable
          : page as int,
      limit: limit == const $CopyWithPlaceholder()
          ? _value.limit
          // ignore: cast_nullable_to_non_nullable
          : limit as int,
    );
  }
}

extension $CampaignRequestFilterCopyWith on CampaignRequestFilter {
  /// Returns a callable class that can be used as follows: `instanceOfCampaignRequestFilter.copyWith(...)` or like so:`instanceOfCampaignRequestFilter.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CampaignRequestFilterCWProxy get copyWith =>
      _$CampaignRequestFilterCWProxyImpl(this);
}
