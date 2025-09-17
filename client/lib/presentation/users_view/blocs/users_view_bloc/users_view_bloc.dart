import 'package:bloc/bloc.dart';
import 'package:domain/entities/user.dart';
import 'package:domain/repositories/user_repository.dart';
import 'package:domain/value_objects/email.dart';
import 'package:domain/value_objects/id.dart';
import 'package:domain/value_objects/password.dart';
part 'users_view_event.dart';
part 'users_view_state.dart';

class UsersViewBloc extends Bloc<UsersViewEvent, UsersViewState> {
  UsersViewBloc({required UserRepository userRepository})
    : _userRepository = userRepository,
      super(UsersViewInitial()) {
    on<UsersFetchRequested>(_onFetchRequested);
    on<UserDeleteRequested>(_onDeleteRequested);
    on<UserUpdateEmailRequested>(_onUpdateEmailRequested);
    on<UserUpdatePasswordRequested>(_onUpdatePasswordRequested);
  }

  final UserRepository _userRepository;

  Future<void> _onFetchRequested(
    UsersFetchRequested event,
    Emitter<UsersViewState> emit,
  ) async {
    emit(UsersViewLoading());
    try {
      final users = await _userRepository.users;
      emit(UsersViewLoaded(users));
    } catch (e) {
      emit(UsersViewFailure());
    }
  }

  Future<void> _onDeleteRequested(
    UserDeleteRequested event,
    Emitter<UsersViewState> emit,
  ) async {
    try {
      await _userRepository.delete(userId: event.userId);
    } catch (e) {
      emit(UsersViewFailure());
    }
  }

  Future<void> _onUpdateEmailRequested(
    UserUpdateEmailRequested event,
    Emitter<UsersViewState> emit,
  ) async {
    try {
      await _userRepository.updateEmail(
        userId: event.userId,
        newEmail: event.newEmail,
      );
      add(UsersFetchRequested());
    } catch (e) {
      emit(UsersViewFailure());
    }
  }

  Future<void> _onUpdatePasswordRequested(
    UserUpdatePasswordRequested event,
    Emitter<UsersViewState> emit,
  ) async {
    try {
      await _userRepository.updatePassword(
        userId: event.userId,
        newPassword: event.newPassword,
      );
      add(UsersFetchRequested());
    } catch (e) {
      emit(UsersViewFailure());
    }
  }
}
