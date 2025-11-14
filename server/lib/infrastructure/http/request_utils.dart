import 'dart:convert';

import 'package:domain/repositories/user_repository.dart';
import 'package:global_utils/error_codes.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:domain/value_objects/id.dart';

import 'package:domain/entities/user.dart';
import 'exceptions/request_exceptions.dart';

Future<User> getTargetUser(Request req, UserRepository userRepository) async {
  final userId = extractUserIdFromParams(req);
  final user = await userRepository.get(userId: userId);
  if (user == null) {
    throw NotFoundException(RefreshUserNotFound());
  }
  return user;
}

Future<Map<String, dynamic>> readJsonBody(Request req) async {
  final body = await req.readAsString();

  if (body.isEmpty) {
    throw BadRequestException(PayloadMissingRequestBody());
  }

  return jsonDecode(body) as Map<String, dynamic>;
}

UserId extractUserIdFromParams(Request req) {
  final userIdParam = req.params['userId'];

  if (userIdParam == null || userIdParam.isEmpty) {
    throw BadRequestException(PayloadMissingUserId());
  }

  return UserId(userIdParam);
}
