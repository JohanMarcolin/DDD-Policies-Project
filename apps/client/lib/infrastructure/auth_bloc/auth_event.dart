part of 'auth_bloc.dart';

abstract class AuthEvent {}

class AuthLoginRequested extends AuthEvent {
  final Email email;
  final Password password;

  AuthLoginRequested({required this.email, required this.password});
}

class AuthRefreshRequested extends AuthEvent {}

class AuthLogoutRequested extends AuthEvent {}

class AuthRevokeAuthentication extends AuthEvent {}
