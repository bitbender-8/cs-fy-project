import 'package:json_annotation/json_annotation.dart';

part 'recipient.g.dart';

@JsonSerializable(explicitToJson: true)
class Recipient {
  String? id;
  String? auth0UserId;
  String? email;
  String firstName;
  String middleName;
  String lastName;
  DateTime? dateOfBirth;
  String? phoneNo;
  String bio;
  String? profilePictureUrl;
  List<SocialMediaHandle>? socialMediaHandles;

  Recipient({
    this.id,
    this.auth0UserId,
    this.email,
    required this.firstName,
    required this.middleName,
    required this.lastName,
    required this.dateOfBirth,
    required this.phoneNo,
    required this.bio,
    this.profilePictureUrl,
    this.socialMediaHandles,
  });

  String get fullName => "$firstName $middleName $lastName";

  factory Recipient.fromJson(Map<String, dynamic> json) =>
      _$RecipientFromJson(json);
  Map<String, dynamic> toJson() => _$RecipientToJson(this);

  Recipient copyWith({
    String? id,
    String? auth0UserId,
    String? email,
    String? firstName,
    String? middleName,
    String? lastName,
    DateTime? dateOfBirth,
    String? phoneNo,
    String? bio,
    String? profilePictureUrl,
    List<SocialMediaHandle>? socialMediaHandles,
  }) {
    return Recipient(
      id: id ?? this.id,
      auth0UserId: auth0UserId ?? this.auth0UserId,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      middleName: middleName ?? this.middleName,
      lastName: lastName ?? this.lastName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      phoneNo: phoneNo ?? this.phoneNo,
      bio: bio ?? this.bio,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      socialMediaHandles: socialMediaHandles ?? this.socialMediaHandles,
    );
  }
}

@JsonSerializable(explicitToJson: true)
class SocialMediaHandle {
  String? id;
  String? recipientId;
  String socialMediaHandle;

  SocialMediaHandle({
    this.id,
    this.recipientId,
    required this.socialMediaHandle,
  });

  factory SocialMediaHandle.fromJson(Map<String, dynamic> json) =>
      _$SocialMediaHandleFromJson(json);
  Map<String, dynamic> toJson() => _$SocialMediaHandleToJson(this);

  SocialMediaHandle copyWith({
    String? id,
    String? recipientId,
    String? socialMediaHandle,
  }) {
    return SocialMediaHandle(
      id: id ?? this.id,
      recipientId: recipientId ?? this.recipientId,
      socialMediaHandle: socialMediaHandle ?? this.socialMediaHandle,
    );
  }
}
