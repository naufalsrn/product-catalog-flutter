import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class ApiException implements Exception {
  ApiException({required this.message, this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

/// Thin wrapper around [http.Client] for the DummyJSON API: builds the
/// request URI, applies a timeout, and turns network failures / non-2xx
/// responses into a single [ApiException] so callers only ever handle one
/// error type instead of HTTP status codes directly.
class AppClient {
  AppClient({required this.baseUrl, http.Client? client})
    : _client = client ?? http.Client();

  final String baseUrl;
  final http.Client _client;

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final uri = Uri.parse('$baseUrl$path').replace(
      queryParameters: queryParameters?.map(
        (key, value) => MapEntry(key, value.toString()),
      ),
    );

    late http.Response response;
    try {
      response = await _client.get(uri).timeout(const Duration(seconds: 15));
    } on SocketException {
      throw ApiException(
        message: 'No internet connection. Please check your network and try again.',
      );
    } on TimeoutException {
      throw ApiException(message: 'The request timed out. Please try again.');
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        message: 'Something went wrong (${response.statusCode}). Please try again.',
        statusCode: response.statusCode,
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw ApiException(message: 'Unexpected response from server.');
    }
    return decoded;
  }
}
