import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/config.dart';
import 'package:mobile/models/campaign_request.dart';
import 'package:mobile/models/server/errors.dart';
import 'package:mobile/models/server/filters.dart';
import 'package:mobile/models/server/response.dart';

class CampaignRequestService {
  static const String baseUrl = "${AppConfig.apiUrl}/campaign-requests";

  /// Fetches a paginated list of campaign requests based on provided filters.
  Future<ServiceResult<PaginatedList<CampaignRequest>>> getCampaignRequests(
    CampaignRequestFilter filter,
    String accessToken,
  ) async {
    Uri getUrl = Uri.parse(baseUrl);
    final queryParams = filter.toMap();
    if (queryParams != null) {
      getUrl = getUrl.replace(queryParameters: queryParams);
    }

    debugPrint("[REQUEST_URI]: $getUrl");

    try {
      final response = await http.get(getUrl, headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      });
      debugPrint(
        "[RESPONSE]: ${response.statusCode} - ${response.body}",
      );

      if (response.statusCode == 200) {
        return (
          data: PaginatedList<CampaignRequest>.fromJson(
            jsonDecode(response.body),
            (data) => CampaignRequest.fromJson(data as Map<String, dynamic>),
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

  /// Fetches a single campaign request by its ID.
  Future<ServiceResult<CampaignRequest>> getCampaignRequestById(
    String id,
    String accessToken,
  ) async {
    final Uri getUrl = Uri.parse('$baseUrl/$id');

    try {
      final response = await http.get(getUrl, headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      });

      debugPrint(
        "[RESPONSE]: ${response.statusCode} - ${response.body}",
      );

      if (response.statusCode == 200) {
        return (
          data: CampaignRequest.fromJson(jsonDecode(response.body)),
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

  /// Creates a new campaign request by accepting a CampaignRequest object.
  Future<ServiceResult<CampaignRequest>> createCampaignRequest(
    CampaignRequest campaignRequest,
    String accessToken,
  ) async {
    final Uri createUrl =
        Uri.parse('$baseUrl?campaignId=${campaignRequest.campaignId}');
    final body = jsonEncode(campaignRequest.toJson());

    try {
      final response = await http.post(
        createUrl,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: body,
      );

      debugPrint(
        "[RESPONSE]: ${response.statusCode} - ${response.body}",
      );

      if (response.statusCode == 201) {
        return (
          data: CampaignRequest.fromJson(jsonDecode(response.body)),
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

  /// Deletes a campaign request by its ID.
  /// Returns a ServiceResult indicating success or failure. True if successful and null if not.
  Future<ServiceResult<bool?>> deleteCampaignRequest(
      String id, String accessToken) async {
    final Uri deleteUrl = Uri.parse('$baseUrl/$id');

    try {
      final response = await http.delete(deleteUrl, headers: {
        'Authorization': 'Bearer $accessToken',
      });

      debugPrint(
        "[RESPONSE]: ${response.statusCode} - ${response.body}",
      );

      if (response.statusCode == 204) {
        return (data: true, error: null);
      } else {
        // Any other status code indicates an error
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
}
