import 'dart:convert';
import 'package:client/infrastructure/apis/auth_api.dart';
import 'package:client/infrastructure/services/auth_token_service.dart';
import 'package:domain/entities/user.dart';
import 'package:domain/value_objects/email.dart';
import 'package:domain/value_objects/id.dart';
import 'package:domain/value_objects/password.dart';
import 'package:global_utils/error_codes.dart';
import 'package:global_utils/mappers/user_mapper.dart';
import 'package:global_utils/http_api/http_api.dart';

/// API for user administration operations.
class UserApi extends HttpApi {
  UserApi({required this.authApi, required this.authTokenService});

  final AuthApi authApi;
  final AuthTokenService authTokenService;

  /// Retrieves all users from the backend.
  ///
  /// Returns a list of [User] objects. Throws [UserApiException].
  Future<List<User>> get users async {
    return await callGet<List<User>>(
      endpoint: '/user/all',
      accessToken: await authTokenService.accessToken,
      refreshAccessToken: _refreshAccessToken,
      map: (response) {
        if (response.isSuccess) {
          return UserMapper.toDomainUserList(response.data);
        }
        throw UserApiException(response.errorCode);
      },
    );
  }

  /// Retrieves a user by [userId].
  ///
  /// Returns a [User] object if found, or null if not found. Throws [UserApiException].
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
        throw UserApiException(response.errorCode);
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
        throw UserApiException(response.errorCode);
      },
    );
  }

  /// Updates the email address for the user with [userId].
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
        throw UserApiException(response.errorCode);
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
        throw UserApiException(response.errorCode);
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

class UserApiException implements Exception {
  final ErrorCode errorCode;

  UserApiException(String? errorCode) : errorCode = errorCodeFromString(errorCode);
}
