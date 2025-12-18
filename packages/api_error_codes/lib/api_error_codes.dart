part 'api_error_codes/payload.dart';
part 'api_error_codes/login.dart';
part 'api_error_codes/logout.dart';
part 'api_error_codes/user_repository.dart';
part 'api_error_codes/security.dart';
part 'api_error_codes/token.dart';
part 'api_error_codes/server.dart';

/// Base class for all api error codes.
///
/// Extend this class to define specific error code categories for api responses.
sealed class ApiErrorCode {
  @override
  String toString() => runtimeType.toString();
}

/// Converts a string to the corresponding [ApiErrorCode] instance.
///
/// Returns [ServerUnhandledError] if the string does not match any known error code.
ApiErrorCode apiErrorCodeFromString(String? apiErrorCode) {
  switch (apiErrorCode) {
    case 'PayloadMissingRequestBody':
      return PayloadMissingRequestBody();
    case 'PayloadMissingUserId':
      return PayloadMissingUserId();
    case 'PayloadMissingRole':
      return PayloadMissingRole();
    case 'UpdateUserEmailMissingNewEmail':
      return UpdateUserEmailMissingNewEmail();
    case 'UpdateUserEmailInUseBySelf':
      return UpdateUserEmailInUseBySelf();
    case 'UpdateUserEmailInUseByOther':
      return UpdateUserEmailInUseByOther();
    case 'PayloadMissingUserPassword':
      return PayloadMissingUserPassword();
    case 'UpdateUserPasswordMissingNewPassword':
      return UpdateUserPasswordMissingNewPassword();
    case 'LoginMissingEmail':
      return LoginMissingEmail();
    case 'LoginMissingPassword':
      return LoginMissingPassword();
    case 'LoginUserNotFound':
      return LoginUserNotFound();
    case 'LoginInvalidPassword':
      return LoginInvalidPassword();
    case 'TokenRefreshTokenMissing':
      return TokenRefreshTokenMissing();
    case 'TokenRefreshTokenUserNotFound ':
      return TokenRefreshTokenUserNotFound();
    case 'LogoutCouldNotRevokeRefreshToken':
      return LogoutCouldNotRevokeRefreshToken();
    case 'UserRepoUserNotFoundById':
      return UserRepoUserNotFoundById();
    case 'UserRepoFailedToFetchUsers':
      return UserRepoFailedToFetchUsers();
    case 'UserRepoFailedToFetchUser':
      return UserRepoFailedToFetchUser();
    case 'UserRepoUserNotFoundByEmail':
      return UserRepoUserNotFoundByEmail();
    case 'UserRepoFailedToFetchUserByEmail':
      return UserRepoFailedToFetchUserByEmail();
    case 'UserRepoFailedToUpdateEmail':
      return UserRepoFailedToUpdateEmail();
    case 'UserRepoFailedToUpdatePassword':
      return UserRepoFailedToUpdatePassword();
    case 'UserRepoFailedToDeleteUser':
      return UserRepoFailedToDeleteUser();
    case 'UserRepoCouldNotVerifyPassword':
      return UserRepoCouldNotVerifyPassword();
    case 'SecurityMissingAuthenticatedUser':
      return SecurityMissingAuthenticatedUser();
    case 'SecurityMissingAuthorizationHeader':
      return SecurityMissingAuthorizationHeader();
    case 'SecurityMalformedAuthorizationHeader':
      return SecurityMalformedAuthorizationHeader();
    case 'TokenInvalidAccessToken':
      return TokenInvalidAccessToken();
    case 'TokenInvalidRefreshToken':
      return TokenInvalidRefreshToken();
    case 'TokenCouldNotFindStoredRefreshToken':
      return TokenCouldNotFindStoredRefreshToken();
    case 'TokenInvalidUserIdInToken':
      return TokenInvalidUserIdInToken();
    case 'TokenInvalidUserEmailInToken':
      return TokenInvalidUserEmailInToken();
    case 'TokenInvalidUserRoleInToken':
      return TokenInvalidUserRoleInToken();
    case 'ServerUnhandledError':
      return ServerUnhandledError();
    default:
      return ServerUnhandledError();
  }
}

/// Exception type for api errors, wrapping an [ApiErrorCode].
class ApiException implements Exception {
  final ApiErrorCode apiErrorCode;

  /// Constructs an [ApiException] from a string api error code.
  ApiException(String? apiErrorCode) : apiErrorCode = apiErrorCodeFromString(apiErrorCode);
}
