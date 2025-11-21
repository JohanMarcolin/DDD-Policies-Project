part of 'user_administration_view_bloc.dart';

abstract class UserAdministrationViewState {}

class UserAdministrationViewInitial extends UserAdministrationViewState {}

class UserAdministrationViewLoading extends UserAdministrationViewState {}

class UserAdministrationViewLoaded extends UserAdministrationViewState {
  UserAdministrationViewLoaded(this.users);

  final List<User> users;
}

class UserAdministrationViewFailure extends UserAdministrationViewState {}
