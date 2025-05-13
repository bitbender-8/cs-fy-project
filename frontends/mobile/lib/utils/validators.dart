String? validNonEmptyString(String? value,
    {int min = 3, required int max}) {
  if (value == null || value.trim().isEmpty) {
    return 'Cannot be empty or contain only whitespace';
  }
  if (value.length < min) {
    return 'Must be at least $min characters long';
  }
  if (value.length > max) {
    return 'Must be no more than $max characters long';
  }
  return null;
}

String? validPhoneNo(String? value) {
  final regex = RegExp(r'^\+[1-9]\d{7,14}$');
  if (value == null || value.isEmpty) {
    return 'Phone number is required';
  }
  if (!regex.hasMatch(value)) {
    return 'Phone number must be in E.164 format (e.g., +1234567890, 8 to 15 digits)';
  }
  return null;
}

String? validDate(String? value, {required bool isPast}) {
  if (value == null || value.isEmpty) {
    return 'Date is required';
  }
  DateTime? date;
  try {
    date = DateTime.parse(value);
  } catch (_) {
    return 'Invalid date format';
  }
  final now = DateTime.now();
  if (isPast && !date.isBefore(now)) {
    return 'Must be in the past';
  }
  if (!isPast && date.isBefore(now)) {
    return 'Must be now or in the future';
  }
  return null;
}

String? validEmail(String? value) {
  if (value == null || value.isEmpty) {
    return 'Email is required';
  }
  final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
  if (!regex.hasMatch(value)) {
    return 'Invalid email address';
  }
  return null;
}

String? validUrl(String? value) {
  if (value == null || value.isEmpty) {
    return 'URL is required';
  }
  final regex =
      RegExp(r'^(https?|ftp):\/\/[^\s/$.?#].[^\s]*$', caseSensitive: false);
  if (!regex.hasMatch(value)) {
    return 'Invalid URL format. Please provide a valid URL.';
  }
  return null;
}

String? validUuid(String? value) {
  final regex = RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$');
  if (value == null || value.isEmpty) {
    return 'UUID is required';
  }
  if (!regex.hasMatch(value)) {
    return 'Invalid UUID';
  }
  return null;
}

String? validBoolean(String? value) {
  if (value != 'true' && value != 'false') {
    return "Must be either 'true' or 'false'.";
  }
  return null;
}

String? validMoneyAmount(String? value, double max) {
  if (value == null || value.isEmpty) {
    return 'Amount is required';
  }
  final numValue = double.tryParse(value);
  if (numValue == null || numValue < 0) {
    return 'Must be a valid non-negative number.';
  }
  if (value.contains('.')) {
    final decimals = value.split('.')[1];
    if (decimals.length > 2) {
      return 'Must have up to two decimal places.';
    }
  }
  if (numValue > max) {
    return 'Amount must be less than or equal to $max.';
  }
  return null;
}

/*

String? validEnum(String? value, List<String> allowed, String fieldName) {
  if (value == null || value.isEmpty) {
    return '$fieldName is required';
  }
  if (!allowed.contains(value)) {
    return 'Invalid $fieldName. Must be one of: ${allowed.join(", ")}.';
  }
  return null;
}

String? validBankAccountNo(String? value) {
  final regex = RegExp(r'^\d{10,16}$');
  if (value == null || value.isEmpty) {
    return 'Bank account number is required';
  }
  if (!regex.hasMatch(value)) {
    return 'Bank account number must be numeric and 10-16 digits long';
  }
  return null;
}

*/
