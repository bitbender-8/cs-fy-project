import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:mobile/config.dart';
import 'package:mobile/models/campaign.dart';
import 'package:mobile/models/server/errors.dart';
import 'package:mobile/models/server/filters.dart';
import 'package:mobile/models/server/response.dart';

class CampaignPostService {
  static const String baseUrl = '${AppConfig.apiUrl}/campaign-posts';

  Future<ServiceResult<PaginatedList<CampaignPost>>> getCampaignPosts(
    CampaignPostFilter filters,
    String? accessToken,
  ) async {
    Uri uri = Uri.parse(baseUrl);
    final queryParams = filters.toMap();
    if (queryParams != null) uri = uri.replace(queryParameters: queryParams);

    debugPrint("[REQUEST_URI]: $uri");
    try {
      final response = await http.get(
        uri,
        headers: {
          if (accessToken != null) 'Authorization': 'Bearer $accessToken'
        },
      );
      debugPrint("[RESPONSE]: ${response.body}");

      final decodedBody = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200) {
        return (
          data: PaginatedList<CampaignPost>.fromJson(
            decodedBody,
            (data) => CampaignPost.fromJson(data as Map<String, dynamic>),
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
        error: ApiServiceError.handleException(e),
      );
    }
  }
}
