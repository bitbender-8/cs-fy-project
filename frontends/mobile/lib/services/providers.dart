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
  String? _errorMsg;

  final Auth0 _auth0 = Auth0(auth0Domain, auth0ClientId);

  Recipient? get user => _recipient;
  Credentials? get credentials => _credentials;
  String? get errorMsg => _errorMsg;
  bool get isLoading => _isLoading;

  void setRecipient(Recipient? recipient) {
    _recipient = recipient;
    notifyListeners();
  }

  void setCredentials(Credentials? credentials) {
    _credentials = credentials;
    notifyListeners();
  }

  Future<void> login() async {
    _isLoading = true;

    try {
      final credentials =
          await _auth0.webAuthentication(scheme: auth0RedirectScheme).login(
        useHTTPS: true,
        audience: auth0Audience,
        parameters: const {},
      );
      final role = _getUserRole(credentials.accessToken);

      if (role != UserType.recipient) {
        _errorMsg = "You must be a 'Recipient' to login.";
      } else {
        _credentials = credentials;
      }
    } on WebAuthenticationException catch (e) {
      _errorMsg = "${e.details}";
      debugPrint("[AUTH0_ERROR]: $e");
    } catch (e) {
      debugPrint("[UNEXPECTED_AUTH0_ERROR]: $e");
    } finally {
      _isLoading = false;
    }
  }

  Future<void> signup() async {
    _isLoading = true;

    try {
      _credentials =
          await _auth0.webAuthentication(scheme: auth0RedirectScheme).login(
        useHTTPS: true,
        audience: auth0Audience,
        parameters: {'screen_hint': 'signup'},
      );
    } on WebAuthenticationException catch (e) {
      _errorMsg = "${e.details}";
      debugPrint("[AUTH0_ERROR]: $e");
    } catch (e) {
      debugPrint("[UNEXPECTED_AUTH0_ERROR]: $e");
    } finally {
      _isLoading = false;
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    await _auth0.webAuthentication().logout(useHTTPS: true);

    _credentials = null;
    _recipient = null;
    _errorMsg = null;

    _isLoading = false;
    notifyListeners();
  }

  void notifyUserListeners() => notifyListeners();

  static void debugPrintUserProviderState(UserProvider userProvider) {
    debugPrint(
      "[PROVIDER_STATE]: \n\tRecipient: ${userProvider.user?.toJson()}; \n\tCredentials: ${userProvider.credentials?.toMap()}",
    );
  }

  // Private methods
  UserType? _getUserRole(String accessToken) {
    Map<String, dynamic> payload = Jwt.parseJwt(accessToken);
    final roles = payload['$auth0Namespace/roles'];

    return (roles is List) ? UserType.fromString(roles.firstOrNull) : null;
  }
}
