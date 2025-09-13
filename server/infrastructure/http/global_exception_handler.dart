import 'package:shelf/shelf.dart';
import '../../../domain/policies/policy.dart';
import '../../../domain/value_objects/email.dart';
import '../../../domain/value_objects/password.dart';
import '../http/response_utils.dart';
import '../http/exceptions/request_exceptions.dart';

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
          InvalidAccessTokenException(:final message) => forbidden(message),
          InvalidRefreshTokenException(:final message) => forbidden(message),
          AuthenticatedUserNotFoundException(:final message) =>
            forbidden(message),
          ServerErrorException(:final message) => serverError(message),
          PolicyPermissionDeniedException(:final reason) => forbidden(reason),
          EmailValidationErrorException(:final reason) => forbidden(reason),
          PasswordValidationErrorException(:final reason) => forbidden(reason),
          _ => serverError('An unexpected error occurred'),
        };
      }
    };
  };
}
