import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:flutter/material.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:mobile/config.dart';
import 'package:mobile/models/notification.dart';
import 'package:mobile/models/recipient.dart';

class UserProvider extends ChangeNotifier {
  Recipient? _recipient = Recipient(
      firstName: 'Eileen',
      middleName: 'Arden',
      lastName: 'Ondricka',
      dateOfBirth: DateTime.parse('2002-10-26'),
      phoneNo: '+18408703513',
      bio: 'Vilis conqueror delectatio tenax libero vaco anser.',
      profilePictureUrl:
          'https://cdn.jsdelivr.net/gh/faker-js/assets-person-portrait/male/512/93.jpg');

  Credentials? _credentials = Credentials(
      idToken:
          "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImV6MXBFRU9pcThra3dDVlJ3cnUyUCJ9.eyJodHRwczovL3Rlc2ZhZnVuZC1hcGkuZXhhbXBsZS5jb20vcm9sZXMiOlsiUmVjaXBpZW50Il0sImlzcyI6Imh0dHBzOi8vZGV2LWJkcnc1M2RxNzM2dXg1am4udXMuYXV0aDAuY29tLyIsInN1YiI6ImF1dGgwfDY3ZmY1OGRlMzQ3ODJkYTgxODliNDUxNyIsImF1ZCI6WyJ0ZXNmYWZ1bmQtYXBpIiwiaHR0cHM6Ly9kZXYtYmRydzUzZHE3MzZ1eDVqbi51cy5hdXRoMC5jb20vdXNlcmluZm8iXSwiaWF0IjoxNzQ4NjkyMTI2LCJleHAiOjE3NDg3Nzg1MjYsInNjb3BlIjoib3BlbmlkIGVtYWlsIiwiYXpwIjoib2NCSlFQTG5samExaWNQTVE0T3V6QUpWeEgxaU5jTnAiLCJwZXJtaXNzaW9ucyI6W119.G-DX2CSdUqEWNT4l9hJXbFLhM4XcGjIba0RplBIVMcoYqTGf_J8FAqFhtCBWNOgfFJPjAvMcePAEFmVsiw2WsqQ7ntxxxsv9z9NFMMlhmHL0baBpfyeInwaQr6dr-Va83gwmSGGrkYHPRNCaSMiqA1Qhc6UAfJDRMUEfDUC1cmxoi7i77KgkUWsx8rZv2zsMzs-UrODnUO1Z9TZea87RYt8HIqH2sc0c8vS0BJWGAPgKJP_GhTJawq0oQu_V23jbDaTeDMjHkQjaVSIFrBff1LbmoUBv2hM6G4UrSzR2k0abHFD3Em9nQttCKkpNAGutwYJiKXRf7bmhc3nck0r73Q",
      accessToken:
          "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImV6MXBFRU9pcThra3dDVlJ3cnUyUCJ9.eyJodHRwczovL3Rlc2ZhZnVuZC1hcGkuZXhhbXBsZS5jb20vcm9sZXMiOlsiUmVjaXBpZW50Il0sImlzcyI6Imh0dHBzOi8vZGV2LWJkcnc1M2RxNzM2dXg1am4udXMuYXV0aDAuY29tLyIsInN1YiI6ImF1dGgwfDY3ZmY1OGRlMzQ3ODJkYTgxODliNDUxNyIsImF1ZCI6WyJ0ZXNmYWZ1bmQtYXBpIiwiaHR0cHM6Ly9kZXYtYmRydzUzZHE3MzZ1eDVqbi51cy5hdXRoMC5jb20vdXNlcmluZm8iXSwiaWF0IjoxNzQ4NjkyMTI2LCJleHAiOjE3NDg3Nzg1MjYsInNjb3BlIjoib3BlbmlkIGVtYWlsIiwiYXpwIjoib2NCSlFQTG5samExaWNQTVE0T3V6QUpWeEgxaU5jTnAiLCJwZXJtaXNzaW9ucyI6W119.G-DX2CSdUqEWNT4l9hJXbFLhM4XcGjIba0RplBIVMcoYqTGf_J8FAqFhtCBWNOgfFJPjAvMcePAEFmVsiw2WsqQ7ntxxxsv9z9NFMMlhmHL0baBpfyeInwaQr6dr-Va83gwmSGGrkYHPRNCaSMiqA1Qhc6UAfJDRMUEfDUC1cmxoi7i77KgkUWsx8rZv2zsMzs-UrODnUO1Z9TZea87RYt8HIqH2sc0c8vS0BJWGAPgKJP_GhTJawq0oQu_V23jbDaTeDMjHkQjaVSIFrBff1LbmoUBv2hM6G4UrSzR2k0abHFD3Em9nQttCKkpNAGutwYJiKXRf7bmhc3nck0r73Q",
      expiresAt: DateTime.fromMillisecondsSinceEpoch(1748165463000),
      user: const UserProfile(
        email: 'test1@example.com',
        sub: 'auth0|67ff58de34782da8189b4517',
      ),
      tokenType: 'Bearer');
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
