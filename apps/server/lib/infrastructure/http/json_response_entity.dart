part of 'response_utils.dart';

sealed class JsonResponseEntity {
  static const jsonHeaders = {'Content-Type': 'application/json'};

  /// Encodes a standard error response with [apiErrorCode].
  static String encodeError(ApiErrorCode apiErrorCode) =>
      jsonEncode({'isSuccess': false, 'apiErrorCode': apiErrorCode.toString()});
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
        JsonResponseEntity.encodeError(apiErrorCode),
        headers: JsonResponseEntity.jsonHeaders,
      );
}

class JsonResponseForbidden extends JsonResponseEntity {
  static Response asShelfResponse(ApiErrorCode apiErrorCode) {
    return Response.forbidden(
      JsonResponseEntity.encodeError(apiErrorCode),
      headers: JsonResponseEntity.jsonHeaders,
    );
  }
}

class JsonResponsePolicyViolation extends JsonResponseEntity {
  static Response asShelfResponse<TPolicyViolationReason>(TPolicyViolationReason policyViolationReason) {
    return Response.forbidden(
      jsonEncode({'isSuccess': false, 'policyViolationReason': policyViolationReason.toString()}),
      headers: JsonResponseEntity.jsonHeaders,
    );
  }
}

class JsonResponseBadRequest extends JsonResponseEntity {
  static Response asShelfResponse(ApiErrorCode apiErrorCode) => Response.badRequest(
        body: JsonResponseEntity.encodeError(apiErrorCode),
        headers: JsonResponseEntity.jsonHeaders,
      );
}

class JsonResponseConflict extends JsonResponseEntity {
  static Response asShelfResponse(ApiErrorCode apiErrorCode) => Response(
        409,
        body: JsonResponseEntity.encodeError(apiErrorCode),
        headers: JsonResponseEntity.jsonHeaders,
      );
}

class JsonResponseUnauthorized extends JsonResponseEntity {
  static Response asShelfResponse(ApiErrorCode apiErrorCode) => Response(
        401,
        body: JsonResponseEntity.encodeError(apiErrorCode),
        headers: JsonResponseEntity.jsonHeaders,
      );
}

class JsonResponseServerError extends JsonResponseEntity {
  static Response asShelfResponse(ApiErrorCode apiErrorCode) => Response.internalServerError(
        body: JsonResponseEntity.encodeError(apiErrorCode),
        headers: JsonResponseEntity.jsonHeaders,
      );
}
