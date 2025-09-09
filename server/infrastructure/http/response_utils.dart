import 'dart:convert';

import 'package:shelf/shelf.dart';

part 'json_response_entity.dart';

Response ok([Object? body]) => JsonResponseOk.asShelfResponse(body);

Response notFound([Object? body]) => JsonResponseNotFound.asShelfResponse(body);

Response forbidden([Object? body]) =>
    JsonResponseForbidden.asShelfResponse(body);

Response badRequest([Object? body]) =>
    JsonResponseBadRequest.asShelfResponse(body);

Response serverError([Object? body]) =>
    JsonResponseServerError.asShelfResponse(body);
