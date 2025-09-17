part of 'users_view_bloc.dart';

abstract class UsersViewState extends Equatable {
  @override
  List<Object?> get props => [];
}

class UsersViewInitial extends UsersViewState {}

class UsersViewLoading extends UsersViewState {}

class UsersViewLoaded extends UsersViewState {
  final List<User> users;
  UsersViewLoaded(this.users);

  @override
  List<Object?> get props => [users];
}

class UsersViewFailure extends UsersViewState {
  final String message;
  UsersViewFailure(this.message);

  @override
  List<Object?> get props => [message];
}
