part of 'auth_bloc.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  Authenticated({required this.currentUser});

  final User currentUser;
}

class Unauthenticated extends AuthState {}

class AuthFailure extends AuthState {}
