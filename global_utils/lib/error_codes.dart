sealed class ErrorCode {
  @override
  String toString() => runtimeType.toString();
}

sealed class PayloadErrorCode extends ErrorCode {}

final class PayloadMissingRequestBody extends PayloadErrorCode {}

final class PayloadMissingUserId extends PayloadErrorCode {}

final class PayloadMissingRole extends PayloadErrorCode {}

final class UpdateUserEmailMissingNewEmail extends PayloadErrorCode {}

final class PayloadMissingUserPassword extends PayloadErrorCode {}

final class UpdateUserPasswordMissingNewPassword extends PayloadErrorCode {}

sealed class LoginErrorCode extends ErrorCode {}

final class LoginMissingEmail extends LoginErrorCode {}

final class LoginMissingPassword extends LoginErrorCode {}

final class LoginUserNotFound extends LoginErrorCode {}

final class LoginInvalidPassword extends LoginErrorCode {}

sealed class RefreshErrorCode extends ErrorCode {}

final class RefreshMissingRefreshToken extends RefreshErrorCode {}

final class RefreshUserNotFound extends RefreshErrorCode {}

sealed class LogoutErrorCode extends ErrorCode {}

final class LogoutMissingRefreshToken extends LogoutErrorCode {}

final class LogoutMissingUser extends LogoutErrorCode {}

final class LogoutCouldNotRevokeRefreshToken extends LogoutErrorCode {}

sealed class UserRepoErrorCode extends ErrorCode {}

final class UserRepoUserNotFoundById extends UserRepoErrorCode {}

final class UserRepoFailedToFetchUsers extends UserRepoErrorCode {}

final class UserRepoFailedToFetchUser extends UserRepoErrorCode {}

final class UserRepoUserNotFoundByEmail extends UserRepoErrorCode {}

final class UserRepoFailedToFetchUserByEmail extends UserRepoErrorCode {}

final class UserRepoFailedToUpdateEmail extends UserRepoErrorCode {}

final class UserRepoFailedToUpdatePassword extends UserRepoErrorCode {}

final class UserRepoFailedToDeleteUser extends UserRepoErrorCode {}

final class UserRepoCouldNotVerifyPassword extends UserRepoErrorCode {}

sealed class SecurityErrorCode extends ErrorCode {}

final class SecurityMissingAuthenticatedUser extends SecurityErrorCode {}

final class SecurityMissingAuthorizationHeader extends SecurityErrorCode {}

final class SecurityMalformedAuthorizationHeader extends SecurityErrorCode {}

sealed class TokenErrorCode extends ErrorCode {}

final class TokenInvalidAccessToken extends TokenErrorCode {}

final class TokenInvalidRefreshToken extends TokenErrorCode {}

final class TokenCouldNotFindStoredRefreshToken extends TokenErrorCode {}

final class TokenInvalidUserIdInToken extends TokenErrorCode {}

final class TokenInvalidUserEmailInToken extends TokenErrorCode {}

final class TokenInvalidUserRoleInToken extends TokenErrorCode {}

sealed class ServerErrorCode extends ErrorCode {}

final class ServerUnhandledServer extends ServerErrorCode {}

ErrorCode errorCodeFromString(String? errorCode) {
  switch (errorCode) {
    case 'PayloadMissingRequestBody':
      return PayloadMissingRequestBody();
    case 'PayloadMissingUserId':
      return PayloadMissingUserId();
    case 'PayloadMissingRole':
      return PayloadMissingRole();
    case 'UpdateUserEmailMissingNewEmail':
      return UpdateUserEmailMissingNewEmail();
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
