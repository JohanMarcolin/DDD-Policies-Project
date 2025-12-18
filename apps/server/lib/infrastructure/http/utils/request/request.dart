import 'dart:convert';

import 'package:domain/repositories/user_repository.dart';
import 'package:api_error_codes/api_error_codes.dart';
import 'package:server/infrastructure/http/global_exception_handler/global_exception_handler.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:domain/value_objects/id.dart';

import 'package:domain/entities/user.dart';

/// Retrieves the target [User] from the request using the [UserId].
///
/// Throws [NotFoundException] if the user does not exist.
Future<User> getTargetUser(Request req, UserRepository userRepository) async {
  final userId = extractUserIdFromParams(req);
  final user = await userRepository.get(userId: userId);
  if (user == null) {
    throw NotFoundException(TokenRefreshTokenUserNotFound());
  }
  return user;
}

/// Reads and decodes the JSON body from a [Request].
///
/// Throws [BadRequestException] if the body is empty or missing.
Future<Map<String, dynamic>> readJsonBody(Request req) async {
  final body = await req.readAsString();

  if (body.isEmpty) {
    throw BadRequestException(PayloadMissingRequestBody());
  }

  return jsonDecode(body) as Map<String, dynamic>;
}

/// Extracts the [UserId] from request parameters.
///
/// Throws [BadRequestException] if the param is missing or empty.
UserId extractUserIdFromParams(Request req) {
  final userIdParam = req.params['userId'];

  if (userIdParam == null || userIdParam.isEmpty) {
    throw BadRequestException(PayloadMissingUserId());
  }

  return UserId(userIdParam);
}
