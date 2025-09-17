part of 'users_view_bloc.dart';

abstract class UsersViewState {}

class UsersViewInitial extends UsersViewState {}

class UsersViewLoading extends UsersViewState {}

class UsersViewLoaded extends UsersViewState {
  UsersViewLoaded(this.users);

  final List<User> users;
}

class UsersViewFailure extends UsersViewState {}
