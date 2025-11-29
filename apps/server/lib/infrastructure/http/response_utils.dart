import 'dart:convert';
import 'package:api_error_codes/api_error_codes.dart';
import 'package:shelf/shelf.dart';

part 'json_response_entity.dart';

Response ok([Object? body]) => JsonResponseOk.asShelfResponse(body);

Response created([Object? body]) => JsonResponseCreated.asShelfResponse(body);

Response noContent() => JsonResponseNoContent.asShelfResponse();

Response deleted() => JsonResponseDeleted.asShelfResponse();

Response notFound(ApiErrorCode apiErrorCode) => JsonResponseNotFound.asShelfResponse(apiErrorCode);

Response forbidden(ApiErrorCode apiErrorCode) => JsonResponseForbidden.asShelfResponse(apiErrorCode);

Response policyViolation<TPolicyViolationReason>(TPolicyViolationReason reason) =>
    JsonResponsePolicyViolation.asShelfResponse(reason);

Response conflict(ApiErrorCode apiErrorCode) => JsonResponseConflict.asShelfResponse(apiErrorCode);

Response badRequest(ApiErrorCode apiErrorCode) => JsonResponseBadRequest.asShelfResponse(apiErrorCode);

Response unauthorized(ApiErrorCode apiErrorCode) => JsonResponseUnauthorized.asShelfResponse(apiErrorCode);

Response serverError(ApiErrorCode apiErrorCode) => JsonResponseServerError.asShelfResponse(apiErrorCode);
