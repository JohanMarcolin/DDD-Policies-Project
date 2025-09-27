part of 'user_administration_view_bloc.dart';

abstract class UserAdministrationViewEvent {}

class UsersFetchRequested extends UserAdministrationViewEvent {}

class UserDeleteRequested extends UserAdministrationViewEvent {
  final User targetUser;
  UserDeleteRequested({required this.targetUser});
}

class UserUpdateEmailRequested extends UserAdministrationViewEvent {
  final User targetUser;
  final Email newEmail;
  UserUpdateEmailRequested({required this.targetUser, required this.newEmail});
}

class UserUpdateEmailInvalid extends UserAdministrationViewEvent {
  UserUpdateEmailInvalid({required this.reason});
  final EmailInvalidReason reason;
}

class UserUpdateEmailFailure extends UserAdministrationViewEvent {}

class UserUpdateEmailSuccess extends UserAdministrationViewEvent {}

class UserUpdatePasswordRequested extends UserAdministrationViewEvent {
  final User targetUser;
  final Password newPassword;
  UserUpdatePasswordRequested({
    required this.targetUser,
    required this.newPassword,
  });
}

class UserUpdatePasswordInvalid extends UserAdministrationViewEvent {
  UserUpdatePasswordInvalid({required this.reason});
  final PasswordInvalidReason reason;
}
