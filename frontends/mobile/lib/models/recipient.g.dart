// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipient.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$RecipientCWProxy {
  Recipient id(String? id);

  Recipient auth0UserId(String? auth0UserId);

  Recipient email(String? email);

  Recipient firstName(String firstName);

  Recipient middleName(String middleName);

  Recipient lastName(String lastName);

  Recipient dateOfBirth(DateTime? dateOfBirth);

  Recipient phoneNo(String? phoneNo);

  Recipient bio(String bio);

  Recipient profilePictureUrl(String? profilePictureUrl);

  Recipient socialMediaHandles(List<SocialMediaHandle>? socialMediaHandles);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Recipient(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Recipient(...).copyWith(id: 12, name: "My name")
  /// ````
  Recipient call({
    String? id,
    String? auth0UserId,
    String? email,
    String firstName,
    String middleName,
    String lastName,
    DateTime? dateOfBirth,
    String? phoneNo,
    String bio,
    String? profilePictureUrl,
    List<SocialMediaHandle>? socialMediaHandles,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfRecipient.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfRecipient.copyWith.fieldName(...)`
class _$RecipientCWProxyImpl implements _$RecipientCWProxy {
  const _$RecipientCWProxyImpl(this._value);

  final Recipient _value;

  @override
  Recipient id(String? id) => this(id: id);

  @override
  Recipient auth0UserId(String? auth0UserId) => this(auth0UserId: auth0UserId);

  @override
  Recipient email(String? email) => this(email: email);

  @override
  Recipient firstName(String firstName) => this(firstName: firstName);

  @override
  Recipient middleName(String middleName) => this(middleName: middleName);

  @override
  Recipient lastName(String lastName) => this(lastName: lastName);

  @override
  Recipient dateOfBirth(DateTime? dateOfBirth) =>
      this(dateOfBirth: dateOfBirth);

  @override
  Recipient phoneNo(String? phoneNo) => this(phoneNo: phoneNo);

  @override
  Recipient bio(String bio) => this(bio: bio);

  @override
  Recipient profilePictureUrl(String? profilePictureUrl) =>
      this(profilePictureUrl: profilePictureUrl);

  @override
  Recipient socialMediaHandles(List<SocialMediaHandle>? socialMediaHandles) =>
      this(socialMediaHandles: socialMediaHandles);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Recipient(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Recipient(...).copyWith(id: 12, name: "My name")
  /// ````
  Recipient call({
    Object? id = const $CopyWithPlaceholder(),
    Object? auth0UserId = const $CopyWithPlaceholder(),
    Object? email = const $CopyWithPlaceholder(),
    Object? firstName = const $CopyWithPlaceholder(),
    Object? middleName = const $CopyWithPlaceholder(),
    Object? lastName = const $CopyWithPlaceholder(),
    Object? dateOfBirth = const $CopyWithPlaceholder(),
    Object? phoneNo = const $CopyWithPlaceholder(),
    Object? bio = const $CopyWithPlaceholder(),
    Object? profilePictureUrl = const $CopyWithPlaceholder(),
    Object? socialMediaHandles = const $CopyWithPlaceholder(),
  }) {
    return Recipient(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String?,
      auth0UserId: auth0UserId == const $CopyWithPlaceholder()
          ? _value.auth0UserId
          // ignore: cast_nullable_to_non_nullable
          : auth0UserId as String?,
      email: email == const $CopyWithPlaceholder()
          ? _value.email
          // ignore: cast_nullable_to_non_nullable
          : email as String?,
      firstName: firstName == const $CopyWithPlaceholder()
          ? _value.firstName
          // ignore: cast_nullable_to_non_nullable
          : firstName as String,
      middleName: middleName == const $CopyWithPlaceholder()
          ? _value.middleName
          // ignore: cast_nullable_to_non_nullable
          : middleName as String,
      lastName: lastName == const $CopyWithPlaceholder()
          ? _value.lastName
          // ignore: cast_nullable_to_non_nullable
          : lastName as String,
      dateOfBirth: dateOfBirth == const $CopyWithPlaceholder()
          ? _value.dateOfBirth
          // ignore: cast_nullable_to_non_nullable
          : dateOfBirth as DateTime?,
      phoneNo: phoneNo == const $CopyWithPlaceholder()
          ? _value.phoneNo
          // ignore: cast_nullable_to_non_nullable
          : phoneNo as String?,
      bio: bio == const $CopyWithPlaceholder()
          ? _value.bio
          // ignore: cast_nullable_to_non_nullable
          : bio as String,
      profilePictureUrl: profilePictureUrl == const $CopyWithPlaceholder()
          ? _value.profilePictureUrl
          // ignore: cast_nullable_to_non_nullable
          : profilePictureUrl as String?,
      socialMediaHandles: socialMediaHandles == const $CopyWithPlaceholder()
          ? _value.socialMediaHandles
          // ignore: cast_nullable_to_non_nullable
          : socialMediaHandles as List<SocialMediaHandle>?,
    );
  }
}

extension $RecipientCopyWith on Recipient {
  /// Returns a callable class that can be used as follows: `instanceOfRecipient.copyWith(...)` or like so:`instanceOfRecipient.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$RecipientCWProxy get copyWith => _$RecipientCWProxyImpl(this);
}

abstract class _$SocialMediaHandleCWProxy {
  SocialMediaHandle id(String? id);

  SocialMediaHandle recipientId(String? recipientId);

  SocialMediaHandle socialMediaHandle(String socialMediaHandle);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SocialMediaHandle(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SocialMediaHandle(...).copyWith(id: 12, name: "My name")
  /// ````
  SocialMediaHandle call({
    String? id,
    String? recipientId,
    String socialMediaHandle,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSocialMediaHandle.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSocialMediaHandle.copyWith.fieldName(...)`
class _$SocialMediaHandleCWProxyImpl implements _$SocialMediaHandleCWProxy {
  const _$SocialMediaHandleCWProxyImpl(this._value);

  final SocialMediaHandle _value;

  @override
  SocialMediaHandle id(String? id) => this(id: id);

  @override
  SocialMediaHandle recipientId(String? recipientId) =>
      this(recipientId: recipientId);

  @override
  SocialMediaHandle socialMediaHandle(String socialMediaHandle) =>
      this(socialMediaHandle: socialMediaHandle);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SocialMediaHandle(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SocialMediaHandle(...).copyWith(id: 12, name: "My name")
  /// ````
  SocialMediaHandle call({
    Object? id = const $CopyWithPlaceholder(),
    Object? recipientId = const $CopyWithPlaceholder(),
    Object? socialMediaHandle = const $CopyWithPlaceholder(),
  }) {
    return SocialMediaHandle(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String?,
      recipientId: recipientId == const $CopyWithPlaceholder()
          ? _value.recipientId
          // ignore: cast_nullable_to_non_nullable
          : recipientId as String?,
      socialMediaHandle: socialMediaHandle == const $CopyWithPlaceholder()
          ? _value.socialMediaHandle
          // ignore: cast_nullable_to_non_nullable
          : socialMediaHandle as String,
    );
  }
}

extension $SocialMediaHandleCopyWith on SocialMediaHandle {
  /// Returns a callable class that can be used as follows: `instanceOfSocialMediaHandle.copyWith(...)` or like so:`instanceOfSocialMediaHandle.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SocialMediaHandleCWProxy get copyWith =>
      _$SocialMediaHandleCWProxyImpl(this);
}

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
      'socialMediaHandles':
          instance.socialMediaHandles?.map((e) => e.toJson()).toList(),
      'profilePictureUrl': instance.profilePictureUrl,
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
