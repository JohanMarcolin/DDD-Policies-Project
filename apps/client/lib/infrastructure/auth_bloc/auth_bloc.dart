import 'package:bloc/bloc.dart';
import 'package:client/infrastructure/apis/auth_api.dart';
import 'package:domain/entities/user.dart';
import 'package:domain/value_objects/email.dart';
import 'package:domain/value_objects/password.dart';
import 'package:api_error_codes/api_error_codes.dart';
part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({required AuthApi authApi}) : _authApi = authApi, super(AuthInitial()) {
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthRefreshAccessTokenRequested>(_onRefreshAccessTokenRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthRevokeAuthenticationRequested>(_onRevokeAuthentication);
  }

  final AuthApi _authApi;

  Future<void> _onLoginRequested(AuthLoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final currentUser = await _authApi.login(email: event.email, password: event.password);
      emit(Authenticated(currentUser: currentUser));
    } on AuthApiException catch (e) {
      emit(Unauthenticated(e.apiErrorCode));
    } catch (e) {
      emit(AuthFailure());
    }
  }

  Future<void> _onRefreshAccessTokenRequested(AuthRefreshAccessTokenRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final currentUser = await _authApi.refreshAccessToken();
      emit(Authenticated(currentUser: currentUser));
    } on AuthApiException catch (e) {
      emit(Unauthenticated(e.apiErrorCode));
    } catch (_) {
      emit(AuthFailure());
    }
  }

  Future<void> _onLogoutRequested(AuthLogoutRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _authApi.logout();
      emit(Unauthenticated());
    } on AuthApiException catch (e) {
      emit(AuthFailure(e.apiErrorCode));
    } catch (_) {
      emit(AuthFailure());
    }
  }

  Future<void> _onRevokeAuthentication(AuthRevokeAuthenticationRequested event, Emitter<AuthState> emit) async {
    emit(Unauthenticated());
  }
}
