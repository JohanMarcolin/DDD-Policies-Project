import 'package:bloc_presentation/bloc_presentation.dart';
import 'package:client/presentation/widgets/action_snack_bar_helper.dart';
import 'package:client/presentation/views/user_administration_view/blocs/users_view_bloc/user_administration_view_bloc.dart';
import 'package:client/presentation/widgets/action_dialog_helper.dart';
import 'package:client/presentation/widgets/action_icon.dart';
import 'package:client/presentation/widgets/confirm_input_dialog.dart';
import 'package:domain/entities/user.dart';
import 'package:domain/policies/action_policies/action_policy.dart';
import 'package:domain/value_objects/email.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UpdateUserEmailIcon extends StatelessWidget {
  const UpdateUserEmailIcon({super.key, required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserAdministrationViewBloc, UserAdministrationViewState>(
      builder: (context, state) {
        final bloc = context.read<UserAdministrationViewBloc>();
        final updateEmail = bloc.authorizeUpdateEmail(user);

        return ActionIcon(
          icon: Icons.email,
          isGreyedOut: updateEmail is Authorized,
          onPressed: () {
            switch (updateEmail) {
              case Authorized():
                ActionDialogHelper.show(
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
                                UpdateUserEmailInvalid() =>
                                  'Invalid email format',
                                UpdateUserEmailFailure() =>
                                  'Failed to update email',
                                UpdateUserEmailSuccess() =>
                                  'Email updated successfully',
                                _ => '',
                              },
                            );
                            if (event is UpdateUserEmailSuccess) {
                              await ActionDialogHelper.hide();
                            }
                          },
                          child: ConfirmInputDialog(
                            title: 'Update Email',
                            label: 'New Email',
                            onCancel: () async => await ActionDialogHelper.hide(),
                            onConfirm: (value) {
                              bloc.add(
                                UpdateUserEmailRequested(
                                  targetUser: user,
                                  newEmail: Email(value),
                                ),
                              );
                            },
                          ),
                        ),
                  ),
                );
              case Unauthorized(:final reason as UpdateUserEmailUnauthorizedReason):
                ActionSnackBarHelper.show(
                  message: switch (reason) {
                    CannotUpdateEmailOnAnalyst() =>
                      'You cannot update the email of an analyst.',
                    CanOnlyUpdateEmailOnSelf() =>
                      'You can only update your own email.',
                  },
                );
            }
          },
        );
      },
    );
  }
}
