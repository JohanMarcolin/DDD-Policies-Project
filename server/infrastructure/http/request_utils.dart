import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../../../domain/entities/user.dart';
import '../../../domain/services/user_administration/user_administration_service.dart';
import '../../../domain/value_objects/id.dart';
import '../security/security_filter_chain.dart';
import 'exceptions/request_exceptions.dart';

User getTargetUser(
    Request req, UserAdministrationService userAdministrationService) {
  final id = extractIdFromParams(req);
  final user =
      userAdministrationService.get(requester: req.currentUser, id: id);
  if (user == null) throw const NotFoundException('User not found');
  return user;
}

Future<Map<String, dynamic>> readJsonBody(Request req) async {
  final body = await req.readAsString();
  if (body.isEmpty) {
    throw BadRequestException('Request body cannot be empty');
  }
  try {
    return jsonDecode(body) as Map<String, dynamic>;
  } catch (_) {
    throw BadRequestException('Invalid JSON');
  }
}

Id extractIdFromParams(Request req) {
  final idParam = req.params['id'];

  if (idParam == null || idParam.isEmpty) {
    throw BadRequestException('Missing or empty user ID');
  }

  return Id(idParam);
}
