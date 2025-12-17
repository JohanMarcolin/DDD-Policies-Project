part of '../../user_administration_view.dart';

class DeleteUserIcon extends StatelessWidget {
  const DeleteUserIcon({super.key, required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    final icon = Icons.delete;
    final bloc = context.read<UserAdministrationViewBloc>();
    final isUserDeletingSelf = bloc.isAdministratingSelf(user);

    return bloc.authorizeDeleteUser(
      user,
      onAuthorized: () {
        return BlocPresentationListener<UserAdministrationViewBloc, UserAdministrationViewEvent>(
          listener: (_, event) async {
            if (event is DeleteSelfSuccess) {
              context.read<AuthBloc>().add(AuthRevokeAuthenticationRequested());
            }
          },
          child: UserActionIcon.authorized(
            icon: icon,
            dialogChildBuilder: (context, {required closeDialog}) => DeleteUserDialogChild(
              isUserDeletingSelf: isUserDeletingSelf,
              onCancel: () async => await closeDialog(context),
              onConfirm: () => bloc.add(DeleteUserRequested(targetUser: user)),
            ),
            closeDialogOnEvent: (event) => event is DeleteUserSuccess || event is DeleteSelfSuccess,
            eventMessageMapper: (event) => switch (event) {
              DeleteUserFailure() => 'Failed to delete user',
              DeleteUserSuccess() => 'User deleted successfully',
              DeleteSelfSuccess() => 'You have deleted your account',
              _ => '',
            },
          ),
        );
      },
      onUnauthorized: (DeleteUserUnauthorizedReason reason) {
        return UserActionIcon.unauthorized<DeleteUserUnauthorizedReason>(
          icon: icon,
          unauthorizedReason: reason,
          unauthorizedMessageMapper: (reason) => switch (reason) {
            CannotDeleteSelf() => 'You cannot delete yourself',
            CannotDeleteAnalyst() => 'You cannot delete an analyst',
            CanOnlyDeleteSelf() => 'You can only delete your own account',
          },
        );
      },
    );
  }
}
