import 'dart:convert';
import 'package:client/infrastructure/apis/http_api.dart';
import 'package:client/infrastructure/apis/auth_api.dart';
import 'package:client/infrastructure/mappers/user_mapper.dart';
import 'package:client/infrastructure/services/auth_token_service.dart';
import 'package:domain/entities/user.dart';
import 'package:domain/value_objects/email.dart';
import 'package:domain/value_objects/id.dart';
import 'package:domain/value_objects/password.dart';

class UserApi extends HttpApi {
  UserApi({required this.authApi, required this.authTokenService});

  final AuthApi authApi;
  final AuthTokenService authTokenService;

  Future<List<User>> get users async {
    return await callGet<List<User>>(
      endpoint: '/user/all',
      accessToken: await authTokenService.accessToken,
      refreshAccessToken: _refreshAccessToken,
      map: (response) => UserMapper.toDomainUserList(response.result),
    );
  }

  Future<User?> get({required UserId userId}) async {
    return await callGet<User?>(
      endpoint: '/user/${userId.value}',
      accessToken: await authTokenService.accessToken,
      refreshAccessToken: _refreshAccessToken,
      map: (response) => UserMapper.toDomainUser(response.result),
    );
  }

  Future<void> delete({required UserId userId}) async {
    await callDelete<void>(
      endpoint: '/user/${userId.value}',
      accessToken: await authTokenService.accessToken,
      refreshAccessToken: _refreshAccessToken,
      map: (_) {},
    );
  }

  Future<void> updateEmail({
    required UserId userId,
    required Email newEmail,
  }) async {
    await callPut<void>(
      endpoint: '/user/${userId.value}/email',
      data: jsonEncode({'email': newEmail.value}),
      accessToken: await authTokenService.accessToken,
      refreshAccessToken: _refreshAccessToken,
      map: (_) {},
    );
  }

  Future<void> updatePassword({
    required UserId userId,
    required Password newPassword,
  }) async {
    await callPut<void>(
      endpoint: '/user/${userId.value}/password',
      data: jsonEncode({'password': newPassword.value}),
      accessToken: await authTokenService.accessToken,
      refreshAccessToken: _refreshAccessToken,
      map: (_) {},
    );
  }

  Future<AccessToken?> _refreshAccessToken() async {
    await authApi.refreshAccessToken();
    return await authTokenService.accessToken;
  }
}
