import 'package:domain/policies/policy_violation_exception.dart';
import 'package:api_error_codes/api_error_codes.dart';
import 'package:shelf/shelf.dart';
import '../utils/response/response.dart';

part 'exceptions/request_exceptions.dart';

/// Shelf middleware for global exception handling of http requests.
///
/// Catches exceptions thrown by downstream handlers and maps them to http responses.
Middleware globalExceptionHandler() {
  return (Handler innerHandler) {
    return (Request request) async {
      try {
        return await innerHandler(request);
      } catch (e) {
        // Map known exceptions to http responses; fallback to server unhandled error for unknown exceptions.
        return switch (e) {
          AuthenticatedUserNotFoundException(:final apiErrorCode) => forbidden(apiErrorCode),
          BadRequestException(:final apiErrorCode) => badRequest(apiErrorCode),
          ConflictException(:final apiErrorCode) => conflict(apiErrorCode),
          ForbiddenException(:final apiErrorCode) => forbidden(apiErrorCode),
          InvalidAccessTokenException(:final apiErrorCode) => unauthorized(apiErrorCode),
          InvalidRefreshTokenException(:final apiErrorCode) => unauthorized(apiErrorCode),
          MalformedAuthorizationHeaderException(:final apiErrorCode) => badRequest(apiErrorCode),
          NotFoundException(:final apiErrorCode) => notFound(apiErrorCode),
          PolicyViolationException(:final reason) => policyViolation(reason),
          ServerErrorException(:final apiErrorCode) => serverError(apiErrorCode),
          _ => serverError(ServerUnhandledError()),
        };
      }
    };
  };
}
