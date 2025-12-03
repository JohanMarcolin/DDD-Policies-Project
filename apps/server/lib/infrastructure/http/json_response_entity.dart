part of 'response_utils.dart';

/// Base class for standardized JSON HTTP responses.
sealed class JsonResponseEntity {
  static const jsonHeaders = {'Content-Type': 'application/json'};

  static String encodeSuccess([Object? data]) => jsonEncode({'isSuccess': true, 'data': data});

  static String encodeError(ApiErrorCode apiErrorCode) =>
      jsonEncode({'isSuccess': false, 'apiErrorCode': apiErrorCode.toString()});
}

/// Represents a successful `200` OK JSON response.
class JsonResponseOk extends JsonResponseEntity {
  static Response asShelfResponse([Object? body]) => Response.ok(
        JsonResponseEntity.encodeSuccess(body),
        headers: JsonResponseEntity.jsonHeaders,
      );
}

/// Represents a successful `201` Created JSON response.
class JsonResponseCreated extends JsonResponseEntity {
  static Response asShelfResponse([Object? body]) => Response(
        201,
        body: JsonResponseEntity.encodeSuccess(body),
        headers: JsonResponseEntity.jsonHeaders,
      );
}

/// Represents a `204` No Content JSON response.
class JsonResponseNoContent extends JsonResponseEntity {
  static Response asShelfResponse() => Response(204, headers: JsonResponseEntity.jsonHeaders);
}

/// Represents a `204` No Content response for successful deletion.
class JsonResponseDeleted extends JsonResponseEntity {
  static Response asShelfResponse() => JsonResponseNoContent.asShelfResponse();
}

/// Represents a `404` Not Found JSON error response.
class JsonResponseNotFound extends JsonResponseEntity {
  static Response asShelfResponse(ApiErrorCode apiErrorCode) => Response.notFound(
        JsonResponseEntity.encodeError(apiErrorCode),
        headers: JsonResponseEntity.jsonHeaders,
      );
}

/// Represents a `403` Forbidden JSON error response.
class JsonResponseForbidden extends JsonResponseEntity {
  static Response asShelfResponse(ApiErrorCode apiErrorCode) {
    return Response.forbidden(
      JsonResponseEntity.encodeError(apiErrorCode),
      headers: JsonResponseEntity.jsonHeaders,
    );
  }
}

/// Represents a `403` Forbidden response for policy violations.
class JsonResponsePolicyViolation extends JsonResponseEntity {
  static Response asShelfResponse<TPolicyViolationReason>(TPolicyViolationReason policyViolationReason) {
    return Response.forbidden(
      jsonEncode({'isSuccess': false, 'policyViolationReason': policyViolationReason.toString()}),
      headers: JsonResponseEntity.jsonHeaders,
    );
  }
}

/// Represents a `400` Bad Request JSON error response.
class JsonResponseBadRequest extends JsonResponseEntity {
  static Response asShelfResponse(ApiErrorCode apiErrorCode) => Response.badRequest(
        body: JsonResponseEntity.encodeError(apiErrorCode),
        headers: JsonResponseEntity.jsonHeaders,
      );
}

/// Represents a `409` Conflict JSON error response.
class JsonResponseConflict extends JsonResponseEntity {
  static Response asShelfResponse(ApiErrorCode apiErrorCode) => Response(
        409,
        body: JsonResponseEntity.encodeError(apiErrorCode),
        headers: JsonResponseEntity.jsonHeaders,
      );
}

/// Represents a `401` Unauthorized JSON error response.
class JsonResponseUnauthorized extends JsonResponseEntity {
  static Response asShelfResponse(ApiErrorCode apiErrorCode) => Response(
        401,
        body: JsonResponseEntity.encodeError(apiErrorCode),
        headers: JsonResponseEntity.jsonHeaders,
      );
}

/// Represents a `500` Internal Server Error JSON response.
class JsonResponseServerError extends JsonResponseEntity {
  static Response asShelfResponse(ApiErrorCode apiErrorCode) => Response.internalServerError(
        body: JsonResponseEntity.encodeError(apiErrorCode),
        headers: JsonResponseEntity.jsonHeaders,
      );
}
