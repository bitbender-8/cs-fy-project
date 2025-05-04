class Notification {
  String id;
  String subject;
  String body;
  bool isRead;
  DateTime createdAt;
  String userId;
  UserType userType;

  Notification({
    required this.id,
    required this.subject,
    required this.body,
    required this.isRead,
    required this.createdAt,
    required this.userId,
    required this.userType,
  });
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
