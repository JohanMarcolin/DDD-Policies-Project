import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../infrastructure/user_repository.dart';
part 'users_view_event.dart';
part 'users_view_state.dart';

class UsersViewBloc extends Bloc<UsersViewEvent, UsersViewState> {
  final UserRepository userRepository;
  final String accessToken;

  UsersViewBloc({required this.userRepository, required this.accessToken})
    : super(UsersViewInitial()) {
    on<UsersFetchRequested>(_onFetchRequested);
    on<UserRemoveRequested>(_onRemoveRequested);
    on<UserUpdateEmailRequested>(_onUpdateEmailRequested);
    on<UserUpdatePasswordRequested>(_onUpdatePasswordRequested);
  }

  Future<void> _onFetchRequested(
    UsersFetchRequested event,
    Emitter<UsersViewState> emit,
  ) async {
    emit(UsersViewLoading());
    try {
      final users = await userRepository.listUsers(accessToken);
      emit(UsersViewLoaded(users));
    } catch (e) {
      emit(UsersViewFailure(e.toString()));
    }
  }

  Future<void> _onRemoveRequested(
    UserRemoveRequested event,
    Emitter<UsersViewState> emit,
  ) async {
    try {
      await userRepository.removeUser(accessToken, event.userId);
      add(UsersFetchRequested());
    } catch (e) {
      emit(UsersViewFailure(e.toString()));
    }
  }

  Future<void> _onUpdateEmailRequested(
    UserUpdateEmailRequested event,
    Emitter<UsersViewState> emit,
  ) async {
    try {
      await userRepository.updateEmail(
        accessToken,
        event.userId,
        event.newEmail,
      );
      add(UsersFetchRequested());
    } catch (e) {
      emit(UsersViewFailure(e.toString()));
    }
  }

  Future<void> _onUpdatePasswordRequested(
    UserUpdatePasswordRequested event,
    Emitter<UsersViewState> emit,
  ) async {
    try {
      await userRepository.updatePassword(
        accessToken,
        event.userId,
        event.newPassword,
      );
      add(UsersFetchRequested());
    } catch (e) {
      emit(UsersViewFailure(e.toString()));
    }
  }
}
