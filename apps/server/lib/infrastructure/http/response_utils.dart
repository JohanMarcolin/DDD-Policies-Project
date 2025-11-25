import 'dart:convert';
import 'package:api_error_codes/api_error_codes.dart';
import 'package:shelf/shelf.dart';

part 'json_response_entity.dart';

Response ok([Object? body]) => JsonResponseOk.asShelfResponse(body);

Response created([Object? body]) => JsonResponseCreated.asShelfResponse(body);

Response noContent() => JsonResponseNoContent.asShelfResponse();

Response deleted() => JsonResponseDeleted.asShelfResponse();

Response notFound(ApiErrorCode errorCode) => JsonResponseNotFound.asShelfResponse(errorCode);

Response forbidden([ApiErrorCode? errorCode, String? policyViolationDetails]) =>
    JsonResponseForbidden.asShelfResponse(errorCode, policyViolationDetails);

Response badRequest(ApiErrorCode errorCode) => JsonResponseBadRequest.asShelfResponse(errorCode);

Response unauthorized(ApiErrorCode errorCode) => JsonResponseUnauthorized.asShelfResponse(errorCode);

Response serverError(ApiErrorCode errorCode) => JsonResponseServerError.asShelfResponse(errorCode);
