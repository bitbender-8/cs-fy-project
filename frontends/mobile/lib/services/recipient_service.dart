import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:mobile/config.dart';
import 'package:mobile/models/server/filters.dart';
import 'package:mobile/models/recipient.dart';
import 'package:mobile/models/server/errors.dart';
import 'package:mobile/models/server/response.dart';

class RecipientService {
  static const String baseUrl = "${AppConfig.apiUrl}/recipients";

  Future<ServiceResult<Recipient>> createRecipient(
    Recipient recipientData,
    File? profilePicture,
    String accessToken,
  ) async {
    final recipientUrl = Uri.parse(baseUrl);
    final request = http.MultipartRequest('POST', recipientUrl);
    request.headers['Authorization'] = 'Bearer $accessToken';

    final fields = {
      'firstName': recipientData.firstName,
      'middleName': recipientData.middleName,
      'lastName': recipientData.lastName,
      'bio': recipientData.bio,
      if (recipientData.dateOfBirth != null)
        'dateOfBirth': recipientData.dateOfBirth!.toIso8601String(),
      if (recipientData.phoneNo != null) 'phoneNo': recipientData.phoneNo!
    };

    if (recipientData.socialMediaHandles != null) {
      for (var i = 0; i < recipientData.socialMediaHandles!.length; i++) {
        fields['socialMediaHandles[$i][socialMediaHandle]'] =
            recipientData.socialMediaHandles![i].socialMediaHandle;

        if (recipientData.socialMediaHandles![i].recipientId != null) {
          fields['socialMediaHandles[$i][recipientId]'] =
              recipientData.socialMediaHandles![i].recipientId!;
        }
      }
    }
    request.fields.addAll(fields);

    // Add profile picture if it exists
    if (profilePicture != null) {
      final stream = http.ByteStream(profilePicture.openRead());
      final length = await profilePicture.length();
      final filename = profilePicture.path.split('/').last;
      final mimeType =
          lookupMimeType(profilePicture.path) ?? 'application/octet-stream';
      final mimeSplit = mimeType.split('/');

      request.files.add(
        http.MultipartFile(
          'profilePicture',
          stream,
          length,
          filename: filename,
          contentType: MediaType(mimeSplit[0], mimeSplit[1]),
        ),
      );
    }

    debugPrint("[REQUEST_BODY]: ${request.fields.toString()}");

    try {
      final streamedResponse = await request.send();
      final createResponse = await http.Response.fromStream(streamedResponse);
      debugPrint("RESPONSE: ${jsonEncode(createResponse.body)}");

      if (createResponse.statusCode != 201) {
        return (
          data: null,
          error: ProblemDetails.fromJson(jsonDecode(createResponse.body)),
        );
      }

      return (
        data: Recipient.fromJson(jsonDecode(createResponse.body)),
        error: null,
      );
    } catch (e) {
      return (
        data: null,
        error: ApiServiceError.handleException(e),
      );
    }
  }

  Future<ServiceResult<Recipient>> getRecipientById(
    String recipientId,
    String? accessToken,
  ) async {
    Uri getUrl = Uri.parse("$baseUrl/$recipientId");

    try {
      final response = await http.get(getUrl, headers: {
        if (accessToken != null && accessToken.isNotEmpty)
          'Authorization': 'Bearer $accessToken',
      });

      if (response.statusCode == 200) {
        return (
          data: Recipient.fromJson(jsonDecode(response.body)),
          error: null,
        );
      } else {
        return (
          data: null,
          error: ProblemDetails.fromJson(jsonDecode(response.body))
        );
      }
    } catch (e) {
      return (
        data: null,
        error: ApiServiceError.handleException(e),
      );
    }
  }

  Future<ServiceResult<PaginatedList<Recipient>>> getRecipients(
    RecipientFilter filters,
    String accessToken,
  ) async {
    Uri getUrl = Uri.parse(baseUrl);
    final queryParams = filters.toMap();
    if (queryParams != null) {
      getUrl = getUrl.replace(queryParameters: queryParams);
    }

    try {
      final response = await http.get(getUrl, headers: {
        'Authorization': 'Bearer $accessToken',
      });

      if (response.statusCode == 200) {
        final decodedBody = jsonDecode(response.body) as Map<String, dynamic>;

        return (
          data: PaginatedList<Recipient>.fromJson(
            decodedBody,
            (data) => Recipient.fromJson(data as Map<String, dynamic>),
          ),
          error: null
        );
      } else {
        return (
          data: null,
          error: ProblemDetails.fromJson(jsonDecode(response.body))
        );
      }
    } catch (e) {
      return (
        data: null,
        error: ApiServiceError.handleException(e),
      );
    }
  }

  Future<ServiceResult<bool?>> deleteAuth0User(
    String auth0UserId,
    String accessToken,
  ) async {
    final deleteUrl = Uri.parse('$baseUrl/auth0/$auth0UserId');

    try {
      final response = await http.delete(deleteUrl, headers: {
        'Authorization': 'Bearer $accessToken',
      });

      if (response.statusCode == 204) {
        return (data: true, error: null);
      } else {
        return (
          data: null,
          error: ProblemDetails.fromJson(jsonDecode(response.body)),
        );
      }
    } catch (e) {
      return (
        data: null,
        error: ApiServiceError.handleException(e),
      );
    }
  }

  /// Recipient id should be in recipientData
  Future<ServiceResult<bool>> updateRecipient(
    Recipient recipientData,
    File? profilePicture,
    String accessToken,
  ) async {
    final recipientUrl = Uri.parse("$baseUrl/${recipientData.id}");
    final request = http.MultipartRequest('PUT', recipientUrl);
    request.headers['Authorization'] = 'Bearer $accessToken';

    final fields = {
      'firstName': recipientData.firstName,
      'middleName': recipientData.middleName,
      'lastName': recipientData.lastName,
      'bio': recipientData.bio,
      if (recipientData.dateOfBirth != null)
        'dateOfBirth': recipientData.dateOfBirth!.toIso8601String(),
      if (recipientData.phoneNo != null) 'phoneNo': recipientData.phoneNo!
    };

    if (recipientData.socialMediaHandles != null) {
      for (var i = 0; i < recipientData.socialMediaHandles!.length; i++) {
        fields['socialMediaHandles[$i][socialMediaHandle]'] =
            recipientData.socialMediaHandles![i].socialMediaHandle;

        if (recipientData.socialMediaHandles![i].recipientId != null) {
          fields['socialMediaHandles[$i][recipientId]'] =
              recipientData.socialMediaHandles![i].recipientId!;
        }
      }
    }
    request.fields.addAll(fields);

    // Add profile picture if it exists
    if (profilePicture != null) {
      final stream = http.ByteStream(profilePicture.openRead());
      final length = await profilePicture.length();
      final filename = profilePicture.path.split('/').last;
      final mimeType =
          lookupMimeType(profilePicture.path) ?? 'application/octet-stream';
      final mimeSplit = mimeType.split('/');

      request.files.add(
        http.MultipartFile(
          'profilePicture',
          stream,
          length,
          filename: filename,
          contentType: MediaType(mimeSplit[0], mimeSplit[1]),
        ),
      );
    }

    debugPrint("[REQUEST_BODY]: ${request.fields.toString()}");
    try {
      final streamedResponse = await request.send();
      final createResponse = await http.Response.fromStream(streamedResponse);
      debugPrint("RESPONSE: ${jsonEncode(createResponse.body)}");

      if (createResponse.statusCode != 204) {
        return (
          data: null,
          error: ProblemDetails.fromJson(jsonDecode(createResponse.body)),
        );
      }

      return (
        data: true,
        error: null,
      );
    } catch (e) {
      return (
        data: null,
        error: ApiServiceError.handleException(e),
      );
    }
  }
}
