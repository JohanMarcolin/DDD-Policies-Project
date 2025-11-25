import 'dart:convert';
import 'package:client/infrastructure/services/auth_token_service.dart';
import 'package:domain/entities/user.dart';
import 'package:domain/value_objects/email.dart';
import 'package:domain/value_objects/password.dart';
import 'package:api_error_codes/api_error_codes.dart';
import 'package:mappers/user_mapper.dart';
import 'package:http_api/http_api.dart';

/// API for authentication-related operations: login, logout, and token refresh.
class AuthApi extends HttpApi {
  AuthApi({required AuthTokenService authTokenService}) : _authTokenService = authTokenService;

  final AuthTokenService _authTokenService;

  /// Logs in a user with [email] and [password].
  ///
  /// On success, saves tokens and returns the authenticated [User].
  /// Throws [AuthApiException] on failure.
  Future<User> login({required Email email, required Password password}) async {
    return await callPost<User>(
      endpoint: '/auth/login',
      data: jsonEncode({'email': email.value, 'password': password.value}),
      map: (response) {
        if (response.isSuccess) {
          _authTokenService.saveTokens(
            accessToken: response.data['accessToken'],
            refreshToken: response.data['refreshToken'],
          );
          return UserMapper.toDomainUser(response.data['currentUser']);
        }
        throw AuthApiException(response.apiErrorCode);
      },
    );
  }

  /// Logs out the current user, invalidating the refresh token and clearing local tokens.
  ///
  /// Throws [AuthApiException] on failure.
  Future<void> logout() async {
    final refreshToken = await _authTokenService.refreshToken;

    await callDelete<void>(
      endpoint: '/auth/logout/$refreshToken',
      accessToken: await _authTokenService.accessToken,
      map: (response) {
        if (response.isSuccess) {
          return;
        }
        throw AuthApiException(response.apiErrorCode);
      },
    );

    await _authTokenService.clearTokens();
  }

  /// Refreshes the access token using the stored refresh token.
  ///
  /// On success, updates the access token and returns the authenticated [User].
  /// Throws [AuthApiException] on failure.
  Future<User> refreshAccessToken() async {
    return await callPost<User>(
      endpoint: '/auth/refresh',
      data: jsonEncode({'refreshToken': await _authTokenService.refreshToken}),
      map: (response) {
        if (response.isSuccess) {
          _authTokenService.setAccessToken(accessToken: response.data['accessToken']);
          return UserMapper.toDomainUser(response.data['currentUser']);
        }
        throw AuthApiException(response.apiErrorCode);
      },
    );
  }
}

/// Exception thrown for authentication API errors.
class AuthApiException extends ApiException {
  AuthApiException(super.apiErrorCode);
}
