// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'campaign.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CampaignCWProxy {
  Campaign id(String? id);

  Campaign ownerRecipientId(String ownerRecipientId);

  Campaign title(String title);

  Campaign description(String description);

  Campaign fundraisingGoal(String fundraisingGoal);

  Campaign status(CampaignStatus? status);

  Campaign category(String category);

  Campaign launchDate(DateTime? launchDate);

  Campaign endDate(DateTime? endDate);

  Campaign submissionDate(DateTime? submissionDate);

  Campaign verificationDate(DateTime? verificationDate);

  Campaign denialDate(DateTime? denialDate);

  Campaign documents(List<CampaignDocument> documents);

  Campaign paymentInfo(PaymentInfo? paymentInfo);

  Campaign campaignPosts(List<CampaignPost>? campaignPosts);

  Campaign campaignOwner(Recipient? campaignOwner);

  Campaign totalDonated(String? totalDonated);

  Campaign isPublic(bool? isPublic);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Campaign(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Campaign(...).copyWith(id: 12, name: "My name")
  /// ````
  Campaign call({
    String? id,
    String ownerRecipientId,
    String title,
    String description,
    String fundraisingGoal,
    CampaignStatus? status,
    String category,
    DateTime? launchDate,
    DateTime? endDate,
    DateTime? submissionDate,
    DateTime? verificationDate,
    DateTime? denialDate,
    List<CampaignDocument> documents,
    PaymentInfo? paymentInfo,
    List<CampaignPost>? campaignPosts,
    Recipient? campaignOwner,
    String? totalDonated,
    bool? isPublic,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCampaign.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCampaign.copyWith.fieldName(...)`
class _$CampaignCWProxyImpl implements _$CampaignCWProxy {
  const _$CampaignCWProxyImpl(this._value);

  final Campaign _value;

  @override
  Campaign id(String? id) => this(id: id);

  @override
  Campaign ownerRecipientId(String ownerRecipientId) =>
      this(ownerRecipientId: ownerRecipientId);

  @override
  Campaign title(String title) => this(title: title);

  @override
  Campaign description(String description) => this(description: description);

  @override
  Campaign fundraisingGoal(String fundraisingGoal) =>
      this(fundraisingGoal: fundraisingGoal);

  @override
  Campaign status(CampaignStatus? status) => this(status: status);

  @override
  Campaign category(String category) => this(category: category);

  @override
  Campaign launchDate(DateTime? launchDate) => this(launchDate: launchDate);

  @override
  Campaign endDate(DateTime? endDate) => this(endDate: endDate);

  @override
  Campaign submissionDate(DateTime? submissionDate) =>
      this(submissionDate: submissionDate);

  @override
  Campaign verificationDate(DateTime? verificationDate) =>
      this(verificationDate: verificationDate);

  @override
  Campaign denialDate(DateTime? denialDate) => this(denialDate: denialDate);

  @override
  Campaign documents(List<CampaignDocument> documents) =>
      this(documents: documents);

  @override
  Campaign paymentInfo(PaymentInfo? paymentInfo) =>
      this(paymentInfo: paymentInfo);

  @override
  Campaign campaignPosts(List<CampaignPost>? campaignPosts) =>
      this(campaignPosts: campaignPosts);

  @override
  Campaign campaignOwner(Recipient? campaignOwner) =>
      this(campaignOwner: campaignOwner);

  @override
  Campaign totalDonated(String? totalDonated) =>
      this(totalDonated: totalDonated);

  @override
  Campaign isPublic(bool? isPublic) => this(isPublic: isPublic);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Campaign(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Campaign(...).copyWith(id: 12, name: "My name")
  /// ````
  Campaign call({
    Object? id = const $CopyWithPlaceholder(),
    Object? ownerRecipientId = const $CopyWithPlaceholder(),
    Object? title = const $CopyWithPlaceholder(),
    Object? description = const $CopyWithPlaceholder(),
    Object? fundraisingGoal = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
    Object? category = const $CopyWithPlaceholder(),
    Object? launchDate = const $CopyWithPlaceholder(),
    Object? endDate = const $CopyWithPlaceholder(),
    Object? submissionDate = const $CopyWithPlaceholder(),
    Object? verificationDate = const $CopyWithPlaceholder(),
    Object? denialDate = const $CopyWithPlaceholder(),
    Object? documents = const $CopyWithPlaceholder(),
    Object? paymentInfo = const $CopyWithPlaceholder(),
    Object? campaignPosts = const $CopyWithPlaceholder(),
    Object? campaignOwner = const $CopyWithPlaceholder(),
    Object? totalDonated = const $CopyWithPlaceholder(),
    Object? isPublic = const $CopyWithPlaceholder(),
  }) {
    return Campaign(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String?,
      ownerRecipientId: ownerRecipientId == const $CopyWithPlaceholder()
          ? _value.ownerRecipientId
          // ignore: cast_nullable_to_non_nullable
          : ownerRecipientId as String,
      title: title == const $CopyWithPlaceholder()
          ? _value.title
          // ignore: cast_nullable_to_non_nullable
          : title as String,
      description: description == const $CopyWithPlaceholder()
          ? _value.description
          // ignore: cast_nullable_to_non_nullable
          : description as String,
      fundraisingGoal: fundraisingGoal == const $CopyWithPlaceholder()
          ? _value.fundraisingGoal
          // ignore: cast_nullable_to_non_nullable
          : fundraisingGoal as String,
      status: status == const $CopyWithPlaceholder()
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as CampaignStatus?,
      category: category == const $CopyWithPlaceholder()
          ? _value.category
          // ignore: cast_nullable_to_non_nullable
          : category as String,
      launchDate: launchDate == const $CopyWithPlaceholder()
          ? _value.launchDate
          // ignore: cast_nullable_to_non_nullable
          : launchDate as DateTime?,
      endDate: endDate == const $CopyWithPlaceholder()
          ? _value.endDate
          // ignore: cast_nullable_to_non_nullable
          : endDate as DateTime?,
      submissionDate: submissionDate == const $CopyWithPlaceholder()
          ? _value.submissionDate
          // ignore: cast_nullable_to_non_nullable
          : submissionDate as DateTime?,
      verificationDate: verificationDate == const $CopyWithPlaceholder()
          ? _value.verificationDate
          // ignore: cast_nullable_to_non_nullable
          : verificationDate as DateTime?,
      denialDate: denialDate == const $CopyWithPlaceholder()
          ? _value.denialDate
          // ignore: cast_nullable_to_non_nullable
          : denialDate as DateTime?,
      documents: documents == const $CopyWithPlaceholder()
          ? _value.documents
          // ignore: cast_nullable_to_non_nullable
          : documents as List<CampaignDocument>,
      paymentInfo: paymentInfo == const $CopyWithPlaceholder()
          ? _value.paymentInfo
          // ignore: cast_nullable_to_non_nullable
          : paymentInfo as PaymentInfo?,
      campaignPosts: campaignPosts == const $CopyWithPlaceholder()
          ? _value.campaignPosts
          // ignore: cast_nullable_to_non_nullable
          : campaignPosts as List<CampaignPost>?,
      campaignOwner: campaignOwner == const $CopyWithPlaceholder()
          ? _value.campaignOwner
          // ignore: cast_nullable_to_non_nullable
          : campaignOwner as Recipient?,
      totalDonated: totalDonated == const $CopyWithPlaceholder()
          ? _value.totalDonated
          // ignore: cast_nullable_to_non_nullable
          : totalDonated as String?,
      isPublic: isPublic == const $CopyWithPlaceholder()
          ? _value.isPublic
          // ignore: cast_nullable_to_non_nullable
          : isPublic as bool?,
    );
  }
}

extension $CampaignCopyWith on Campaign {
  /// Returns a callable class that can be used as follows: `instanceOfCampaign.copyWith(...)` or like so:`instanceOfCampaign.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CampaignCWProxy get copyWith => _$CampaignCWProxyImpl(this);
}

abstract class _$CampaignDocumentCWProxy {
  CampaignDocument campaignId(String campaignId);

  CampaignDocument documentUrl(String? documentUrl);

  CampaignDocument redactedDocumentUrl(String? redactedDocumentUrl);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CampaignDocument(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CampaignDocument(...).copyWith(id: 12, name: "My name")
  /// ````
  CampaignDocument call({
    String campaignId,
    String? documentUrl,
    String? redactedDocumentUrl,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCampaignDocument.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCampaignDocument.copyWith.fieldName(...)`
class _$CampaignDocumentCWProxyImpl implements _$CampaignDocumentCWProxy {
  const _$CampaignDocumentCWProxyImpl(this._value);

  final CampaignDocument _value;

  @override
  CampaignDocument campaignId(String campaignId) =>
      this(campaignId: campaignId);

  @override
  CampaignDocument documentUrl(String? documentUrl) =>
      this(documentUrl: documentUrl);

  @override
  CampaignDocument redactedDocumentUrl(String? redactedDocumentUrl) =>
      this(redactedDocumentUrl: redactedDocumentUrl);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CampaignDocument(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CampaignDocument(...).copyWith(id: 12, name: "My name")
  /// ````
  CampaignDocument call({
    Object? campaignId = const $CopyWithPlaceholder(),
    Object? documentUrl = const $CopyWithPlaceholder(),
    Object? redactedDocumentUrl = const $CopyWithPlaceholder(),
  }) {
    return CampaignDocument(
      campaignId: campaignId == const $CopyWithPlaceholder()
          ? _value.campaignId
          // ignore: cast_nullable_to_non_nullable
          : campaignId as String,
      documentUrl: documentUrl == const $CopyWithPlaceholder()
          ? _value.documentUrl
          // ignore: cast_nullable_to_non_nullable
          : documentUrl as String?,
      redactedDocumentUrl: redactedDocumentUrl == const $CopyWithPlaceholder()
          ? _value.redactedDocumentUrl
          // ignore: cast_nullable_to_non_nullable
          : redactedDocumentUrl as String?,
    );
  }
}

extension $CampaignDocumentCopyWith on CampaignDocument {
  /// Returns a callable class that can be used as follows: `instanceOfCampaignDocument.copyWith(...)` or like so:`instanceOfCampaignDocument.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CampaignDocumentCWProxy get copyWith => _$CampaignDocumentCWProxyImpl(this);
}

abstract class _$CampaignDonationCWProxy {
  CampaignDonation id(String id);

  CampaignDonation grossAmount(String grossAmount);

  CampaignDonation serviceFee(String serviceFee);

  CampaignDonation createdAt(DateTime createdAt);

  CampaignDonation campaignId(String campaignId);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CampaignDonation(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CampaignDonation(...).copyWith(id: 12, name: "My name")
  /// ````
  CampaignDonation call({
    String id,
    String grossAmount,
    String serviceFee,
    DateTime createdAt,
    String campaignId,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCampaignDonation.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCampaignDonation.copyWith.fieldName(...)`
class _$CampaignDonationCWProxyImpl implements _$CampaignDonationCWProxy {
  const _$CampaignDonationCWProxyImpl(this._value);

  final CampaignDonation _value;

  @override
  CampaignDonation id(String id) => this(id: id);

  @override
  CampaignDonation grossAmount(String grossAmount) =>
      this(grossAmount: grossAmount);

  @override
  CampaignDonation serviceFee(String serviceFee) =>
      this(serviceFee: serviceFee);

  @override
  CampaignDonation createdAt(DateTime createdAt) => this(createdAt: createdAt);

  @override
  CampaignDonation campaignId(String campaignId) =>
      this(campaignId: campaignId);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CampaignDonation(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CampaignDonation(...).copyWith(id: 12, name: "My name")
  /// ````
  CampaignDonation call({
    Object? id = const $CopyWithPlaceholder(),
    Object? grossAmount = const $CopyWithPlaceholder(),
    Object? serviceFee = const $CopyWithPlaceholder(),
    Object? createdAt = const $CopyWithPlaceholder(),
    Object? campaignId = const $CopyWithPlaceholder(),
  }) {
    return CampaignDonation(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      grossAmount: grossAmount == const $CopyWithPlaceholder()
          ? _value.grossAmount
          // ignore: cast_nullable_to_non_nullable
          : grossAmount as String,
      serviceFee: serviceFee == const $CopyWithPlaceholder()
          ? _value.serviceFee
          // ignore: cast_nullable_to_non_nullable
          : serviceFee as String,
      createdAt: createdAt == const $CopyWithPlaceholder()
          ? _value.createdAt
          // ignore: cast_nullable_to_non_nullable
          : createdAt as DateTime,
      campaignId: campaignId == const $CopyWithPlaceholder()
          ? _value.campaignId
          // ignore: cast_nullable_to_non_nullable
          : campaignId as String,
    );
  }
}

extension $CampaignDonationCopyWith on CampaignDonation {
  /// Returns a callable class that can be used as follows: `instanceOfCampaignDonation.copyWith(...)` or like so:`instanceOfCampaignDonation.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CampaignDonationCWProxy get copyWith => _$CampaignDonationCWProxyImpl(this);
}

abstract class _$CampaignPostCWProxy {
  CampaignPost id(String? id);

  CampaignPost campaignId(String campaignId);

  CampaignPost title(String title);

  CampaignPost content(String content);

  CampaignPost publicPostDate(DateTime? publicPostDate);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CampaignPost(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CampaignPost(...).copyWith(id: 12, name: "My name")
  /// ````
  CampaignPost call({
    String? id,
    String campaignId,
    String title,
    String content,
    DateTime? publicPostDate,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCampaignPost.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCampaignPost.copyWith.fieldName(...)`
class _$CampaignPostCWProxyImpl implements _$CampaignPostCWProxy {
  const _$CampaignPostCWProxyImpl(this._value);

  final CampaignPost _value;

  @override
  CampaignPost id(String? id) => this(id: id);

  @override
  CampaignPost campaignId(String campaignId) => this(campaignId: campaignId);

  @override
  CampaignPost title(String title) => this(title: title);

  @override
  CampaignPost content(String content) => this(content: content);

  @override
  CampaignPost publicPostDate(DateTime? publicPostDate) =>
      this(publicPostDate: publicPostDate);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CampaignPost(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CampaignPost(...).copyWith(id: 12, name: "My name")
  /// ````
  CampaignPost call({
    Object? id = const $CopyWithPlaceholder(),
    Object? campaignId = const $CopyWithPlaceholder(),
    Object? title = const $CopyWithPlaceholder(),
    Object? content = const $CopyWithPlaceholder(),
    Object? publicPostDate = const $CopyWithPlaceholder(),
  }) {
    return CampaignPost(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String?,
      campaignId: campaignId == const $CopyWithPlaceholder()
          ? _value.campaignId
          // ignore: cast_nullable_to_non_nullable
          : campaignId as String,
      title: title == const $CopyWithPlaceholder()
          ? _value.title
          // ignore: cast_nullable_to_non_nullable
          : title as String,
      content: content == const $CopyWithPlaceholder()
          ? _value.content
          // ignore: cast_nullable_to_non_nullable
          : content as String,
      publicPostDate: publicPostDate == const $CopyWithPlaceholder()
          ? _value.publicPostDate
          // ignore: cast_nullable_to_non_nullable
          : publicPostDate as DateTime?,
    );
  }
}

extension $CampaignPostCopyWith on CampaignPost {
  /// Returns a callable class that can be used as follows: `instanceOfCampaignPost.copyWith(...)` or like so:`instanceOfCampaignPost.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CampaignPostCWProxy get copyWith => _$CampaignPostCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Campaign _$CampaignFromJson(Map<String, dynamic> json) => Campaign(
      id: json['id'] as String?,
      ownerRecipientId: json['ownerRecipientId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      fundraisingGoal: json['fundraisingGoal'] as String,
      status: $enumDecodeNullable(_$CampaignStatusEnumMap, json['status']),
      category: json['category'] as String,
      launchDate: json['launchDate'] == null
          ? null
          : DateTime.parse(json['launchDate'] as String),
      endDate: json['endDate'] == null
          ? null
          : DateTime.parse(json['endDate'] as String),
      submissionDate: json['submissionDate'] == null
          ? null
          : DateTime.parse(json['submissionDate'] as String),
      verificationDate: json['verificationDate'] == null
          ? null
          : DateTime.parse(json['verificationDate'] as String),
      denialDate: json['denialDate'] == null
          ? null
          : DateTime.parse(json['denialDate'] as String),
      documents: (json['documents'] as List<dynamic>?)
              ?.map((e) => CampaignDocument.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      paymentInfo: json['paymentInfo'] == null
          ? null
          : PaymentInfo.fromJson(json['paymentInfo'] as Map<String, dynamic>),
      totalDonated: json['totalDonated'] as String?,
      isPublic: json['isPublic'] as bool?,
    );

Map<String, dynamic> _$CampaignToJson(Campaign instance) => <String, dynamic>{
      'id': instance.id,
      'ownerRecipientId': instance.ownerRecipientId,
      'title': instance.title,
      'description': instance.description,
      'fundraisingGoal': instance.fundraisingGoal,
      'status': _$CampaignStatusEnumMap[instance.status],
      'category': instance.category,
      'launchDate': instance.launchDate?.toIso8601String(),
      'endDate': instance.endDate?.toIso8601String(),
      'submissionDate': instance.submissionDate?.toIso8601String(),
      'verificationDate': instance.verificationDate?.toIso8601String(),
      'denialDate': instance.denialDate?.toIso8601String(),
      'documents': instance.documents.map((e) => e.toJson()).toList(),
      'paymentInfo': instance.paymentInfo?.toJson(),
      'totalDonated': instance.totalDonated,
    };

const _$CampaignStatusEnumMap = {
  CampaignStatus.pendingReview: 'Pending Review',
  CampaignStatus.verified: 'Verified',
  CampaignStatus.denied: 'Denied',
  CampaignStatus.live: 'Live',
  CampaignStatus.paused: 'Paused',
  CampaignStatus.completed: 'Completed',
};

CampaignDocument _$CampaignDocumentFromJson(Map<String, dynamic> json) =>
    CampaignDocument(
      campaignId: json['campaignId'] as String,
      documentUrl: json['documentUrl'] as String?,
      redactedDocumentUrl: json['redactedDocumentUrl'] as String?,
    );

Map<String, dynamic> _$CampaignDocumentToJson(CampaignDocument instance) =>
    <String, dynamic>{
      'campaignId': instance.campaignId,
      'documentUrl': instance.documentUrl,
      'redactedDocumentUrl': instance.redactedDocumentUrl,
    };

CampaignDonation _$CampaignDonationFromJson(Map<String, dynamic> json) =>
    CampaignDonation(
      id: json['id'] as String,
      grossAmount: json['grossAmount'] as String,
      serviceFee: json['serviceFee'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      campaignId: json['campaignId'] as String,
    );

Map<String, dynamic> _$CampaignDonationToJson(CampaignDonation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'grossAmount': instance.grossAmount,
      'serviceFee': instance.serviceFee,
      'createdAt': instance.createdAt.toIso8601String(),
      'campaignId': instance.campaignId,
    };

CampaignPost _$CampaignPostFromJson(Map<String, dynamic> json) => CampaignPost(
      id: json['id'] as String?,
      campaignId: json['campaignId'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      publicPostDate: json['publicPostDate'] == null
          ? null
          : DateTime.parse(json['publicPostDate'] as String),
    );

Map<String, dynamic> _$CampaignPostToJson(CampaignPost instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'content': instance.content,
      'publicPostDate': instance.publicPostDate?.toIso8601String(),
      'campaignId': instance.campaignId,
    };
