import 'package:domain/policies/policy_violation_exception.dart';
import 'package:error_codes/error_codes.dart';
import 'package:shelf/shelf.dart';
import 'response_utils.dart';
import 'exceptions/request_exceptions.dart';

Middleware globalExceptionHandler() {
  return (Handler innerHandler) {
    return (Request request) async {
      try {
        return await innerHandler(request);
      } catch (e) {
        print(e);
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
