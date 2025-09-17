import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:domain/value_objects/id.dart';

import 'package:domain/entities/user.dart';
import 'package:domain/services/user_administration/user_administration_service.dart';
import '../security/security_filter_chain.dart';
import 'exceptions/request_exceptions.dart';

Future<User> getTargetUser(
    Request req, UserAdministrationService userAdministrationService) async {
  final userId = extractUserIdFromParams(req);
  final user = await userAdministrationService.get(
      initiator: req.currentUser, userId: userId);
  if (user == null) throw const NotFoundException('User not found');
  return user;
}

Future<Map<String, dynamic>> readJsonBody(Request req) async {
  final body = await req.readAsString();

  if (body.isEmpty) {
    throw BadRequestException('Request body cannot be empty');
  }

  return jsonDecode(body) as Map<String, dynamic>;
}

UserId extractUserIdFromParams(Request req) {
  final userIdParam = req.params['userId'];

  if (userIdParam == null || userIdParam.isEmpty) {
    throw BadRequestException('Missing or empty user ID');
  }

  return UserId(userIdParam);
}
