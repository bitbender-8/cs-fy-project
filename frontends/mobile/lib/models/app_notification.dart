import 'package:json_annotation/json_annotation.dart';

part 'app_notification.g.dart';

@JsonSerializable()
class AppNotification {
  String id;
  String subject;
  String body;
  bool isRead;
  DateTime createdAt;
  String userId;
  UserType userType;

  AppNotification({
    required this.id,
    required this.subject,
    required this.body,
    required this.isRead,
    required this.createdAt,
    required this.userId,
    required this.userType,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      _$AppNotificationFromJson(json);
  Map<String, dynamic> toJson() => _$AppNotificationToJson(this);
}

enum UserType {
  @JsonValue("Recipient")
  recipient,

  @JsonValue("Supervisor")
  supervisor;

  static UserType? fromString(String value) {
    switch (value) {
      case "Supervisor":
        return UserType.supervisor;
      case "Recipient":
        return UserType.recipient;
      default:
        return null;
    }
  }
}
