import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mobile/config.dart';

part 'recipient.g.dart';

@CopyWith()
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
  @JsonKey(name: 'profilePictureUrl')
  String? _profilePictureUrl;
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
    String? profilePictureUrl,
    this.socialMediaHandles,
  }) : _profilePictureUrl = profilePictureUrl;

  String get fullName => "$firstName $middleName $lastName";
  String? get profilePictureUrl {
    if (_profilePictureUrl == null) return null;

    // Use your base API URL if the stored URL is relative.
    if (_profilePictureUrl!.startsWith('http')) {
      return _profilePictureUrl!;
    } else {
      return "${AppConfig.apiUrl}/files/public/$_profilePictureUrl";
    }
  }

  set profilePictureUrl(String? value) => _profilePictureUrl = value;

  factory Recipient.fromJson(Map<String, dynamic> json) =>
      _$RecipientFromJson(json);
  Map<String, dynamic> toJson() => _$RecipientToJson(this);
}

@CopyWith()
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
}
