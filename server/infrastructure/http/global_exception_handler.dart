import 'package:shelf/shelf.dart';
import 'package:domain/policies/policy_exception.dart';
import 'response_utils.dart';
import 'exceptions/request_exceptions.dart';

Middleware globalExceptionHandler() {
  return (Handler innerHandler) {
    return (Request request) async {
      try {
        return await innerHandler(request);
      } catch (e) {
        return switch (e) {
          BadRequestException(:final message) => badRequest(message),
          MalformedAuthorizationHeaderException(:final message) =>
            badRequest(message),
          NotFoundException(:final message) => notFound(message),
          ForbiddenException(:final message) => forbidden(message),
          InvalidAccessTokenException(:final message) => unauthorized(message),
          InvalidRefreshTokenException(:final message) => unauthorized(message),
          AuthenticatedUserNotFoundException(:final message) =>
            forbidden(message),
          ServerErrorException(:final message) => serverError(message),
          PolicyException(:final reason) => forbidden(reason),
          _ => serverError('An unexpected error occurred'),
        };
      }
    };
  };
}
