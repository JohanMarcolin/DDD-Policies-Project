part of '../../user_administration_view.dart';

class DeleteUserIcon extends StatelessWidget {
  const DeleteUserIcon({super.key, required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<UserAdministrationViewBloc>();
    final deleteUser = bloc.authorizeDeleteUser(user);

    return BlocPresentationListener<
      UserAdministrationViewBloc,
      UserAdministrationViewEvent
    >(
      listener: (_, event) async {
        if (event is DeleteSelfSuccess) {
          context.read<AuthBloc>().add(AuthRevokeAuthentication());
        }
      },
      child: UserActionIcon<DeleteUserUnauthorizedReason>(
        icon: Icons.delete,
        isActionAuthorized: deleteUser is Authorized,
        dialogChildBuilder: (context, {required closeDialog}) =>
            DeleteUserDialogChild(
              isUserDeletingSelf: bloc.isAdministratingSelf(user),
              onCancel: () async => await closeDialog(context),
              onConfirm: () {
                bloc.add(DeleteUserRequested(targetUser: user));
              },
            ),
        closeDialogOnEvent: (event) =>
            event is DeleteUserSuccess || event is DeleteSelfSuccess,
        eventMessageMapper: (event) => switch (event) {
          DeleteUserFailure() => 'Failed to delete user',
          DeleteUserSuccess() => 'User deleted successfully',
          DeleteSelfSuccess() => 'You have deleted your account',
          _ => '',
        },
        unauthorizedReason: deleteUser is Unauthorized
            ? deleteUser.reason as DeleteUserUnauthorizedReason
            : null,
        unauthorizedMessageMapper: (reason) => switch (reason) {
          CannotDeleteSelf() => 'You cannot delete yourself.',
          CannotDeleteAnalyst() => 'You cannot delete an analyst.',
          CanOnlyDeleteSelf() => 'You can only delete your own account.',
        },
      ),
    );
  }
}
