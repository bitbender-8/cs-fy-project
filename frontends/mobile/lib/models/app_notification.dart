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
      _$NotificationFromJson(json);
  Map<String, dynamic> toJson() => _$NotificationToJson(this);
}

enum UserType {
  recipient("Recipient"),
  supervisor("Supervisor");

  final String value;
  const UserType(this.value);
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
