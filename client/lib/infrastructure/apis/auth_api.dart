import 'dart:convert';
import 'package:client/infrastructure/apis/http_api.dart';
import 'package:client/infrastructure/mappers/user_mapper.dart';
import 'package:client/infrastructure/services/auth_token_service.dart';
import 'package:domain/entities/user.dart';
import 'package:domain/value_objects/email.dart';
import 'package:domain/value_objects/password.dart';

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
        _authTokenService.saveTokens(
          accessToken: response.result['accessToken'],
          refreshToken: response.result['refreshToken'],
        );
        return UserMapper.toDomainUser(response.result['currentUser']);
      },
    );
  }

  Future<void> logout() async {
    final refreshToken = await _authTokenService.refreshToken;

    await callDelete<void>(
      endpoint: '/auth/logout/$refreshToken',
      accessToken: await _authTokenService.accessToken,
      map: (_) {},
    );
    
    await _authTokenService.clearTokens();
  }

  Future<CurrentUser> refreshAccessToken() async {
    final hasRefreshToken = await _authTokenService.hasRefreshToken;
    if (!hasRefreshToken) {
      throw Exception('No refresh token found');
    }
    return await callPost<CurrentUser>(
      endpoint: '/auth/refresh',
      data: jsonEncode({'refreshToken': await _authTokenService.refreshToken}),
      map: (response) {
        _authTokenService.setAccessToken(
          accessToken: response.result['accessToken'],
        );
        return UserMapper.toDomainUser(response.result['currentUser']);
      },
    );
  }
}
