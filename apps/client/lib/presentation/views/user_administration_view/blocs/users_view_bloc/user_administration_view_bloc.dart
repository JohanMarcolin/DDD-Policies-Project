import 'package:api_error_codes/api_error_codes.dart';
import 'package:bloc/bloc.dart';
import 'package:bloc_presentation/bloc_presentation.dart';
import 'package:client/infrastructure/apis/user_api.dart';
import 'package:domain/entities/user.dart';
import 'package:domain/policies/action_authorization_policies/user_administration/user_administration_policy.dart';
import 'package:domain/policies/value_validation_policies/user_credentials/user_credential_policy.dart';
import 'package:domain/services/user_administration/user_administration_service.dart';
import 'package:domain/value_objects/email.dart';
import 'package:domain/value_objects/password.dart';
part 'user_administration_view_event.dart';
part 'user_administration_view_state.dart';

class UserAdministrationViewBloc extends Bloc<UserAdministrationViewEvent, UserAdministrationViewState>
    with BlocPresentationMixin<UserAdministrationViewState, UserAdministrationViewEvent> {
  UserAdministrationViewBloc({required User currentUser, required UserAdministrationService userAdministrationService})
    : _currentUser = currentUser,
      _userAdministrationService = userAdministrationService,
      super(UserAdministrationViewInitial()) {
    on<FetchUsersRequested>(_onFetchRequested);
    on<DeleteUserRequested>(_onDeleteRequested);
    on<UpdateUserEmailRequested>(_onUpdateEmailRequested);
    on<UpdateUserPasswordRequested>(_onUpdatePasswordRequested);
  }

  final User _currentUser;
  final UserAdministrationService _userAdministrationService;

  bool isAdministratingSelf(User targetUser) => _currentUser.isSameAs(targetUser);

  TReturn authorizeDeleteUser<TReturn>(
    User targetUser, {
    required TReturn Function() onAuthorized,
    required TReturn Function(DeleteUserUnauthorizedReason reason) onUnauthorized,
  }) => _userAdministrationService.authorizeDeleteUser(
    initiator: _currentUser,
    target: targetUser,
    onAuthorized: onAuthorized,
    onUnauthorized: (reason) => onUnauthorized(reason),
  );

  TReturn authorizeUpdateEmail<TReturn>(
    User targetUser, {
    required TReturn Function() onAuthorized,
    required TReturn Function(UpdateUserEmailUnauthorizedReason reason) onUnauthorized,
  }) => _userAdministrationService.authorizeUpdateUserEmail(
    initiator: _currentUser,
    target: targetUser,
    onAuthorized: onAuthorized,
    onUnauthorized: (reason) => onUnauthorized(reason),
  );

  TReturn authorizeUpdatePassword<TReturn>(
    User targetUser, {
    required TReturn Function() onAuthorized,
    required TReturn Function(UpdateUserPasswordUnauthorizedReason reason) onUnauthorized,
  }) => _userAdministrationService.authorizeUpdateUserPassword(
    initiator: _currentUser,
    target: targetUser,
    onAuthorized: onAuthorized,
    onUnauthorized: (reason) => onUnauthorized(reason),
  );

  Future<void> _onFetchRequested(FetchUsersRequested event, Emitter<UserAdministrationViewState> emit) async {
    emit(UserAdministrationViewLoading());
    try {
      final users = await _userAdministrationService.viewUsers(initiator: _currentUser);
      emit(UserAdministrationViewLoaded(users));
    } on UserApiException catch (e) {
      emit(UserAdministrationViewFailure(e.apiErrorCode));
    } catch (_) {
      emit(UserAdministrationViewFailure());
    }
  }

  Future<void> _onDeleteRequested(DeleteUserRequested event, Emitter<UserAdministrationViewState> emit) async {
    try {
      final isDeletingSelf = isAdministratingSelf(event.targetUser);
      await _userAdministrationService.deleteUser(initiator: _currentUser, target: event.targetUser);
      if (isDeletingSelf) {
        emitPresentation(DeleteSelfSuccess());
      } else {
        emitPresentation(DeleteUserSuccess());
      }
      add(FetchUsersRequested());
    } on UserApiException catch (e) {
      emitPresentation(DeleteUserFailure(e.apiErrorCode));
    } catch (_) {
      emitPresentation(DeleteUserFailure());
    }
  }

  Future<void> _onUpdateEmailRequested(
    UpdateUserEmailRequested event,
    Emitter<UserAdministrationViewState> emit,
  ) async {
    _userAdministrationService.validateUserEmail(
      event.newEmail,
      onInvalid: (EmailInvalidReason reason) {
        return emitPresentation(UpdateUserEmailInvalid(reason: reason));
      },
      onValid: () async {
        try {
          await _userAdministrationService.updateUserEmail(
            initiator: _currentUser,
            target: event.targetUser,
            newEmail: event.newEmail,
          );
          emitPresentation(UpdateUserEmailSuccess());
          add(FetchUsersRequested());
        } on UserApiException catch (e) {
          emitPresentation(UpdateUserEmailFailure(e.apiErrorCode));
        } catch (_) {
          emitPresentation(UpdateUserEmailFailure());
        }
      },
    );
  }

  Future<void> _onUpdatePasswordRequested(
    UpdateUserPasswordRequested event,
    Emitter<UserAdministrationViewState> emit,
  ) async {
    _userAdministrationService.validateUserPassword(
      event.newPassword,
      onValid: () async {
        try {
          await _userAdministrationService.updateUserPassword(
            initiator: _currentUser,
            target: event.targetUser,
            newPassword: event.newPassword,
          );
          emitPresentation(UpdateUserPasswordSuccess());
          add(FetchUsersRequested());
        } on UserApiException catch (e) {
          emitPresentation(UpdateUserPasswordFailure(e.apiErrorCode));
        } catch (_) {
          emitPresentation(UpdateUserPasswordFailure());
        }
      },
      onInvalid: (PasswordInvalidReason reason) {
        return emitPresentation(UpdateUserPasswordInvalid(reason: reason));
      },
    );
  }
}
