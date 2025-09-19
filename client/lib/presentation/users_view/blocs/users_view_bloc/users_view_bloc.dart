import 'package:bloc/bloc.dart';
import 'package:domain/entities/user.dart';
import 'package:domain/services/user_administration/user_administration_service.dart';
import 'package:domain/value_objects/email.dart';
import 'package:domain/value_objects/id.dart';
import 'package:domain/value_objects/password.dart';
part 'users_view_event.dart';
part 'users_view_state.dart';

class UsersViewBloc extends Bloc<UsersViewEvent, UsersViewState> {
  UsersViewBloc({
    required User currentUser,
    required UserAdministrationService userAdministrationService,
  }) : _currentUser = currentUser,
       _userAdministrationService = userAdministrationService,
       super(UsersViewInitial()) {
    on<UsersFetchRequested>(_onFetchRequested);
    on<UserDeleteRequested>(_onDeleteRequested);
    on<UserUpdateEmailRequested>(_onUpdateEmailRequested);
    on<UserUpdatePasswordRequested>(_onUpdatePasswordRequested);
  }

  final User _currentUser;
  final UserAdministrationService _userAdministrationService;

  Future<void> _onFetchRequested(
    UsersFetchRequested event,
    Emitter<UsersViewState> emit,
  ) async {
    emit(UsersViewLoading());
    try {
      final users = await _userAdministrationService.getUsers(
        initiator: _currentUser,
      );
      emit(UsersViewLoaded(users));
    } catch (e) {
      print(e);
      emit(UsersViewFailure());
    }
  }

  Future<void> _onDeleteRequested(
    UserDeleteRequested event,
    Emitter<UsersViewState> emit,
  ) async {
    try {
      await _userAdministrationService.deleteUser(
        initiator: _currentUser,
        userId: event.userId,
      );
    } catch (e) {
      emit(UsersViewFailure());
    }
  }

  Future<void> _onUpdateEmailRequested(
    UserUpdateEmailRequested event,
    Emitter<UsersViewState> emit,
  ) async {
    try {
      await _userAdministrationService.updateUserEmail(
        initiator: _currentUser,
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
      await _userAdministrationService.updateUserPassword(
        initiator: _currentUser,
        userId: event.userId,
        newPassword: event.newPassword,
      );
      add(UsersFetchRequested());
    } catch (e) {
      emit(UsersViewFailure());
    }
  }
}
