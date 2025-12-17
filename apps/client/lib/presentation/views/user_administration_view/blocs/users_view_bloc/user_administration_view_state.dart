part of 'user_administration_view_bloc.dart';

sealed class UserAdministrationViewState {}

class UserAdministrationViewInitial extends UserAdministrationViewState {}

class UserAdministrationViewLoading extends UserAdministrationViewState {}

class UserAdministrationViewLoaded extends UserAdministrationViewState {
  UserAdministrationViewLoaded(this.users);

  final List<User> users;
}

class UserAdministrationViewFailure extends UserAdministrationViewState {
  UserAdministrationViewFailure([this.apiErrorCode]);

  final ApiErrorCode? apiErrorCode;
}
