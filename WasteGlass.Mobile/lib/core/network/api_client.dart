import 'dart:convert';
import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';

class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Uri _uri(String path) => Uri.parse('${ApiConstants.baseUrl}$path');

  Future<Map<String, dynamic>> getTodayTrip() async {
    return getMap(ApiConstants.todayTrip);
  }

  Future<Map<String, dynamic>> postCollection(Map<String, dynamic> body) async {
    return postMap(ApiConstants.collections, body);
  }

  Future<Map<String, dynamic>> syncCollections(Map<String, dynamic> body) async {
    return postMap(ApiConstants.syncCollections, body);
  }

  Future<Map<String, dynamic>> getTripReport(int tripId) async {
    return getMap(ApiConstants.tripReport(tripId));
  }

  Future<List<dynamic>> getSuppliers() async {
    final response = await get(ApiConstants.suppliers);
    if (response is List) {
      return response;
    }
    throw ApiException('Invalid suppliers response from server.');
  }

  Future<Map<String, dynamic>> getMap(String path) async {
    final response = await get(path);
    if (response is Map<String, dynamic>) {
      return response;
    }
    throw ApiException('Invalid response from server.');
  }

  Future<Map<String, dynamic>> postMap(
    String path,
    Map<String, dynamic> body,
  ) async {
    final response = await post(path, body);
    if (response is Map<String, dynamic>) {
      return response;
    }
    throw ApiException('Invalid response from server.');
  }

  Future<dynamic> get(String path) async {
    try {
      final response = await _client
          .get(_uri(path), headers: _headers)
          .timeout(const Duration(seconds: 12));
      return _decode(response);
    } on SocketException {
      throw ApiException('No internet connection.');
    } on TimeoutException {
      throw ApiException('Request timed out. Please try again.');
    } on http.ClientException {
      throw ApiException('Could not reach the server.');
    } on FormatException {
      throw ApiException('Server returned an invalid response.');
    }
  }

  Future<dynamic> post(String path, Map<String, dynamic> body) async {
    try {
      final response = await _client
          .post(_uri(path), headers: _headers, body: jsonEncode(body))
          .timeout(const Duration(seconds: 12));
      return _decode(response);
    } on SocketException {
      throw ApiException('No internet connection.');
    } on TimeoutException {
      throw ApiException('Request timed out. Please try again.');
    } on http.ClientException {
      throw ApiException('Could not reach the server.');
    } on FormatException {
      throw ApiException('Server returned an invalid response.');
    }
  }

  Map<String, String> get _headers => const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  dynamic _decode(http.Response response) {
    final decoded = response.body.isEmpty ? null : jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded;
    }

    final message = decoded is Map<String, dynamic>
        ? decoded['message']?.toString() ??
            decoded['title']?.toString() ??
            _modelStateMessage(decoded)
        : null;
    throw ApiException(message ?? 'Request failed (${response.statusCode}).');
  }

  String? _modelStateMessage(Map<String, dynamic> decoded) {
    final errors = decoded['errors'];
    if (errors is Map && errors.isNotEmpty) {
      final firstValue = errors.values.first;
      if (firstValue is List && firstValue.isNotEmpty) {
        return firstValue.first.toString();
      }
      return firstValue.toString();
    }
    return null;
  }
}

class ApiException implements Exception {
  ApiException(this.message);
  final String message;

  @override
  String toString() => message;
}
