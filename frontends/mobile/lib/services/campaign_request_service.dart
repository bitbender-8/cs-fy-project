import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile/config.dart';
import 'package:mobile/models/campaign_request.dart';
import 'package:mobile/models/server/errors.dart';
import 'package:mobile/models/server/response.dart';

class CampaignRequestService {
  // If `apiUrl` in config.dart is a `const String`, you may keep this `const`.
  // Otherwise, switch to `static final String baseUrl = '$apiUrl/campaign-requests';`
  static const String baseUrl = "$apiUrl/campaign-requests";

  Future<ServiceResult<PaginatedList<CampaignRequest>>> getCampaignRequests({
    String? campaignId,
    String? requestType,
    bool? isResolved,
    DateTime? minRequestDate,
    DateTime? maxRequestDate,
    DateTime? minResolutionDate,
    DateTime? maxResolutionDate,
    String? title,
    int? page,
    int? limit,
    required String accessToken,
  }) async {
    Uri getUrl = Uri.parse(baseUrl);

    // Build query parameters
    final queryParams = <String, String>{};
    if (campaignId != null) queryParams['campaignId'] = campaignId;
    if (requestType != null) queryParams['requestType'] = requestType;
    if (isResolved != null) queryParams['isResolved'] = isResolved.toString();
    if (minRequestDate != null) {
      queryParams['minRequestDate'] = minRequestDate.toIso8601String();
    }
    if (maxRequestDate != null) {
      queryParams['maxRequestDate'] = maxRequestDate.toIso8601String();
    }
    if (minResolutionDate != null) {
      queryParams['minResolutionDate'] = minResolutionDate.toIso8601String();
    }
    if (maxResolutionDate != null) {
      queryParams['maxResolutionDate'] = maxResolutionDate.toIso8601String();
    }
    if (title != null) queryParams['title'] = title;
    if (page != null) queryParams['page'] = page.toString();
    if (limit != null) queryParams['limit'] = limit.toString();

    getUrl = getUrl.replace(queryParameters: queryParams);

    try {
      final response = await http.get(
        getUrl,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

    print(
        "=========================== \n "
        "Fetching campaign requests from API: ${getUrl.toString()}",
      );

      if (response.statusCode == 200) {
        final decodedBody = jsonDecode(response.body) as Map<String, dynamic>;

        print("==================\n" 
            "Response body: ${jsonEncode(decodedBody)}\n"
            "==================");

        // First, decode into PaginatedList<Map<String, dynamic>> to get raw JSON objects:
        final rawPage = PaginatedList<Map<String, dynamic>>.fromJson(
          decodedBody,
          (data) => data as Map<String, dynamic>,
        );

        // Then convert each `Map<String, dynamic>` into a CampaignRequest subclass:
        final List<CampaignRequest> typedItems = rawPage.items
            .map((jsonMap) => _mapToCampaignRequest(jsonMap))
            .toList();

        final paginatedResult = PaginatedList<CampaignRequest>(
          items: typedItems,
          pageNo: rawPage.pageNo,
          pageCount: rawPage.pageCount,
        );

    print(
        "=========================== \n "
        "Successfully fetched ${jsonEncode(paginatedResult.items[1].toJson())} campaign requests.",
      );

        // Return a Dart record matching `ServiceResult<…>`:
        return (
          data: paginatedResult,
          error: null,
        );
      } else {
        // Non‐200: decode a ProblemDetails (which implements ApiServiceError)
        final problem = ProblemDetails.fromJson(jsonDecode(response.body));
        return (
          data: null,
          error: problem,
        );
      }
    } catch (e) {
      print("Error during HTTP request: $e");
      return (
        data: null,
        error: SimpleError('An unexpected error occurred: $e'),
      );
    }
  }

  /// Helper to pick the right subclass based on `json['requestType']`
  CampaignRequest _mapToCampaignRequest(Map<String, dynamic> json) {
    final String? apiRequestType = json['requestType'] as String?;
    if (apiRequestType == null) {
      throw Exception(
        "Campaign request JSON missing 'requestType' field: $json",
      );
    }

    switch (apiRequestType) {
      case 'Goal Adjustment':
      case 'GOAL_ADJUSTMENT_REQUEST':
        return GoalAdjustmentRequest.fromJson({
          ...json,
          'type': 'GOAL_ADJUSTMENT_REQUEST',
        });

      case 'Status Change':
      case 'STATUS_CHANGE_REQUEST':
        return StatusChangeRequest.fromJson({
          ...json,
          'type': 'STATUS_CHANGE_REQUEST',
        });

      case 'Post Update':
      case 'POST_UPDATE_REQUEST':
        // If the API nested a `newPost` object, pull out its `id` as `newPostId`.
        final mappedJson = {
          ...json,
          'type': 'POST_UPDATE_REQUEST',
        };
        if (json['newPost'] != null && json['newPost'] is Map<String, dynamic>) {
          mappedJson['newPostId'] =
              (json['newPost'] as Map<String, dynamic>)['id'];
        }
        return PostUpdateRequest.fromJson(mappedJson);

      case 'End Date Extension':
      case 'END_EXTENSION_REQUEST':
        return EndDateExtensionRequest.fromJson({
          ...json,
          'type': 'END_EXTENSION_REQUEST',
        });

      default:
        throw Exception('Unknown campaign request type from API: $apiRequestType');
    }
  }

  Future<ServiceResult<CampaignRequest>> getCampaignRequestById(
    String id, String accessToken) async {
    final Uri getUrl = Uri.parse('$baseUrl/$id');

    try {
      final response = await http.get(
        getUrl,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      print(
        "=========================== \n "
        "Fetching campaign request from API: ${getUrl.toString()}",
      );

      if (response.statusCode == 200) {
        final decodedBody = jsonDecode(response.body) as Map<String, dynamic>;

        print("==================\n"
            "Response body: ${jsonEncode(decodedBody)}\n"
            "==================");

        final campaignRequest = _mapToCampaignRequest(decodedBody);

        print(
          "=========================== \n "
          "Successfully fetched campaign request: ${jsonEncode(campaignRequest.toJson())}",
        );

        return (
          data: campaignRequest,
          error: null,
        );
      } else {
        final problem = ProblemDetails.fromJson(jsonDecode(response.body));
        return (
          data: null,
          error: problem,
        );
      }
    } catch (e) {
      print("Error during HTTP request for single campaign request: $e");
      return (
        data: null,
        error: SimpleError('An unexpected error occurred: $e'),
      );
    }
  }

 Future<ServiceResult<CampaignRequest>> updateCampaignRequest(
    String requestId,
    String accessToken, {
    required String title,
    required String justification,
  }) async {
    final Uri updateUrl = Uri.parse('$baseUrl/$requestId');
    final body = jsonEncode({
      'title': title,
      'justification': justification,
      // Assuming the backend API can handle a PUT/PATCH with only these fields.
      // If it expects the full object, you might need to send other fields from the original request.
    });

    try {
      // Using PUT, but PATCH might be more semantically correct if only updating specific fields.
      // Adjust according to your backend API design.
      final response = await http.put(
        updateUrl,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: body,
      );

      print(
        "=========================== \n "
        "Updating campaign request ${requestId} at API: ${updateUrl.toString()}\n"
        "Body: $body",
      );

      if (response.statusCode == 200) {
        final decodedBody = jsonDecode(response.body) as Map<String, dynamic>;
        print("==================\n"
            "Update Response body: ${jsonEncode(decodedBody)}\n"
            "==================");
        final updatedRequest = _mapToCampaignRequest(decodedBody); // Ensure this handles the response correctly
        print(
          "=========================== \n "
          "Successfully updated campaign request: ${jsonEncode(updatedRequest.toJson())}",
        );
        return (data: updatedRequest, error: null);
      } else {
        print("==================\n"
            "Update Error Status: ${response.statusCode}\n"
            "Update Error Body: ${response.body}\n"
            "==================");
        final problem = ProblemDetails.fromJson(jsonDecode(response.body));
        return (data: null, error: problem);
      }
    } catch (e) {
      print("Error during HTTP request for updating campaign request: $e");
      return (
        data: null,
        error: SimpleError('An unexpected error occurred during update: $e'),
      );
    }
  }

 Future<ServiceResult<CampaignRequest>> createCampaignRequest({
    required String campaignId, // TODO: This ID needs to be sourced correctly
    required String accessToken,
    required String requestType,
    required String title,
    required String justification,
  }) async {
    final Uri createUrl = Uri.parse('$baseUrl?campaignId=$campaignId');
    final body = jsonEncode({
      'requestType': requestType, // Ensure this matches backend expectations
      'title': title,
      'justification': justification,
      // Add other fields if required by the specific requestType for creation
    });

    try {
      final response = await http.post(
        createUrl,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: body,
      );

      print(
        "=========================== \n "
        "Creating campaign request for campaign ${campaignId} at API: ${createUrl.toString()}\n"
        "Body: $body",
      );

      if (response.statusCode == 201) {
        final decodedBody = jsonDecode(response.body) as Map<String, dynamic>;
        print("==================\n"
            "Create Response body: ${jsonEncode(decodedBody)}\n"
            "==================");
        final createdRequest = _mapToCampaignRequest(decodedBody);
        print(
          "=========================== \n "
          "Successfully created campaign request: ${jsonEncode(createdRequest.toJson())}",
        );
        return (data: createdRequest, error: null);
      } else {
        print("==================\n"
            "Create Error Status: ${response.statusCode}\n"
            "Create Error Body: ${response.body}\n"
            "==================");
        final problem = ProblemDetails.fromJson(jsonDecode(response.body));
        return (data: null, error: problem);
      }
    } catch (e) {
      print("Error during HTTP request for creating campaign request: $e");
      return (
        data: null,
        error: SimpleError('An unexpected error occurred during creation: $e'),
      );
    }
  }
}
