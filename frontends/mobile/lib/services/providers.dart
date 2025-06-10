import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:flutter/material.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:mobile/config.dart';
import 'package:mobile/models/app_notification.dart';
import 'package:mobile/models/recipient.dart';
import 'package:mobile/models/server/errors.dart';
import 'package:mobile/models/server/filters.dart';
import 'package:mobile/services/notification_service.dart';

class UserProvider extends ChangeNotifier {
  Recipient? _recipient;
  Credentials? _credentials;
  bool _isLoading = false;
  String? _errorMsg;

  final Auth0 _auth0 = Auth0(AppConfig.auth0Domain, AppConfig.auth0ClientId);

  Recipient? get user => _recipient;
  Credentials? get credentials => _credentials;
  String? get errorMsg => _errorMsg;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => credentials != null;

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
      final credentials = await _auth0
          .webAuthentication(scheme: AppConfig.auth0RedirectScheme)
          .login(
        useHTTPS: true,
        audience: AppConfig.auth0Audience,
        parameters: const {'prompt': 'login'},
      );
      final role = _getUserRole(credentials.accessToken);

      if (role != UserType.recipient) {
        _errorMsg = "You must be a 'Recipient' to login.";
      } else {
        _credentials = credentials;
      }
    } on WebAuthenticationException catch (e) {
      _errorMsg = e.details.isNotEmpty ? "${e.details}" : null;
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
      _credentials = await _auth0
          .webAuthentication(scheme: AppConfig.auth0RedirectScheme)
          .login(
        useHTTPS: true,
        audience: AppConfig.auth0Audience,
        useEphemeralSession: true,
        parameters: const {'screen_hint': 'signup', 'prompt': 'login'},
      );
    } on WebAuthenticationException catch (e) {
      _errorMsg = e.details.isNotEmpty ? "${e.details}" : null;
      debugPrint("[AUTH0_ERROR]: $e");
    } catch (e) {
      debugPrint("[UNEXPECTED_AUTH0_ERROR]: $e");
    } finally {
      _isLoading = false;
    }
  }

  Future<void> logout() async {
    _isLoading = true;

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
    final roles = payload['${AppConfig.auth0Namespace}/roles'];

    return (roles is List) ? UserType.fromString(roles.firstOrNull) : null;
  }
}

enum NotificationStatus {
  idle,
  loading,
  error,
}

class NotificationProvider extends ChangeNotifier {
  final NotificationService _notificationService;
  final UserProvider _userProvider;

  List<AppNotification> _notifications = [];
  NotificationStatus _status = NotificationStatus.idle;
  String? _errorMessage;

  NotificationProvider(this._notificationService, this._userProvider);

  List<AppNotification> get notifications => _notifications;
  NotificationStatus get status => _status;
  String? get errorMessage => _errorMessage;

  Future<void> fetchNotifications() async {
    if (!_userProvider.isLoggedIn) {
      resetState();
      return;
    }

    _updateStatus(NotificationStatus.loading);

    final accessToken = _userProvider.credentials!.accessToken;
    final result = await _notificationService.getNotifications(
      NotificationFilter(),
      accessToken,
    );

    if (result.error == null && result.data != null) {
      _notifications = result.data!.toTypedList(
        (data) => AppNotification.fromJson(data),
      );
      _updateStatus(NotificationStatus.idle);
    } else {
      _errorMessage = ApiServiceError.getErrorMessage(result.error!);
      _updateStatus(NotificationStatus.error);
    }
  }

  Future<void> markAsRead(String id) async {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index == -1 || _notifications[index].isRead) return;

    _notifications[index].isRead = true;
    notifyListeners();

    if (!_userProvider.isLoggedIn) return;

    final accessToken = _userProvider.credentials!.accessToken;
    final result = await _notificationService.markAsRead(id, accessToken);

    if (result.error != null || result.data == false) {
      _notifications[index].isRead = false;
      notifyListeners();
      debugPrint(
        'Failed to mark notification $id as read: ${ApiServiceError.getErrorMessage(result.error!)}',
      );
    }
  }

  Future<void> dismissNotification(String id) async {
    final int initialLength = _notifications.length;
    _notifications.removeWhere((n) => n.id == id);

    // Only notify listeners if a notification was actually removed.
    if (_notifications.length < initialLength) {
      notifyListeners();
    }

    if (!_userProvider.isLoggedIn) return;

    final accessToken = _userProvider.credentials!.accessToken;
    final result = await _notificationService.deleteNotification(
      id,
      accessToken,
    );

    if (result.error != null || result.data == false) {
      debugPrint(
        'Failed to dismiss notification $id: ${ApiServiceError.getErrorMessage(result.error!)}',
      );
      // Re-fetch only if the dismissal failed on the server
      await fetchNotifications();
    }
  }

  void resetState() {
    _notifications = [];
    _errorMessage = null;
    _updateStatus(NotificationStatus.idle);
  }

  void _updateStatus(NotificationStatus newStatus) {
    _status = newStatus;
    notifyListeners();
  }
}
