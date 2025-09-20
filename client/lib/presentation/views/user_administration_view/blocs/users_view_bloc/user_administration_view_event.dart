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

class UserUpdatePasswordRequested extends UserAdministrationViewEvent {
  final User targetUser;
  final Password newPassword;
  UserUpdatePasswordRequested({
    required this.targetUser,
    required this.newPassword,
  });
}
