import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:flutter/material.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:mobile/config.dart';
import 'package:mobile/models/notification.dart';
import 'package:mobile/models/recipient.dart';

class UserProvider extends ChangeNotifier {
  Recipient? _recipient;
  Credentials? _credentials;
  bool _isLoading = false;
  String? _error;

  final Auth0 _auth0 = Auth0(auth0Domain, auth0ClientId);

  Recipient? get user => _recipient;
  Credentials? get credentials => _credentials;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void setRecipient(Recipient? recipient) {
    _recipient = recipient;
    notifyListeners();
  }

  void setCredentials(Credentials? credentials) {
    _credentials = credentials;
    notifyListeners();
  }

  // Login with Auth0
  Future<void> login() async {
    _isLoading = true;
    _error = null;

    try {
      final credentials = await _auth0
          .webAuthentication(
            scheme: auth0RedirectScheme,
          )
          .login(
            useHTTPS: true,
            audience: auth0Audience,
          );

      final payload = Jwt.parseJwt(credentials.accessToken);
      final roles = payload['$auth0Namespace/roles'];
      final UserType? role = UserType.fromString(roles[0] ?? "");

      // Only allow login for recipients
      if (role == UserType.recipient) {
        _credentials = credentials;
      } else {
        _error = "Only recipients can log in.";
      }
    } catch (e) {
      _error = "$e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Logout
  void logout() {
    _credentials = null;
    _recipient = null;
    notifyListeners();
  }
}
