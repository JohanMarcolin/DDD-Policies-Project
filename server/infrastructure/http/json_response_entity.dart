part of 'response_utils.dart';

sealed class JsonResponseEntity {
  static const jsonHeaders = {'Content-Type': 'application/json'};
}

class JsonResponseOk extends JsonResponseEntity {
  static Response asShelfResponse([Object? body]) => Response.ok(
        jsonEncode(body ?? {'success': true}),
        headers: JsonResponseEntity.jsonHeaders,
      );
}

class JsonResponseNotFound extends JsonResponseEntity {
  static Response asShelfResponse([Object? body]) => Response.notFound(
        jsonEncode(body ?? {'success': false, 'message': 'Not Found'}),
        headers: JsonResponseEntity.jsonHeaders,
      );
}

class JsonResponseForbidden extends JsonResponseEntity {
  static Response asShelfResponse([Object? body]) => Response.forbidden(
        jsonEncode(body ?? {'success': false, 'message': 'Forbidden'}),
        headers: JsonResponseEntity.jsonHeaders,
      );
}

class JsonResponseBadRequest extends JsonResponseEntity {
  static Response asShelfResponse([Object? body]) => Response.badRequest(
        body: jsonEncode(body ?? {'success': false, 'message': 'Bad Request'}),
        headers: JsonResponseEntity.jsonHeaders,
      );
}

class JsonResponseServerError extends JsonResponseEntity {
  static Response asShelfResponse([Object? body]) =>
      Response.internalServerError(
        body: jsonEncode(
            body ?? {'success': false, 'message': 'Internal Server Error'}),
        headers: JsonResponseEntity.jsonHeaders,
      );
}
