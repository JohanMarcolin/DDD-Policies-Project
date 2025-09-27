part of 'user_administration_view_bloc.dart';

abstract class UserAdministrationViewEvent {}

sealed class FetchUsersEvent extends UserAdministrationViewEvent {}

class FetchUsersRequested extends FetchUsersEvent {}

class FetchUsersSuccess extends FetchUsersEvent {}

class FetchUsersFailure extends FetchUsersEvent {}

sealed class DeleteUserEvent extends UserAdministrationViewEvent {}

class DeleteUserRequested extends DeleteUserEvent {
  final User targetUser;
  DeleteUserRequested({required this.targetUser});
}

class DeleteUserSuccess extends DeleteUserEvent {}

class DeleteUserFailure extends DeleteUserEvent {}

sealed class UpdateUserEmailEvent extends UserAdministrationViewEvent {}

class UpdateUserEmailRequested extends UpdateUserEmailEvent {
  final User targetUser;
  final Email newEmail;
  UpdateUserEmailRequested({required this.targetUser, required this.newEmail});
}

class UpdateUserEmailInvalid extends UpdateUserEmailEvent {
  UpdateUserEmailInvalid({required this.reason});
  final EmailInvalidReason reason;
}

class UpdateUserEmailFailure extends UpdateUserEmailEvent {}

class UpdateUserEmailSuccess extends UpdateUserEmailEvent {}

sealed class UpdateUserPasswordEvent extends UserAdministrationViewEvent {}

class UpdateUserPasswordRequested extends UpdateUserPasswordEvent {
  final User targetUser;
  final Password newPassword;
  UpdateUserPasswordRequested({
    required this.targetUser,
    required this.newPassword,
  });
}

class UpdateUserPasswordInvalid extends UpdateUserPasswordEvent {
  UpdateUserPasswordInvalid({required this.reason});
  final PasswordInvalidReason reason;
}

class UpdateUserPasswordSuccess extends UpdateUserPasswordEvent {}

class UpdateUserPasswordFailure extends UpdateUserPasswordEvent {}
