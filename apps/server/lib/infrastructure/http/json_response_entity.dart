part of 'response_utils.dart';

sealed class JsonResponseEntity {
  static const jsonHeaders = {'Content-Type': 'application/json'};
}

class JsonResponseOk extends JsonResponseEntity {
  static Response asShelfResponse([Object? body]) => Response.ok(
        jsonEncode({'isSuccess': true, 'data': body}),
        headers: JsonResponseEntity.jsonHeaders,
      );
}

class JsonResponseCreated extends JsonResponseEntity {
  static Response asShelfResponse([Object? body]) => Response(
        201,
        body: jsonEncode({'isSuccess': true, 'data': body}),
        headers: JsonResponseEntity.jsonHeaders,
      );
}

class JsonResponseNoContent extends JsonResponseEntity {
  static Response asShelfResponse() => Response(204, headers: JsonResponseEntity.jsonHeaders);
}

class JsonResponseDeleted extends JsonResponseEntity {
  static Response asShelfResponse() => JsonResponseNoContent.asShelfResponse();
}

class JsonResponseNotFound extends JsonResponseEntity {
  static Response asShelfResponse(ApiErrorCode apiErrorCode) => Response.notFound(
        jsonEncode({'isSuccess': false, 'apiErrorCode': apiErrorCode.toString()}),
        headers: JsonResponseEntity.jsonHeaders,
      );
}

class JsonResponseForbidden extends JsonResponseEntity {
  static Response asShelfResponse([ApiErrorCode? apiErrorCode, String? policyViolationDetails]) {
    final body = <String, Object>{'isSuccess': false};

    if (apiErrorCode != null) body['apiErrorCode'] = apiErrorCode.toString();

    if (policyViolationDetails != null) {
      body['policyViolationDetails'] = policyViolationDetails;
    }
    return Response.forbidden(
      jsonEncode(body),
      headers: JsonResponseEntity.jsonHeaders,
    );
  }
}

class JsonResponseBadRequest extends JsonResponseEntity {
  static Response asShelfResponse(ApiErrorCode apiErrorCode) => Response.badRequest(
        body: jsonEncode({'isSuccess': false, 'apiErrorCode': apiErrorCode.toString()}),
        headers: JsonResponseEntity.jsonHeaders,
      );
}

class JsonResponseUnauthorized extends JsonResponseEntity {
  static Response asShelfResponse(ApiErrorCode apiErrorCode) => Response(
        401,
        body: jsonEncode({'isSuccess': false, 'apiErrorCode': apiErrorCode.toString()}),
        headers: JsonResponseEntity.jsonHeaders,
      );
}

class JsonResponseServerError extends JsonResponseEntity {
  static Response asShelfResponse(ApiErrorCode apiErrorCode) => Response.internalServerError(
        body: jsonEncode({'isSuccess': false, 'apiErrorCode': apiErrorCode.toString()}),
        headers: JsonResponseEntity.jsonHeaders,
      );
}
