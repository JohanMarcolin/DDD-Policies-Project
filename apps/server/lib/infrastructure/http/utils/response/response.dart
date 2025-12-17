import 'dart:convert';
import 'package:api_error_codes/api_error_codes.dart';
import 'package:shelf/shelf.dart';

part 'json_response_entity.dart';

/// Returns a `200` OK response with optional [body] as JSON.
Response ok([Object? body]) => JsonResponseOk.asShelfResponse(body);

/// Returns a `201` Created response with optional [body] as JSON.
Response created([Object? body]) => JsonResponseCreated.asShelfResponse(body);

/// Returns a `204` No Content response.
Response noContent() => JsonResponseNoContent.asShelfResponse();

/// Returns a `204` No Content response for a deleted resource.
Response deleted() => JsonResponseDeleted.asShelfResponse();

/// Returns a `404` Not Found response with [apiErrorCode] as error JSON.
Response notFound(ApiErrorCode apiErrorCode) => JsonResponseNotFound.asShelfResponse(apiErrorCode);

/// Returns a `403` Forbidden response with [apiErrorCode] as error JSON.
Response forbidden(ApiErrorCode apiErrorCode) => JsonResponseForbidden.asShelfResponse(apiErrorCode);

/// Returns a `403` Forbidden response with [policyViolationReason] as error JSON.
Response policyViolation<TPolicyViolationReason>(TPolicyViolationReason policyViolationReason) =>
    JsonResponsePolicyViolation.asShelfResponse(policyViolationReason);

/// Returns a `409` Conflict response with [apiErrorCode] as error JSON.
Response conflict(ApiErrorCode apiErrorCode) => JsonResponseConflict.asShelfResponse(apiErrorCode);

/// Returns a `400` Bad Request response with [apiErrorCode] as error JSON.
Response badRequest(ApiErrorCode apiErrorCode) => JsonResponseBadRequest.asShelfResponse(apiErrorCode);

/// Returns a `401` Unauthorized response with [apiErrorCode] as error JSON.
Response unauthorized(ApiErrorCode apiErrorCode) => JsonResponseUnauthorized.asShelfResponse(apiErrorCode);

/// Returns a `500` Internal Server Error response with [apiErrorCode] as error JSON.
Response serverError(ApiErrorCode apiErrorCode) => JsonResponseServerError.asShelfResponse(apiErrorCode);
