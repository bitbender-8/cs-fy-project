final class AppConfig {
  AppConfig._();

  static const int pageSize = 10;
  static const double maxMoneyAmount = 100000;
  static const int maxFileNo = 5;
  static const int maxFileSizeMb = 5;
  static const List<String> allowedFileExtensions = [
    "jpg",
    "jpeg",
    "png",
    "gif",
    "pdf",
    "doc",
    "docx"
  ];
  static const String auth0Domain = 'dev-tesfafund.us.auth0.com';
  static const String auth0ClientId = 'XLxuKulvsmo4L6vdpd7waBRupIYT5hvb';
  static const String auth0Audience = 'tesfafund-api';
  static const String auth0RedirectScheme = 'com.example.mobile';
  static const String auth0Namespace = 'https://tesfafund-api.example.com';
  static const String apiUrl = 'http://192.168.202.120:4000';
  static const String chapaPublicKey =
      'CHAPUBK_TEST-HjDea8nO0dEKVZxDMojOEOjp4OrfWfRC';
  static const String currency = "ETB";
}
