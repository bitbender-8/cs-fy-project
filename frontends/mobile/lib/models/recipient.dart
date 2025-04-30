class Recipient {
  String? id;
  String? auth0UserId;
  String firstName;
  String middleName;
  String lastName;
  DateTime dateOfBirth;
  String phoneNo;
  String email;
  String bio;
  String? profilePictureUrl;
  List<SocialMediaHandle>? socialMediaHandles;

  Recipient({
    this.id,
    this.auth0UserId,
    required this.firstName,
    required this.middleName,
    required this.lastName,
    required this.dateOfBirth,
    required this.phoneNo,
    required this.email,
    required this.bio,
    this.profilePictureUrl,
    this.socialMediaHandles,
  });
}

class SocialMediaHandle {
  String? id;
  String? recipientId;
  String socialMediaHandle;

  SocialMediaHandle({
    required this.id,
    required this.recipientId,
    required this.socialMediaHandle,
  });
}
