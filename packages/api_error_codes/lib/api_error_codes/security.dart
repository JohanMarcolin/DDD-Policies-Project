
part of '../api_error_codes.dart';

/// Represents error codes related to security operations.
sealed class SecurityApiErrorCode extends ApiErrorCode {}

final class SecurityMissingAuthenticatedUser extends SecurityApiErrorCode {}

final class SecurityMissingAuthorizationHeader extends SecurityApiErrorCode {}

final class SecurityMalformedAuthorizationHeader extends SecurityApiErrorCode {}