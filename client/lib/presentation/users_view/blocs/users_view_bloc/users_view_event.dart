part of 'users_view_bloc.dart';

abstract class UsersViewEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class UsersFetchRequested extends UsersViewEvent {}

class UserRemoveRequested extends UsersViewEvent {
  final String userId;
  UserRemoveRequested(this.userId);

  @override
  List<Object?> get props => [userId];
}

class UserUpdateEmailRequested extends UsersViewEvent {
  final String userId;
  final String newEmail;
  UserUpdateEmailRequested(this.userId, this.newEmail);

  @override
  List<Object?> get props => [userId, newEmail];
}

class UserUpdatePasswordRequested extends UsersViewEvent {
  final String userId;
  final String newPassword;
  UserUpdatePasswordRequested(this.userId, this.newPassword);

  @override
  List<Object?> get props => [userId, newPassword];
}
