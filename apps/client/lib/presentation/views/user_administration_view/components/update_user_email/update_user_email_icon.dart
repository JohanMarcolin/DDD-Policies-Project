part of '../../user_administration_view.dart';

class UpdateUserEmailIcon extends StatelessWidget {
  const UpdateUserEmailIcon({super.key, required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<UserAdministrationViewBloc>();
    final updateEmail = bloc.authorizeUpdateEmail(user);
    final isUserUpdatingSelf = bloc.isAdministratingSelf(user);

    return UserActionIcon<UpdateUserEmailUnauthorizedReason>(
      icon: Icons.email,
      isActionAuthorized: updateEmail is Authorized,
      dialogChildBuilder: (context, {required closeDialog}) => UpdateUserEmailDialogChild(
        isUserUpdatingSelf: isUserUpdatingSelf,
        onCancel: () async => await closeDialog(context),
        onConfirm: (value) {
          bloc.add(UpdateUserEmailRequested(targetUser: user, newEmail: Email(value)));
        },
      ),
      closeDialogOnEvent: (event) => event is UpdateUserEmailSuccess,
      eventMessageMapper: (event) => switch (event) {
        UpdateUserEmailInvalid() => 'Invalid email format',
        UpdateUserEmailFailure(:var apiErrorCode) => switch (apiErrorCode) {
          UpdateUserEmailTakenBySelf() => 'This is your current email',
          UpdateUserEmailTakenByOther() => 'This email is already taken',
          _ => 'Failed to update email',
        },
        UpdateUserEmailSuccess() => 'Email updated successfully',
        _ => '',
      },
      unauthorizedReason: updateEmail is Unauthorized ? updateEmail.reason as UpdateUserEmailUnauthorizedReason : null,
      unauthorizedMessageMapper: (reason) => switch (reason) {
        CannotUpdateEmailOnAnalyst() => 'You cannot update the email of an analyst.',
        CanOnlyUpdateEmailOnSelf() => 'You can only update your own email.',
      },
    );
  }
}
