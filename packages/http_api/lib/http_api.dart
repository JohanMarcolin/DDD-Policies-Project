import 'dart:convert';
import 'package:http/http.dart' as http;

part 'http_method.dart';
part 'http_api_response.dart';

class _UnauthorizedException implements Exception {}

/// Abstract base class for making HTTP API calls.
///
/// Provides generic methods for CRUD requests, with support for authentication and token refresh.
abstract class HttpApi {
  static String _baseUrl = 'http://0.0.0.0:8080';

  /// Sets the base URL for all API requests.
  ///
  /// Useful for configuring different environments (e.g., development and e2e testing).
  static set baseUrl(String url) => _baseUrl = url;

  /// Performs a `GET` request to [endpoint] and maps the response using [map].
  /// Optionally includes [accessToken] for authentication and [refreshAccessToken] for token refresh.
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

  /// Performs a `POST` request to [endpoint] with [data] and maps the response using [map].
  /// Optionally includes [accessToken] for authentication and [refreshAccessToken] for token refresh.
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

  /// Performs a `PUT` request to [endpoint] with [data] and maps the response using [map].
  /// Optionally includes [accessToken] for authentication and [refreshAccessToken] for token refresh.
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

  /// Performs a `DELETE` request to [endpoint] and maps the response using [map].
  /// Optionally includes [accessToken] for authentication and [refreshAccessToken] for token refresh.
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

  /// Internal helper to perform the HTTP request and decode the response.
  Future<Map<String, dynamic>> _call({
    required HttpMethod method,
    required String endpoint,
    Object? data,
    String? accessToken,
    Future<String?> Function()? refreshAccessToken,
  }) async {
    http.Response response;
    if (accessToken == null) {
      response = await _doPlainRequest(method: method, endpoint: endpoint, data: data);
    } else {
      response = await _doAuthedRequest(
        method: method,
        endpoint: endpoint,
        data: data,
        accessToken: accessToken,
        refreshAccessToken: refreshAccessToken,
      );
    }
    final decoded = response.body.isNotEmpty ? jsonDecode(response.body) : <String, dynamic>{};
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    throw Exception('Invalid response format: expected a JSON object');
  }

  /// Performs an unauthenticated HTTP request.
  Future<http.Response> _doPlainRequest({required HttpMethod method, required String endpoint, Object? data}) async {
    final uri = _buildUri(endpoint);
    return switch (method) {
      Get() => await http.get(uri),
      Post() => await http.post(uri, body: data),
      Put() => await http.put(uri, body: data),
      Delete() => await http.delete(uri),
    };
  }

  /// Performs an authenticated HTTP request, with optional token refresh.
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

  /// Builds a [Uri] for the given [endpoint] using the current base URL.
  Uri _buildUri(String endpoint) {
    return Uri.parse('$_baseUrl$endpoint');
  }

  /// Builds authentication headers for the given [accessToken].
  Map<String, String> _buildAuthHeaders(String accessToken) {
    return {'Authorization': 'Bearer $accessToken'};
  }

  /// Handles authentication retry logic for requests that return `401` Unauthorized.
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

  /// Invokes the [refreshAccessToken] callback to obtain a new token.
  Future<String?> _refreshAccessToken(Future<String?> Function()? refreshAccessToken) async {
    if (refreshAccessToken != null) {
      return await refreshAccessToken();
    }
    throw _UnauthorizedException();
  }
}
