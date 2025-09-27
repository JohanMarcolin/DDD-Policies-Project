import 'package:bloc/bloc.dart';
import 'package:bloc_presentation/bloc_presentation.dart';
import 'package:domain/entities/user.dart';
import 'package:domain/policies/action_policies/action_policy_permission.dart';
import 'package:domain/policies/validation_policies/validation_policy.dart';
import 'package:domain/policies/validation_policies/validation_policy_result.dart';
import 'package:domain/services/user_administration/user_administration_service.dart';
import 'package:domain/value_objects/email.dart';
import 'package:domain/value_objects/password.dart';
part 'user_administration_view_event.dart';
part 'user_administration_view_state.dart';

class UserAdministrationViewBloc
    extends Bloc<UserAdministrationViewEvent, UserAdministrationViewState>
    with
        BlocPresentationMixin<
          UserAdministrationViewState,
          UserAdministrationViewEvent
        > {
  UserAdministrationViewBloc({
    required User currentUser,
    required UserAdministrationService userAdministrationService,
  }) : _currentUser = currentUser,
       _userAdministrationService = userAdministrationService,
       super(UserAdministrationViewInitial()) {
    on<FetchUsersRequested>(_onFetchRequested);
    on<DeleteUserRequested>(_onDeleteRequested);
    on<UpdateUserEmailRequested>(_onUpdateEmailRequested);
    on<UpdateUserPasswordRequested>(_onUpdatePasswordRequested);
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

  ValidationPolicyResult _emailValidationResult(Email email) =>
      _userAdministrationService.emailValidationPolicy.evaluateValidity(email);

  ValidationPolicyResult _passwordValidationResult(Password password) =>
      _userAdministrationService.passwordValidationPolicy.evaluateValidity(
        password,
      );

  Future<void> _onFetchRequested(
    FetchUsersRequested event,
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
    DeleteUserRequested event,
    Emitter<UserAdministrationViewState> emit,
  ) async {
    try {
      await _userAdministrationService.deleteUser(
        initiator: _currentUser,
        target: event.targetUser,
      );
      emitPresentation(DeleteUserSuccess());
      add(FetchUsersRequested());
    } catch (e) {
      emitPresentation(DeleteUserFailure());
    }
  }

  Future<void> _onUpdateEmailRequested(
    UpdateUserEmailRequested event,
    Emitter<UserAdministrationViewState> emit,
  ) async {
    final validationResult = _emailValidationResult(event.newEmail);
    if (validationResult is Invalid) {
      emitPresentation(UpdateUserEmailInvalid(reason: validationResult.reason));
      return;
    }
    try {
      await _userAdministrationService.updateUserEmail(
        initiator: _currentUser,
        target: event.targetUser,
        newEmail: event.newEmail,
      );
      emitPresentation(UpdateUserEmailSuccess());
      add(FetchUsersRequested());
    } catch (e) {
      emitPresentation(UpdateUserEmailFailure());
    }
  }

  Future<void> _onUpdatePasswordRequested(
    UpdateUserPasswordRequested event,
    Emitter<UserAdministrationViewState> emit,
  ) async {
    final validationResult = _passwordValidationResult(event.newPassword);
    if (validationResult is Invalid) {
      emitPresentation(
        UpdateUserPasswordInvalid(reason: validationResult.reason),
      );
      return;
    }
    try {
      await _userAdministrationService.updateUserPassword(
        initiator: _currentUser,
        target: event.targetUser,
        newPassword: event.newPassword,
      );
      emitPresentation(UpdateUserPasswordSuccess());
      add(FetchUsersRequested());
    } catch (e) {
      emitPresentation(UpdateUserPasswordFailure());
    }
  }
}
