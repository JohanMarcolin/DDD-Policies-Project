import 'dart:convert';

import 'package:shelf/shelf.dart';

part 'json_response_entity.dart';

Response ok([Object? body]) => JsonResponseOk.asShelfResponse(body);

Response created([Object? body]) => JsonResponseCreated.asShelfResponse(body);

Response deleted([String? message]) => JsonResponseDeleted.asShelfResponse(message);

Response notFound([String? message]) =>
    JsonResponseNotFound.asShelfResponse(message);

Response forbidden([String? message]) =>
    JsonResponseForbidden.asShelfResponse(message);

Response badRequest([String? message]) =>
    JsonResponseBadRequest.asShelfResponse(message);

Response unauthorized([String? message]) =>
    JsonResponseUnauthorized.asShelfResponse(message);

Response serverError([String? message]) =>
    JsonResponseServerError.asShelfResponse(message);
