part of 'users_view_bloc.dart';

abstract class UsersViewEvent {}

class UsersFetchRequested extends UsersViewEvent {}

class UserDeleteRequested extends UsersViewEvent {
  final UserId userId;
  UserDeleteRequested({required this.userId});
}

class UserUpdateEmailRequested extends UsersViewEvent {
  final UserId userId;
  final Email newEmail;
  UserUpdateEmailRequested({required this.userId, required this.newEmail});
}

class UserUpdatePasswordRequested extends UsersViewEvent {
  final UserId userId;
  final Password newPassword;
  UserUpdatePasswordRequested({
    required this.userId,
    required this.newPassword,
  });
}
