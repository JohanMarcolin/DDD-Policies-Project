import 'package:bloc/bloc.dart';
import 'package:domain/entities/user.dart';
import 'package:domain/policies/action_policies/action_policy_permission.dart';
import 'package:domain/services/user_administration/user_administration_service.dart';
import 'package:domain/value_objects/email.dart';
import 'package:domain/value_objects/password.dart';
part 'user_administration_view_event.dart';
part 'user_administration_view_state.dart';

class UserAdministrationViewBloc
    extends Bloc<UserAdministrationViewEvent, UserAdministrationViewState> {
  UserAdministrationViewBloc({
    required User currentUser,
    required UserAdministrationService userAdministrationService,
  }) : _currentUser = currentUser,
       _userAdministrationService = userAdministrationService,
       super(UserAdministrationViewInitial()) {
    on<UsersFetchRequested>(_onFetchRequested);
    on<UserDeleteRequested>(_onDeleteRequested);
    on<UserUpdateEmailRequested>(_onUpdateEmailRequested);
    on<UserUpdatePasswordRequested>(_onUpdatePasswordRequested);
  }

  final User _currentUser;
  final UserAdministrationService _userAdministrationService;

  ActionPolicyPermission deleteUserPermission(User targetUser) =>
      _userAdministrationService.deleteUserPolicy.evaluatePermission(
        _currentUser,
        targetUser,
      );

  ActionPolicyPermission updateEmailPermission(User targetUser) =>
      _userAdministrationService.updateUserEmailPolicy.evaluatePermission(
        _currentUser,
        targetUser,
      );

  ActionPolicyPermission updatePasswordPermission(User targetUser) =>
      _userAdministrationService.updateUserPasswordPolicy.evaluatePermission(
        _currentUser,
        targetUser,
      );

  Future<void> _onFetchRequested(
    UsersFetchRequested event,
    Emitter<UserAdministrationViewState> emit,
  ) async {
    emit(UserAdministrationViewLoading());
    try {
      final users = await _userAdministrationService.viewUsers(
        initiator: _currentUser,
      );
      emit(UserAdministrationViewLoaded(users));
    } catch (e) {
      print(e);
      emit(UserAdministrationViewFailure());
    }
  }

  Future<void> _onDeleteRequested(
    UserDeleteRequested event,
    Emitter<UserAdministrationViewState> emit,
  ) async {
    try {
      await _userAdministrationService.deleteUser(
        initiator: _currentUser,
        target: event.targetUser,
      );
    } catch (e) {
      emit(UserAdministrationViewFailure());
    }
  }

  Future<void> _onUpdateEmailRequested(
    UserUpdateEmailRequested event,
    Emitter<UserAdministrationViewState> emit,
  ) async {
    try {
      await _userAdministrationService.updateUserEmail(
        initiator: _currentUser,
        target: event.targetUser,
        newEmail: event.newEmail,
      );
      add(UsersFetchRequested());
    } catch (e) {
      emit(UserAdministrationViewFailure());
    }
  }

  Future<void> _onUpdatePasswordRequested(
    UserUpdatePasswordRequested event,
    Emitter<UserAdministrationViewState> emit,
  ) async {
    try {
      await _userAdministrationService.updateUserPassword(
        initiator: _currentUser,
        target: event.targetUser,
        newPassword: event.newPassword,
      );
      add(UsersFetchRequested());
    } catch (e) {
      emit(UserAdministrationViewFailure());
    }
  }
}
