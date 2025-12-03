import 'package:domain/policies/policy_violation_exception.dart';
import 'package:api_error_codes/api_error_codes.dart';
import 'package:shelf/shelf.dart';
import 'response_utils.dart';
import 'exceptions/request_exceptions.dart';

/// Shelf middleware for global exception handling for HTTP requests.
///
/// Catches exceptions thrown by downstream handlers and maps them to appropriate HTTP responses.
/// Handles domain, authentication, and server errors, ensuring consistent error reporting.
Middleware globalExceptionHandler() {
  return (Handler innerHandler) {
    return (Request request) async {
      try {
        return await innerHandler(request);
      } catch (e) {
        print(e);
        // Map known exceptions to HTTP responses; fallback to server error for unknown exceptions.
        return switch (e) {
          BadRequestException(:final apiErrorCode) => badRequest(apiErrorCode),
          MalformedAuthorizationHeaderException(:final apiErrorCode) => badRequest(apiErrorCode),
          NotFoundException(:final apiErrorCode) => notFound(apiErrorCode),
          ForbiddenException(:final apiErrorCode) => forbidden(apiErrorCode),
          PolicyViolationException(:final reason) => policyViolation(reason),
          ConflictException(:final apiErrorCode) => conflict(apiErrorCode),
          InvalidAccessTokenException(:final apiErrorCode) => unauthorized(apiErrorCode),
          InvalidRefreshTokenException(:final apiErrorCode) => unauthorized(apiErrorCode),
          AuthenticatedUserNotFoundException(:final apiErrorCode) => forbidden(apiErrorCode),
          ServerErrorException(:final apiErrorCode) => serverError(apiErrorCode),
          _ => serverError(ServerUnhandledServer()),
        };
      }
    };
  };
}
