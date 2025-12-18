part of '../api_error_codes.dart';

/// Represents error codes related to logout operations.
sealed class LogoutApiErrorCode extends ApiErrorCode {}

final class LogoutTokenRefreshTokenMissing extends LogoutApiErrorCode {}

final class LogoutMissingUser extends LogoutApiErrorCode {}

final class LogoutCouldNotRevokeRefreshToken extends LogoutApiErrorCode {}
