import 'dart:convert';

import 'package:error_codes/error_codes.dart';
import 'package:shelf/shelf.dart';

part 'json_response_entity.dart';

Response ok([Object? body]) => JsonResponseOk.asShelfResponse(body);

Response created([Object? body]) => JsonResponseCreated.asShelfResponse(body);

Response deleted() => JsonResponseDeleted.asShelfResponse();

Response notFound(ErrorCode errorCode) =>
    JsonResponseNotFound.asShelfResponse(errorCode);

Response forbidden([ErrorCode? errorCode, String? policyViolationDetails]) =>
    JsonResponseForbidden.asShelfResponse(errorCode, policyViolationDetails);

Response badRequest(ErrorCode errorCode) =>
    JsonResponseBadRequest.asShelfResponse(errorCode);

Response unauthorized(ErrorCode errorCode) =>
    JsonResponseUnauthorized.asShelfResponse(errorCode);

Response serverError(ErrorCode errorCode) =>
    JsonResponseServerError.asShelfResponse(errorCode);
