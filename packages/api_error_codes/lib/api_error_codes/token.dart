part of '../api_error_codes.dart';

/// Represents error codes related to token operations.
sealed class TokenApiErrorCode extends ApiErrorCode {}

final class TokenInvalidAccessToken extends TokenApiErrorCode {}

final class TokenInvalidRefreshToken extends TokenApiErrorCode {}

final class TokenRefreshTokenMissing extends TokenApiErrorCode {}

final class TokenCouldNotFindStoredRefreshToken extends TokenApiErrorCode {}

final class TokenRefreshTokenUserNotFound extends TokenApiErrorCode {}

final class TokenInvalidUserIdInToken extends TokenApiErrorCode {}

final class TokenInvalidUserEmailInToken extends TokenApiErrorCode {}

final class TokenInvalidUserRoleInToken extends TokenApiErrorCode {}
