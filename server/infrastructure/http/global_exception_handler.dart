import 'package:shelf/shelf.dart';
import '../../../domain/policies/policy_violation_exception.dart';
import '../http/response_utils.dart';
import '../http/exceptions/request_exceptions.dart';

Middleware globalExceptionHandler() {
  return (Handler innerHandler) {
    return (Request request) async {
      try {
        return await innerHandler(request);
      } catch (e, s) {
        // Debug: print type and message
        print('Caught exception: \\${e.runtimeType} - \\${e}');
        if (e is BadRequestException) return badRequest(e.message);
        if (e is NotFoundException) return notFound(e.message);
        if (e is ForbiddenException) return forbidden(e.message);
        if (e is ServerErrorException) return serverError(e.message);
        if (e is PolicyViolationException) return forbidden(e.reason);
        // Fallback for unknown errors
        return serverError('An unexpected error occurred: \\${e.toString()}');
      }
    };
  };
}
