import 'package:domain/policies/policy_violation_exception.dart';
import 'package:api_error_codes/api_error_codes.dart';
import 'package:shelf/shelf.dart';
import 'response_utils.dart';
import 'exceptions/request_exceptions.dart';

/// Shelf middleware for global exception handling in HTTP requests.
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
          BadRequestException(:final errorCode) => badRequest(errorCode),
          MalformedAuthorizationHeaderException(:final errorCode) => badRequest(errorCode),
          NotFoundException(:final errorCode) => notFound(errorCode),
          ForbiddenException(:final errorCode) => forbidden(errorCode),
          InvalidAccessTokenException(:final errorCode) => unauthorized(errorCode),
          InvalidRefreshTokenException(:final errorCode) => unauthorized(errorCode),
          AuthenticatedUserNotFoundException(:final errorCode) => forbidden(errorCode),
          ServerErrorException(:final errorCode) => serverError(errorCode),
          PolicyViolationException(:final reason) => forbidden(null, reason.toString()),
          _ => serverError(ServerUnhandledServer()),
        };
      }
    };
  };
}
