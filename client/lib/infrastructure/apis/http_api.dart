import 'dart:convert';
import 'package:client/infrastructure/apis/http_api_response.dart';
import 'package:http/http.dart' as http;

part 'http_method.dart';

class _UnauthorizedException implements Exception {}

abstract class HttpApi {
  const HttpApi();

  static const String baseUrl = 'http://10.0.2.2:8080';

  Future<T> callGet<T>({
    required String endpoint,
    required T Function(HttpApiResponse response) map,
    String? accessToken,
    Future<String?> Function()? refreshAccessToken,
  }) async {
    final decoded = await _call(
      method: HttpMethod.get,
      endpoint: endpoint,
      accessToken: accessToken,
      refreshAccessToken: refreshAccessToken,
    );
    return map(HttpApiResponse.fromMap(decoded));
  }

  Future<T> callPost<T>({
    required String endpoint,
    Object? data,
    required T Function(HttpApiResponse response) map,
    String? accessToken,
    Future<String?> Function()? refreshAccessToken,
  }) async {
    final decoded = await _call(
      method: HttpMethod.post,
      endpoint: endpoint,
      data: data,
      accessToken: accessToken,
      refreshAccessToken: refreshAccessToken,
    );
    return map(HttpApiResponse.fromMap(decoded));
  }

  Future<T> callPut<T>({
    required String endpoint,
    Object? data,
    required T Function(HttpApiResponse response) map,
    String? accessToken,
    Future<String?> Function()? refreshAccessToken,
  }) async {
    final decoded = await _call(
      method: HttpMethod.put,
      endpoint: endpoint,
      data: data,
      accessToken: accessToken,
      refreshAccessToken: refreshAccessToken,
    );
    return map(HttpApiResponse.fromMap(decoded));
  }

  Future<T> callDelete<T>({
    required String endpoint,
    required T Function(HttpApiResponse response) map,
    String? accessToken,
    Future<String?> Function()? refreshAccessToken,
  }) async {
    final decoded = await _call(
      method: HttpMethod.delete,
      endpoint: endpoint,
      accessToken: accessToken,
      refreshAccessToken: refreshAccessToken,
    );
    return map(HttpApiResponse.fromMap(decoded));
  }

  Future<Map<String, dynamic>> _call({
    required HttpMethod method,
    required String endpoint,
    Object? data,
    String? accessToken,
    Future<String?> Function()? refreshAccessToken,
  }) async {
    http.Response response;
    if (accessToken == null) {
      response = await _doPlainRequest(
        method: method,
        endpoint: endpoint,
        data: data,
      );
    } else {
      response = await _doAuthedRequest(
        method: method,
        endpoint: endpoint,
        data: data,
        accessToken: accessToken,
        refreshAccessToken: refreshAccessToken,
      );
    }
    final decoded = response.body.isNotEmpty
        ? jsonDecode(response.body)
        : <String, dynamic>{};
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    throw Exception('Invalid response format: expected a JSON object');
  }

  Future<http.Response> _doPlainRequest({
    required HttpMethod method,
    required String endpoint,
    Object? data,
  }) async {
    final uri = _buildUri(endpoint);
    return switch (method) {
      Get() => await http.get(uri),
      Post() => await http.post(uri, body: data),
      Put() => await http.put(uri, body: data),
      Delete() => await http.delete(uri),
    };
  }

  Future<http.Response> _doAuthedRequest({
    required HttpMethod method,
    required String endpoint,
    Object? data,
    required String accessToken,
    Future<String?> Function()? refreshAccessToken,
  }) async {
    final uri = _buildUri(endpoint);

    Future<http.Response> request(String token) {
      final headers = _buildAuthHeaders(token);
      return switch (method) {
        Get() => http.get(uri, headers: headers),
        Post() => http.post(uri, headers: headers, body: data),
        Put() => http.put(uri, headers: headers, body: data),
        Delete() => http.delete(uri, headers: headers),
      };
    }

    return await _withAuthRetry(request, accessToken, refreshAccessToken);
  }

  Uri _buildUri(String endpoint) {
    return Uri.parse('$baseUrl$endpoint');
  }

  Map<String, String> _buildAuthHeaders(String accessToken) {
    return {'Authorization': 'Bearer $accessToken'};
  }

  Future<http.Response> _withAuthRetry(
    Future<http.Response> Function(String token) req,
    String accessToken,
    Future<String?> Function()? refreshAccessToken,
  ) async {
    final response = await req(accessToken);
    if (response.statusCode == 401 && refreshAccessToken != null) {
      final newToken = await _refreshAccessToken(refreshAccessToken);
      if (newToken != null) {
        final retry = await req(newToken);
        if (retry.statusCode != 401) return retry;
      }
      throw _UnauthorizedException();
    }
    return response;
  }

  Future<String?> _refreshAccessToken(
    Future<String?> Function()? refreshAccessToken,
  ) async {
    if (refreshAccessToken != null) {
      return await refreshAccessToken();
    }
    throw _UnauthorizedException();
  }
}
