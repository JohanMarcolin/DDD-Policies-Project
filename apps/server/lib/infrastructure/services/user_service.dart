import 'package:domain/repositories/user_repository.dart';
import 'package:api_error_codes/api_error_codes.dart';
import 'package:mappers/user_mapper.dart';
import 'package:server/infrastructure/http/global_exception_handler/global_exception_handler.dart';
import 'package:shelf/shelf.dart';
import 'package:domain/services/user_administration/user_administration_service.dart';
import 'package:domain/value_objects/email.dart';
import 'package:domain/value_objects/password.dart';
import 'package:server/infrastructure/http/utils/request/request.dart';
import 'package:server/infrastructure/http/utils/response/response.dart';
import 'package:server/infrastructure/security/security_filter_chain.dart';

/// Service for handling user-related operations.
class UserService {
  UserService({required UserRepository userRepository, required UserAdministrationService userAdministrationService})
      : _userRepository = userRepository,
        _userAdministrationService = userAdministrationService;

  final UserRepository _userRepository;
  final UserAdministrationService _userAdministrationService;

  /// Retrieves all users visible to the current user.
  ///
  /// Returns [ok] with a list of user JSON objects.
  Future<Response> getAllUsers(Request req) async {
    final users = await _userAdministrationService.viewUsers(initiator: req.currentUser);
    return ok(UserMapper.toJsonList(users));
  }

  /// Retrieves a user by [UserId], if authorized.
  ///
  /// Returns [ok] with the user JSON object.
  /// Throws [NotFoundException] if the [User] does not exist, or if the current user is not authorized to view it.
  Future<Response> getUserById(Request req) async {
    final userId = extractUserIdFromParams(req);

    final user = await _userAdministrationService.viewUser(initiator: req.currentUser, userId: userId);

    if (user == null) {
      throw NotFoundException(RefreshUserNotFound());
    }

    return ok(UserMapper.toJson(user));
  }

  /// Deletes the target [User], if authorized.
  ///
  /// Returns [ok].
  Future<Response> deleteUser(Request req) async {
    final targetUser = await getTargetUser(req, _userRepository);

    await _userAdministrationService.deleteUser(
      initiator: req.currentUser,
      target: targetUser,
    );

    return ok();
  }

  /// Updates the [Email] for the target [User], if authorized.
  ///
  /// Returns [ok].
  /// Throws [BadRequestException] if the new email is missing or invalid, or [ConflictException] if the new email is already in use.
  Future<Response> updateEmail(Request req) async {
    final targetUser = await getTargetUser(req, _userRepository);

    final body = await readJsonBody(req);
    final newEmail = body['newEmail'] as String?;

    if (newEmail == null || newEmail.isEmpty) {
      throw BadRequestException(UpdateUserEmailMissingNewEmail());
    }

    final email = Email(newEmail);

    final isUpdatingSelf = req.currentUser.isSameAs(targetUser);

    final isEmailInUseBySelf = isUpdatingSelf && targetUser.email == email;

    if (isEmailInUseBySelf) {
      throw ConflictException(UpdateUserEmailInUseBySelf());
    }

    final isEmailInUseByOther = await _userRepository.getByEmail(email: email) != null;

    if (isEmailInUseByOther) {
      throw ConflictException(UpdateUserEmailInUseByOther());
    }

    await _userAdministrationService.updateUserEmail(initiator: req.currentUser, target: targetUser, newEmail: email);

    return ok();
  }

  /// Updates the [Password] for the target [User], if authorized.
  ///
  /// Returns [ok].
  /// Throws [BadRequestException] if the new password is missing or invalid.
  Future<Response> updatePassword(Request req) async {
    final targetUser = await getTargetUser(req, _userRepository);

    final body = await readJsonBody(req);

    final newPassword = body['newPassword'] as String?;

    if (newPassword == null || newPassword.isEmpty) {
      throw BadRequestException(UpdateUserPasswordMissingNewPassword());
    }

    await _userAdministrationService.updateUserPassword(
        initiator: req.currentUser, target: targetUser, newPassword: Password(newPassword));

    return ok();
  }
}
