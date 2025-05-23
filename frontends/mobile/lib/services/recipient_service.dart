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
  static const String baseUrl = "$apiUrl/recipients";

  Future<ServiceResult<Recipient>> createRecipient(
    Recipient recipientData,
    File? profilePicture,
    String accessToken,
  ) async {
    final recipientUrl = Uri.parse(baseUrl);

    final request = http.MultipartRequest('POST', recipientUrl);
    request.headers['Authorization'] = 'Bearer $accessToken';

    // Add fields from recipientData
    request.fields['firstName'] = recipientData.firstName;
    request.fields['middleName'] = recipientData.middleName;
    request.fields['lastName'] = recipientData.lastName;
    if (recipientData.dateOfBirth != null) {
      request.fields['dateOfBirth'] =
          recipientData.dateOfBirth!.toIso8601String();
    }
    if (recipientData.phoneNo != null) {
      request.fields['phoneNo'] = recipientData.phoneNo!;
    }
    request.fields['bio'] = recipientData.bio;

    if (recipientData.socialMediaHandles != null) {
      for (var i = 0; i < recipientData.socialMediaHandles!.length; i++) {
        request.fields['socialMediaHandles[$i]'] =
            recipientData.socialMediaHandles![i].socialMediaHandle;
      }
    }

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
      debugPrint("[REQUEST_ERROR]: $e");

      return (
        data: null,
        error: SimpleError(
          'Failed to send a request to the server. Check your Internet.',
        )
      );
    }
  }

  Future<ServiceResult<Recipient>> getRecipientById(
    String recipientId,
    String accessToken,
  ) async {
    Uri getUrl = Uri.parse("$baseUrl/$recipientId");

    try {
      final response = await http.get(getUrl, headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
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
        error: SimpleError('An unexpected error occurred: $e')
      );
    }
  }

  Future<ServiceResult<PaginatedList<Recipient>>> getRecipients(
    RecipientFilters filters,
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
        'Content-Type': 'application/json',
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
        error: SimpleError('An unexpected error occurred: $e')
      );
    }
  }

  Future<ServiceResult<bool>> deleteAuth0User(
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
        debugPrint(
            '[REQUEST_ERROR]: Error deleting Auth0 user. ${response.statusCode} - ${response.body}');
        return (
          data: false,
          error: ProblemDetails.fromJson(jsonDecode(response.body)),
        );
      }
    } catch (e) {
      debugPrint('[REQUEST_ERROR]: Error sending delete request. $e');
      return (
        data: false,
        error: SimpleError(
          'Failed to send delete request. Check your Internet.',
        ),
      );
    }
  }
}
