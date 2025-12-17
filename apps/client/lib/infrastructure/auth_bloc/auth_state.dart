part of 'auth_bloc.dart';

sealed class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  Authenticated({required this.currentUser});

  final User currentUser;
}

class Unauthenticated extends AuthState {
  Unauthenticated([this.apiErrorCode]);

  final ApiErrorCode? apiErrorCode;
}

class AuthFailure extends AuthState {
  AuthFailure([this.apiErrorCode]);

  final ApiErrorCode? apiErrorCode;
}
