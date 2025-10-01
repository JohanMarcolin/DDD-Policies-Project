import 'dart:convert';
import 'package:client/infrastructure/apis/http_api.dart';
import 'package:client/infrastructure/mappers/user_mapper.dart';
import 'package:client/infrastructure/services/auth_token_service.dart';
import 'package:domain/entities/user.dart';
import 'package:domain/value_objects/email.dart';
import 'package:domain/value_objects/password.dart';
import 'package:error_codes/error_codes.dart';

typedef CurrentUser = User;

class AuthApi extends HttpApi {
  AuthApi({required AuthTokenService authTokenService})
    : _authTokenService = authTokenService;

  final AuthTokenService _authTokenService;

  Future<CurrentUser> login({
    required Email email,
    required Password password,
  }) async {
    return await callPost<CurrentUser>(
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

        throw AuthApiException(response.errorCode!);
      },
    );
  }

  Future<void> logout() async {
    final refreshToken = await _authTokenService.refreshToken;

    await callDelete<void>(
      endpoint: '/auth/logout/$refreshToken',
      accessToken: await _authTokenService.accessToken,
      map: (response) {
        if (response.isSuccess) {
          return;
        }
        throw AuthApiException(response.errorCode!);
      },
    );

    await _authTokenService.clearTokens();
  }

  Future<CurrentUser> refreshAccessToken() async {
    return await callPost<CurrentUser>(
      endpoint: '/auth/refresh',
      data: jsonEncode({'refreshToken': await _authTokenService.refreshToken}),
      map: (response) {
        if (response.isSuccess) {
          _authTokenService.setAccessToken(
            accessToken: response.data['accessToken'],
          );
          return UserMapper.toDomainUser(response.data['currentUser']);
        }
        throw AuthApiException(response.errorCode!);
      },
    );
  }
}

class AuthApiException implements Exception {
  final ErrorCode errorCode;
  AuthApiException(String errorCode)
    : errorCode = errorCodeFromString(errorCode);
}
