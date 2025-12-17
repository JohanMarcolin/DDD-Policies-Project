part of 'auth_bloc.dart';

sealed class AuthEvent {}

class AuthLoginRequested extends AuthEvent {
  final Email email;
  final Password password;

  AuthLoginRequested({required this.email, required this.password});
}

class AuthRefreshAccessTokenRequested extends AuthEvent {}

class AuthLogoutRequested extends AuthEvent {}

class AuthRevokeAuthenticationRequested extends AuthEvent {}
