class RecipientFilters {
  String? auth0UserId;
  String? name;
  String? email;
  int? page;
  int? limit;

  DateTime? minBirthDate;
  DateTime? maxBirthDate;
  String? phoneNo;

  RecipientFilters({
    this.auth0UserId,
    this.name,
    this.email,
    this.page,
    this.limit,
    this.minBirthDate,
    this.maxBirthDate,
    this.phoneNo,
  });

  Map<String, dynamic>? toMap() {
    final map = <String, dynamic>{};
    if (auth0UserId != null) map['auth0UserId'] = auth0UserId;
    if (name != null) map['name'] = name;
    if (email != null) map['email'] = email;
    if (page != null) map['page'] = page;
    if (limit != null) map['limit'] = limit;

    map['minBirthDate'] = minBirthDate?.toIso8601String();
    map['maxBirthDate'] = maxBirthDate?.toIso8601String();
    if (phoneNo != null) map['phoneNo'] = phoneNo;

    map.removeWhere((key, value) => value == null);
    return map.isEmpty ? null : map;
  }
}
