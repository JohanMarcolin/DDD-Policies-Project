import 'dart:convert';

import 'package:error_codes/error_codes.dart';
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
  final user = await userAdministrationService.viewUser(
      initiator: req.currentUser, userId: userId);
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
