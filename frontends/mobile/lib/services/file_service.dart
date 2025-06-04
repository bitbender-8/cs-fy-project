import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mobile/config.dart';
import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart' as path;
import 'package:mobile/models/server/errors.dart';
import 'package:mobile/models/server/response.dart';
import 'package:path_provider/path_provider.dart';

class FileService {
  static const String baseUrl = "$apiUrl/files";

  /// Downloads a file from [fileUrl] with optional [accessToken],
  /// saves it locally, and attempts to open it.
  ///
  /// Returns a [ServiceResult<File>] with the local file on success,
  /// or an error on failure.
  Future<ServiceResult<File>> openFileFromUrl({
    required String fileUrl,
    String? accessToken,
  }) async {
    try {
      final uri = Uri.parse(fileUrl);
      final filename = path.basename(uri.path);
      if (filename.isEmpty) {
        return (
          data: null,
          error: SimpleError('Invalid file URL: no filename found'),
        );
      }

      final response = await http.get(uri, headers: {
        if (accessToken != null && accessToken.isNotEmpty)
          'Authorization': 'Bearer $accessToken',
      });

      if (response.statusCode != 200) {
        return (
          data: null,
          error: ProblemDetails.fromJson(jsonDecode(response.body))
        );
      }

      final tempDir = await getTemporaryDirectory();
      final filePath = path.join(tempDir.path, filename);

      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);

      final openResult = await OpenFilex.open(filePath);
      if (openResult.type != ResultType.done) {
        return (
          data: file,
          error: SimpleError('Failed to open file'),
        );
      }

      return (data: file, error: null);
    } catch (e, stacktrace) {
      debugPrint('[REQUEST_ERROR]: $e\n$stacktrace');

      return (
        data: null,
        error: SimpleError(
          'An unexpected error occurred while opening the file.',
        ),
      );
    }
  }
}
