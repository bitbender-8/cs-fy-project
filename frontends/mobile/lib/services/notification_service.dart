import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

import 'package:mobile/config.dart';
import 'package:mobile/models/app_notification.dart';
import 'package:mobile/models/server/errors.dart';
import 'package:mobile/models/server/filters.dart';
import 'package:mobile/models/server/response.dart';

class NotificationService {
  static const baseUrl = "$apiUrl/notifications";

  Future<ServiceResult<PaginatedList<AppNotification>>> getNotifications(
    NotificationFilter filters,
    String accessToken,
  ) async {
    Uri uri = Uri.parse(baseUrl);
    final queryParams = filters.toMap();
    if (queryParams != null) uri = uri.replace(queryParameters: queryParams);

    debugPrint("[REQUEST_URI]: $uri");

    try {
      final response = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $accessToken'},
      );
      debugPrint("[RESPONSE]: ${jsonEncode(response.body)}");

      if (response.statusCode == 200) {
        final decodedBody = jsonDecode(response.body) as Map<String, dynamic>;

        return (
          data: PaginatedList<AppNotification>.fromJson(
            decodedBody,
            (data) => AppNotification.fromJson(data as Map<String, dynamic>),
          ),
          error: null,
        );
      } else {
        return (
          data: null,
          error: ProblemDetails.fromJson(jsonDecode(response.body))
        );
      }
    } catch (e) {
      debugPrint("[REQUEST_ERROR]: $e");

      return (
        data: null,
        error: SimpleError('An unexpected error occurred: $e')
      );
    }
  }

  Future<ServiceResult<bool?>> markAsRead(
    String notificationId,
    String accessToken,
  ) async {
    Uri uri = Uri.parse("$baseUrl/$notificationId/read");
    debugPrint("[REQUEST_URI]: $uri");

    try {
      final response = await http.patch(
        uri,
        headers: {'Authorization': 'Bearer $accessToken'},
      );
      debugPrint("[RESPONSE]: ${response.body}");

      if (response.statusCode == 204) {
        return (
          data: true,
          error: null,
        );
      } else {
        return (
          data: null,
          error: ProblemDetails.fromJson(jsonDecode(response.body))
        );
      }
    } catch (e) {
      debugPrint("[REQUEST_ERROR]: $e");

      return (
        data: null,
        error: SimpleError('An unexpected error occurred: $e')
      );
    }
  }

  Future<ServiceResult<bool?>> deleteNotification(
    String notificationId,
    String accessToken,
  ) async {
    Uri uri = Uri.parse("$baseUrl/$notificationId");
    debugPrint("[REQUEST_URI]: $uri");

    try {
      final response = await http.delete(
        uri,
        headers: {'Authorization': 'Bearer $accessToken'},
      );
      debugPrint("[RESPONSE]: ${response.body}");

      if (response.statusCode == 204) {
        return (
          data: true,
          error: null,
        );
      } else {
        return (
          data: null,
          error: ProblemDetails.fromJson(jsonDecode(response.body))
        );
      }
    } catch (e) {
      debugPrint("[REQUEST_ERROR]: $e");

      return (
        data: null,
        error: SimpleError('An unexpected error occurred: $e')
      );
    }
  }
}
