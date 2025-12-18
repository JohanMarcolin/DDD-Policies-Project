import 'dart:convert';
import 'package:client/infrastructure/apis/auth_api.dart';
import 'package:client/infrastructure/services/auth_token_service.dart';
import 'package:domain/entities/user.dart';
import 'package:domain/value_objects/email.dart';
import 'package:domain/value_objects/id.dart';
import 'package:domain/value_objects/password.dart';
import 'package:api_error_codes/api_error_codes.dart';
import 'package:mappers/user_mapper.dart';
import 'package:http_api/http_api/http_api.dart';

/// Api for user operations.
class UserApi extends HttpApi {
  UserApi({required this.authApi, required this.authTokenService});

  final AuthApi authApi;
  final AuthTokenService authTokenService;

  /// Retrieves all users from the server.
  ///
  /// Returns a list of [User]:s.
  ///
  /// Throws [UserApiException].
  Future<List<User>> get users async {
    return await callGet<List<User>>(
      endpoint: '/user/all',
      accessToken: await authTokenService.accessToken,
      refreshAccessToken: _refreshAccessToken,
      map: (response) {
        if (response.isSuccess) {
          return UserMapper.toDomainUserList(response.data);
        }
        throw UserApiException(response.apiErrorCode);
      },
    );
  }

  /// Retrieves a user by [userId].
  ///
  /// Returns a [User] if found, otherwise `null`.
  ///
  /// Throws [UserApiException].
  Future<User?> get({required UserId userId}) async {
    return await callGet<User?>(
      endpoint: '/user/${userId.value}',
      accessToken: await authTokenService.accessToken,
      refreshAccessToken: _refreshAccessToken,
      map: (response) {
        if (response.isSuccess) {
          if (response.data == null) {
            return null;
          }
          return UserMapper.toDomainUser(response.data);
        }
        throw UserApiException(response.apiErrorCode);
      },
    );
  }

  /// Deletes the user with [userId].
  ///
  /// Throws [UserApiException].
  Future<void> delete({required UserId userId}) async {
    await callDelete<void>(
      endpoint: '/user/${userId.value}',
      accessToken: await authTokenService.accessToken,
      refreshAccessToken: _refreshAccessToken,
      map: (response) {
        if (response.isSuccess) {
          return;
        }
        throw UserApiException(response.apiErrorCode);
      },
    );
  }

  /// Updates the email for the user with [userId].
  ///
  /// Throws [UserApiException].
  Future<void> updateEmail({required UserId userId, required Email newEmail}) async {
    await callPut<void>(
      endpoint: '/user/${userId.value}/email',
      data: jsonEncode({'newEmail': newEmail.value}),
      accessToken: await authTokenService.accessToken,
      refreshAccessToken: _refreshAccessToken,
      map: (response) {
        if (response.isSuccess) {
          return;
        }
        throw UserApiException(response.apiErrorCode);
      },
    );
  }

  /// Updates the password for the user with [userId].
  ///
  /// Throws [UserApiException].
  Future<void> updatePassword({required UserId userId, required Password newPassword}) async {
    await callPut<void>(
      endpoint: '/user/${userId.value}/password',
      data: jsonEncode({'newPassword': newPassword.value}),
      accessToken: await authTokenService.accessToken,
      refreshAccessToken: _refreshAccessToken,
      map: (response) {
        if (response.isSuccess) {
          return;
        }
        throw UserApiException(response.apiErrorCode);
      },
    );
  }

  /// Refreshes the access token using [authApi].
  ///
  /// Returns the new [AccessToken] if successful.
  Future<AccessToken?> _refreshAccessToken() async {
    await authApi.refreshAccessToken();
    return await authTokenService.accessToken;
  }
}

class UserApiException extends ApiException {
  UserApiException(super.apiErrorCode);
}
