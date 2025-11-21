part of 'auth_bloc.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  Authenticated({required this.currentUser});

  final User currentUser;
}

class Unauthenticated extends AuthState {
  Unauthenticated([this.errorCode]);

  final ErrorCode? errorCode;
}

class AuthFailure extends AuthState {
  AuthFailure([this.errorCode]);

  final ErrorCode? errorCode;
}
