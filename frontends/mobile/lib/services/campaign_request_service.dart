import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/config.dart';
import 'package:mobile/models/campaign_request.dart';
import 'package:mobile/models/server/errors.dart';
import 'package:mobile/models/server/filters.dart';
import 'package:mobile/models/server/response.dart';

class CampaignRequestService {
  static const String baseUrl = "$apiUrl/campaign-requests";

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

      print("Fetching campaign requests from API: ${getUrl.toString()}");

      if (response.statusCode == 200) {
        final decodedBody = jsonDecode(response.body) as Map<String, dynamic>;
        final paginatedResult = PaginatedList<CampaignRequest>.fromJson(
          decodedBody,
          (data) => CampaignRequest.fromJson(data as Map<String, dynamic>),
        );
        return (data: paginatedResult, error: null);
      } else {
        final problem = ProblemDetails.fromJson(jsonDecode(response.body));
        return (data: null, error: problem);
      }
    } catch (e) {
      return (
        data: null,
        error: SimpleError('An unexpected error occurred: $e')
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

      if (response.statusCode == 200) {
        final decodedBody = jsonDecode(response.body) as Map<String, dynamic>;
        final campaignRequest = CampaignRequest.fromJson(decodedBody);
        return (data: campaignRequest, error: null);
      } else {
        final problem = ProblemDetails.fromJson(jsonDecode(response.body));
        return (data: null, error: problem);
      }
    } catch (e) {
      return (
        data: null,
        error: SimpleError('An unexpected error occurred: $e')
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

      if (response.statusCode == 201) {
        final decodedBody = jsonDecode(response.body) as Map<String, dynamic>;
        final createdRequest = CampaignRequest.fromJson(decodedBody);
        return (data: createdRequest, error: null);
      } else {
        final problem = ProblemDetails.fromJson(jsonDecode(response.body));
        return (data: null, error: problem);
      }
    } catch (e) {
      return (
        data: null,
        error: SimpleError('An unexpected error occurred during creation: $e')
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

      if (response.statusCode == 204) {
        return (data: true, error: null);
      } else {
        // Any other status code indicates an error
        final problem = ProblemDetails.fromJson(jsonDecode(response.body));
        return (data: null, error: problem);
      }
    } catch (e) {
      return (
        data: null,
        error: SimpleError('An unexpected error occurred during deletion: $e')
      );
    }
  }
}
