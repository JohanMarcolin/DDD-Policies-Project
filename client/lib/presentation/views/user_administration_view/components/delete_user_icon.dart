import 'package:bloc_presentation/bloc_presentation.dart';
import 'package:client/presentation/views/user_administration_view/blocs/users_view_bloc/user_administration_view_bloc.dart';
import 'package:client/presentation/widgets/action_dialog_helper.dart';
import 'package:client/presentation/widgets/action_icon.dart';
import 'package:client/presentation/widgets/action_snack_bar_helper.dart';
import 'package:client/presentation/widgets/confirm_input_dialog.dart';
import 'package:domain/entities/user.dart';
import 'package:domain/policies/action_policies/action_policy.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DeleteUserIcon extends StatelessWidget {
  const DeleteUserIcon({super.key, required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserAdministrationViewBloc, UserAdministrationViewState>(
      builder: (context, state) {
        final bloc = context.read<UserAdministrationViewBloc>();
        final deleteUser = bloc.authorizeDeleteUser(user);

        return ActionIcon(
          icon: Icons.delete,
          isGreyedOut: deleteUser is Unauthorized,
          onPressed: () {
            switch (deleteUser) {
              case Authorized():
                ActionDialogHelper.show(
                  context: context,
                  child: BlocProvider.value(
                    value: bloc,
                    child:
                        BlocPresentationListener<
                          UserAdministrationViewBloc,
                          UserAdministrationViewEvent
                        >(
                          listener: (_, event) async {
                            ActionSnackBarHelper.show(
                              message: switch (event) {
                                DeleteUserFailure() => 'Failed to delete user',
                                DeleteUserSuccess() =>
                                  'User deleted successfully',
                                _ => '',
                              },
                            );
                            if (event is DeleteUserSuccess) {
                              ActionDialogHelper.hide(context);
                            }
                          },
                          child: ConfirmInputDialog(
                            title: 'Delete User',
                            label: 'Are you sure you want to delete this user?',
                            onCancel: () => ActionDialogHelper.hide(context),
                            onConfirm: (value) {
                              bloc.add(DeleteUserRequested(targetUser: user));
                            },
                          ),
                        ),
                  ),
                );
              case Unauthorized(:final reason):
                ActionSnackBarHelper.show(
                  message: switch (reason as DeleteUserUnauthorizedReason) {
                    CannotDeleteSelf() => 'You cannot delete yourself.',
                    CannotDeleteAnalyst() => 'You cannot delete an analyst.',
                    CanOnlyDeleteSelf() =>
                      'You can only delete your own account.',
                  },
                );
            }
          },
        );
      },
    );
  }
}
