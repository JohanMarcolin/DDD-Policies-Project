import 'package:shelf/shelf.dart';
import '../../../domain/policies/policy_violation_exception.dart';
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
          NotFoundException(:final message) => notFound(message),
          ForbiddenException(:final message) => forbidden(message),
          ServerErrorException(:final message) => serverError(message),
          PolicyViolationException(:final reason) => forbidden(reason),
          _ => serverError('An unexpected error occurred'),
        };
      }
    };
  };
}
