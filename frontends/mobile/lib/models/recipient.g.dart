// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipient.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Recipient _$RecipientFromJson(Map<String, dynamic> json) => Recipient(
      id: json['id'] as String?,
      auth0UserId: json['auth0UserId'] as String?,
      email: json['email'] as String?,
      firstName: json['firstName'] as String,
      middleName: json['middleName'] as String,
      lastName: json['lastName'] as String,
      dateOfBirth: json['dateOfBirth'] == null
          ? null
          : DateTime.parse(json['dateOfBirth'] as String),
      phoneNo: json['phoneNo'] as String?,
      bio: json['bio'] as String,
      profilePictureUrl: json['profilePictureUrl'] as String?,
      socialMediaHandles: (json['socialMediaHandles'] as List<dynamic>?)
          ?.map((e) => SocialMediaHandle.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$RecipientToJson(Recipient instance) => <String, dynamic>{
      'id': instance.id,
      'auth0UserId': instance.auth0UserId,
      'email': instance.email,
      'firstName': instance.firstName,
      'middleName': instance.middleName,
      'lastName': instance.lastName,
      'dateOfBirth': instance.dateOfBirth?.toIso8601String(),
      'phoneNo': instance.phoneNo,
      'bio': instance.bio,
      'profilePictureUrl': instance.profilePictureUrl,
      'socialMediaHandles':
          instance.socialMediaHandles?.map((e) => e.toJson()).toList(),
    };

SocialMediaHandle _$SocialMediaHandleFromJson(Map<String, dynamic> json) =>
    SocialMediaHandle(
      id: json['id'] as String?,
      recipientId: json['recipientId'] as String?,
      socialMediaHandle: json['socialMediaHandle'] as String,
    );

Map<String, dynamic> _$SocialMediaHandleToJson(SocialMediaHandle instance) =>
    <String, dynamic>{
      'id': instance.id,
      'recipientId': instance.recipientId,
      'socialMediaHandle': instance.socialMediaHandle,
    };
