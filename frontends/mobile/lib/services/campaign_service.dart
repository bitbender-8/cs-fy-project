import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import 'package:file_picker/file_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:mobile/config.dart';
import 'package:mobile/models/campaign.dart';
import 'package:mobile/models/server/errors.dart';
import 'package:mobile/models/server/filters.dart';
import 'package:mobile/models/server/response.dart';

class CampaignService {
  static const String baseUrl = '$apiUrl/campaigns';

  Future<ServiceResult<Campaign>> createCampaign(
    Campaign campaignData,
    List<PlatformFile> supportingDocuments,
    String accessToken,
  ) async {
    // Check supporting documents
    if (supportingDocuments.isEmpty) {
      return (
        data: null,
        error: SimpleError(
          'Supporting documents are required for campaign creation.',
        ),
      );
    }

    // Construct multipart request body
    final request = http.MultipartRequest('POST', Uri.parse(baseUrl));
    request.headers['Authorization'] = 'Bearer $accessToken';

    Map<String, String> fields = {
      'title': campaignData.title,
      'description': campaignData.description,
      'fundraisingGoal': campaignData.fundraisingGoal,
      'category': campaignData.category,
      'endDate': campaignData.endDate!.toIso8601String(),
      'paymentInfo[chapaBankCode]':
          campaignData.paymentInfo!.chapaBankCode.toString(),
      'paymentInfo[chapaBankName]': campaignData.paymentInfo!.chapaBankName,
      'paymentInfo[bankAccountNo]': campaignData.paymentInfo!.bankAccountNo,
    };

    for (var field in fields.entries) {
      request.fields[field.key] = field.value;
    }

    // Add supporting documents
    for (var file in supportingDocuments) {
      if (file.bytes == null && file.path == null) {
        return (
          data: null,
          error: SimpleError('Warning: File ${file.name} has no bytes or path.')
        );
      }

      final bytes = file.bytes;
      final path = file.path;

      final mimeType = lookupMimeType(file.name) ?? 'application/octet-stream';
      final mimeSplit = mimeType.split('/');

      if (bytes != null) {
        // Use bytes directly
        request.files.add(
          http.MultipartFile.fromBytes(
            'documents',
            bytes,
            filename: file.name,
            contentType: MediaType(mimeSplit[0], mimeSplit[1]),
          ),
        );
      } else {
        // bytes is null, so path is not null here
        final actualFile = File(path!);
        final stream = http.ByteStream(actualFile.openRead());
        final length = await actualFile.length();

        request.files.add(
          http.MultipartFile(
            'documents',
            stream,
            length,
            filename: actualFile.path.split('/').last,
            contentType: MediaType(mimeSplit[0], mimeSplit[1]),
          ),
        );
      }
    }

    debugPrint("[REQUEST_BODY]: ${request.fields.toString()}");

    try {
      final streamedResponse = await request.send();
      final createResponse = await http.Response.fromStream(streamedResponse);

      debugPrint(
        "[RESPONSE]: ${createResponse.statusCode} - ${createResponse.body}",
      );

      if (createResponse.statusCode == 201) {
        return (
          data: Campaign.fromJson(jsonDecode(createResponse.body)),
          error: null,
        );
      } else {
        return (
          data: null,
          error: ProblemDetails.fromJson(jsonDecode(createResponse.body)),
        );
      }
    } catch (e) {
      return (
        data: null,
        error: ApiServiceError.handleException(e),
      );
    }
  }

  Future<ServiceResult<PaginatedList<Campaign>>> getCampaigns(
    CampaignFilter filters,
    String? accessToken,
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
      debugPrint("[RESPONSE]: ${response.body}");

      final decodedBody = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200) {
        return (
          data: PaginatedList<Campaign>.fromJson(
            decodedBody,
            (data) => Campaign.fromJson(data as Map<String, dynamic>),
          ),
          error: null,
        );
      } else {
        return (data: null, error: ProblemDetails.fromJson(decodedBody));
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
