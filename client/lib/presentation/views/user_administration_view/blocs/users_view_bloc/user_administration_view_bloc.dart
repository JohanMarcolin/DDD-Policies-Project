import 'package:bloc/bloc.dart';
import 'package:bloc_presentation/bloc_presentation.dart';
import 'package:domain/entities/user.dart';
import 'package:domain/policies/action_policies/action_policy.dart';
import 'package:domain/policies/validation_policies/validation_policy.dart';
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
    required this.userAdministrationService,
  }) : _currentUser = currentUser,
       super(UserAdministrationViewInitial()) {
    on<FetchUsersRequested>(_onFetchRequested);
    on<DeleteUserRequested>(_onDeleteRequested);
    on<UpdateUserEmailRequested>(_onUpdateEmailRequested);
    on<UpdateUserPasswordRequested>(_onUpdatePasswordRequested);
  }

  final User _currentUser;
  final UserAdministrationService userAdministrationService;

  bool isAdministratingSelf(User targetUser) =>
      _currentUser.isSameAs(targetUser);

  ActionPolicyResult authorizeDeleteUser(User targetUser) =>
      userAdministrationService.deleteUserPolicy.authorize(
        _currentUser,
        targetUser,
      );

  ActionPolicyResult authorizeUpdateEmail(User targetUser) =>
      userAdministrationService.updateUserEmailPolicy.authorize(
        _currentUser,
        targetUser,
      );

  ActionPolicyResult authorizeUpdatePassword(User targetUser) =>
      userAdministrationService.updateUserPasswordPolicy.authorize(
        _currentUser,
        targetUser,
      );

  ValidationPolicyResult validateEmail(Email email) =>
      userAdministrationService.emailValidationPolicy.validate(email);

  ValidationPolicyResult validatePassword(Password password) =>
      userAdministrationService.passwordValidationPolicy.validate(password);

  Future<void> _onFetchRequested(
    FetchUsersRequested event,
    Emitter<UserAdministrationViewState> emit,
  ) async {
    emit(UserAdministrationViewLoading());
    try {
      final users = await userAdministrationService.viewUsers(
        initiator: _currentUser,
      );
      emit(UserAdministrationViewLoaded(users));
    } catch (e) {
      emit(UserAdministrationViewFailure());
    }
  }

  Future<void> _onDeleteRequested(
    DeleteUserRequested event,
    Emitter<UserAdministrationViewState> emit,
  ) async {
    try {
      final isDeletingSelf = isAdministratingSelf(event.targetUser);
      await userAdministrationService.deleteUser(
        initiator: _currentUser,
        target: event.targetUser,
      );
      if (isDeletingSelf) {
        emitPresentation(DeleteSelfSuccess());
      } else {
        emitPresentation(DeleteUserSuccess());
      }
      add(FetchUsersRequested());
    } catch (e) {
      emitPresentation(DeleteUserFailure());
    }
  }

  Future<void> _onUpdateEmailRequested(
    UpdateUserEmailRequested event,
    Emitter<UserAdministrationViewState> emit,
  ) async {
    switch (validateEmail(event.newEmail)) {
      case Invalid(:final reason as EmailInvalidReason):
        emitPresentation(UpdateUserEmailInvalid(reason: reason));
        return;
      case Valid():
        try {
          await userAdministrationService.updateUserEmail(
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
  }

  Future<void> _onUpdatePasswordRequested(
    UpdateUserPasswordRequested event,
    Emitter<UserAdministrationViewState> emit,
  ) async {
    switch (validatePassword(event.newPassword)) {
      case Invalid(:final reason as PasswordInvalidReason):
        emitPresentation(UpdateUserPasswordInvalid(reason: reason));
        return;
      case Valid():
        try {
          await userAdministrationService.updateUserPassword(
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
}
