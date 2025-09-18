import 'dart:convert';

import 'package:shelf/shelf.dart';

part 'json_response_entity.dart';

Response ok([Object? body]) => JsonResponseOk.asShelfResponse(body);

Response created([Object? body]) => JsonResponseCreated.asShelfResponse(body);

Response deleted([Object? body]) => JsonResponseDeleted.asShelfResponse(body);

Response notFound([String? message]) =>
    JsonResponseNotFound.asShelfResponse(message);

Response forbidden([Object? object]) =>
    JsonResponseForbidden.asShelfResponse(object);

Response badRequest([String? message]) =>
    JsonResponseBadRequest.asShelfResponse(message);

Response unauthorized([Object? message]) =>
    JsonResponseUnauthorized.asShelfResponse(message);

Response serverError([String? message]) =>
    JsonResponseServerError.asShelfResponse(message);
