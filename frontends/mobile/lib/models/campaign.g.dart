// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'campaign.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Campaign _$CampaignFromJson(Map<String, dynamic> json) => Campaign(
      id: json['id'] as String?,
      ownerRecipientId: json['ownerRecipientId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      fundraisingGoal: json['fundraisingGoal'] as String,
      status: _$JsonConverterFromJson<String, CampaignStatus>(
          json['status'], const CampaignStatusConverter().fromJson),
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
      'status': _$JsonConverterToJson<String, CampaignStatus>(
          instance.status, const CampaignStatusConverter().toJson),
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

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) =>
    json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) =>
    value == null ? null : toJson(value);

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
      title: json['title'] as String,
      content: json['content'] as String,
      publicPostDate: json['publicPostDate'] == null
          ? null
          : DateTime.parse(json['publicPostDate'] as String),
      campaignId: json['campaignId'] as String,
    );

Map<String, dynamic> _$CampaignPostToJson(CampaignPost instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'content': instance.content,
      'publicPostDate': instance.publicPostDate?.toIso8601String(),
      'campaignId': instance.campaignId,
    };
