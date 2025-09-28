import 'package:bloc/bloc.dart';
import 'package:client/infrastructure/apis/auth_api.dart';
import 'package:domain/entities/user.dart';
import 'package:domain/value_objects/email.dart';
import 'package:domain/value_objects/password.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({required AuthApi authApi})
    : _authApi = authApi,
      super(AuthInitial()) {
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthRefreshRequested>(_onRefreshRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
  }

  final AuthApi _authApi;

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final currentUser = await _authApi.login(
        email: event.email,
        password: event.password,
      );
      emit(Authenticated(currentUser: currentUser));
    } catch (e) {
      emit(Unauthenticated());
    }
  }

  Future<void> _onRefreshRequested(
    AuthRefreshRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final currentUser = await _authApi.refreshAccessToken();
      if (currentUser == null) {
        emit(Unauthenticated());
        return;
      }
      emit(Authenticated(currentUser: currentUser));
    } catch (e) {
      emit(Unauthenticated());
    }
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _authApi.logout();
      emit(Unauthenticated());
    } catch (e) {
      emit(AuthFailure());
    }
  }
}
