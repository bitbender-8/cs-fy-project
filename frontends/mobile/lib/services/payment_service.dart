import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/config.dart';
import 'package:mobile/models/campaign.dart';
import 'package:mobile/models/server/errors.dart';
import 'package:mobile/models/server/response.dart';

class PaymentService {
  Future<ServiceResult<CampaignDonation>> verifyDonation(
    String campaignId,
    String txnRef,
  ) async {
    Uri uri = Uri.parse(
      "${AppConfig.apiUrl}/campaigns/$campaignId/verify-donation/$txnRef",
    );

    debugPrint("[REQUEST_URI]: $uri");

    try {
      final response = await http.post(uri);

      debugPrint(
        "[RESPONSE]: ${response.statusCode} - ${response.body}",
      );

      if (200 <= response.statusCode && response.statusCode < 300) {
        return (
          data: CampaignDonation.fromJson(jsonDecode(response.body)),
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
}
