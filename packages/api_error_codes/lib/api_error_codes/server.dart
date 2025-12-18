part of '../api_error_codes.dart';

/// Represents error codes related to server operations.
sealed class ServerApiErrorCode extends ApiErrorCode {}

final class ServerUnhandledError extends ServerApiErrorCode {}
