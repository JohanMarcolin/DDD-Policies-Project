part of '../api_error_codes.dart';

/// Represents error codes related to login operations.
sealed class LoginApiErrorCode extends ApiErrorCode {}

final class LoginMissingEmail extends LoginApiErrorCode {}

final class LoginMissingPassword extends LoginApiErrorCode {}

final class LoginUserNotFound extends LoginApiErrorCode {}

final class LoginInvalidPassword extends LoginApiErrorCode {}
