part of 'response_utils.dart';

sealed class JsonResponseEntity {
  static const jsonHeaders = {'Content-Type': 'application/json'};
}

class JsonResponseOk extends JsonResponseEntity {
  static Response asShelfResponse([Object? body]) => Response.ok(
        jsonEncode({'success': true, 'result': body}),
        headers: JsonResponseEntity.jsonHeaders,
      );
}

class JsonResponseCreated extends JsonResponseEntity {
  static Response asShelfResponse([Object? body]) => Response(201,
        body: jsonEncode({'success': true, 'result': body}),
        headers: JsonResponseEntity.jsonHeaders,
      );
}

class JsonResponseDeleted extends JsonResponseEntity {
  static Response asShelfResponse([Object? message]) => Response.ok(
        jsonEncode({'success': true, 'details': message ?? 'Deleted'}),
        headers: JsonResponseEntity.jsonHeaders,
      );
}

class JsonResponseNotFound extends JsonResponseEntity {
  static Response asShelfResponse([String? message]) => Response.notFound(
        jsonEncode({'success': false, 'details': message ?? 'Not Found'}),
        headers: JsonResponseEntity.jsonHeaders,
      );
}

class JsonResponseForbidden extends JsonResponseEntity {
  static Response asShelfResponse([Object? object]) => Response.forbidden(
        jsonEncode({'success': false, 'details': object ?? 'Forbidden'}),
        headers: JsonResponseEntity.jsonHeaders,
      );
}

class JsonResponseBadRequest extends JsonResponseEntity {
  static Response asShelfResponse([String? message]) => Response.badRequest(
        body:
            jsonEncode({'success': false, 'details': message ?? 'Bad Request'}),
        headers: JsonResponseEntity.jsonHeaders,
      );
}

class JsonResponseServerError extends JsonResponseEntity {
  static Response asShelfResponse([String? message]) =>
      Response.internalServerError(
        body: jsonEncode(
            {'success': false, 'details': message ?? 'Internal Server Error'}),
        headers: JsonResponseEntity.jsonHeaders,
      );
}
