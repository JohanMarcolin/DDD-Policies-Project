/// Base class for all API error codes.
///
/// Extend this class to define specific error code categories for API responses.
sealed class ApiErrorCode {
  /// Returns the string representation of the error code type.
  @override
  String toString() => runtimeType.toString();
}

sealed class PayloadApiErrorCode extends ApiErrorCode {}

final class PayloadMissingRequestBody extends PayloadApiErrorCode {}

final class PayloadMissingUserId extends PayloadApiErrorCode {}

final class PayloadMissingRole extends PayloadApiErrorCode {}

final class UpdateUserEmailMissingNewEmail extends PayloadApiErrorCode {}

final class UpdateUserEmailInUseBySelf extends PayloadApiErrorCode {}

final class UpdateUserEmailInUseByOther extends PayloadApiErrorCode {}

final class PayloadMissingUserPassword extends PayloadApiErrorCode {}

final class UpdateUserPasswordMissingNewPassword extends PayloadApiErrorCode {}

sealed class LoginApiErrorCode extends ApiErrorCode {}

final class LoginMissingEmail extends LoginApiErrorCode {}

final class LoginMissingPassword extends LoginApiErrorCode {}

final class LoginUserNotFound extends LoginApiErrorCode {}

final class LoginInvalidPassword extends LoginApiErrorCode {}

sealed class RefreshApiErrorCode extends ApiErrorCode {}

final class RefreshMissingRefreshToken extends RefreshApiErrorCode {}

final class RefreshUserNotFound extends RefreshApiErrorCode {}

sealed class LogoutApiErrorCode extends ApiErrorCode {}

final class LogoutMissingRefreshToken extends LogoutApiErrorCode {}

final class LogoutMissingUser extends LogoutApiErrorCode {}

final class LogoutCouldNotRevokeRefreshToken extends LogoutApiErrorCode {}

sealed class UserRepoApiErrorCode extends ApiErrorCode {}

final class UserRepoUserNotFoundById extends UserRepoApiErrorCode {}

final class UserRepoFailedToFetchUsers extends UserRepoApiErrorCode {}

final class UserRepoFailedToFetchUser extends UserRepoApiErrorCode {}

final class UserRepoUserNotFoundByEmail extends UserRepoApiErrorCode {}

final class UserRepoFailedToFetchUserByEmail extends UserRepoApiErrorCode {}

final class UserRepoFailedToUpdateEmail extends UserRepoApiErrorCode {}

final class UserRepoFailedToUpdatePassword extends UserRepoApiErrorCode {}

final class UserRepoFailedToDeleteUser extends UserRepoApiErrorCode {}

final class UserRepoCouldNotVerifyPassword extends UserRepoApiErrorCode {}

sealed class SecurityApiErrorCode extends ApiErrorCode {}

final class SecurityMissingAuthenticatedUser extends SecurityApiErrorCode {}

final class SecurityMissingAuthorizationHeader extends SecurityApiErrorCode {}

final class SecurityMalformedAuthorizationHeader extends SecurityApiErrorCode {}

sealed class TokenApiErrorCode extends ApiErrorCode {}

final class TokenInvalidAccessToken extends TokenApiErrorCode {}

final class TokenInvalidRefreshToken extends TokenApiErrorCode {}

final class TokenCouldNotFindStoredRefreshToken extends TokenApiErrorCode {}

final class TokenInvalidUserIdInToken extends TokenApiErrorCode {}

final class TokenInvalidUserEmailInToken extends TokenApiErrorCode {}

final class TokenInvalidUserRoleInToken extends TokenApiErrorCode {}

sealed class ServerApiErrorCode extends ApiErrorCode {}

final class ServerUnhandledServer extends ServerApiErrorCode {}

/// Converts a string to the corresponding [ApiErrorCode] instance.
///
/// Returns [ServerUnhandledServer] if the string does not match any known error code.
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
    case 'RefreshMissingRefreshToken':
      return RefreshMissingRefreshToken();
    case 'RefreshUserNotFound':
      return RefreshUserNotFound();
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
    case 'ServerUnhandledServer':
      return ServerUnhandledServer();
    default:
      return ServerUnhandledServer();
  }
}

/// Exception type for API errors, wrapping an [ApiErrorCode].
class ApiException implements Exception {
  final ApiErrorCode apiErrorCode;

  /// Constructs an [ApiException] from a string api error code.
  ApiException(String? apiErrorCode) : apiErrorCode = apiErrorCodeFromString(apiErrorCode);
}
