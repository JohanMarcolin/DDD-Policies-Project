import 'package:bloc_presentation/bloc_presentation.dart';
import 'package:client/presentation/utils/action_flush_bar.dart';
import 'package:client/presentation/views/user_administration_view/blocs/users_view_bloc/user_administration_view_bloc.dart';
import 'package:client/presentation/widgets/action_dialog.dart';
import 'package:client/presentation/widgets/action_icon.dart';
import 'package:client/presentation/widgets/confirm_input_dialog.dart';
import 'package:domain/entities/user.dart';
import 'package:domain/policies/action_policies/action_policy.dart';
import 'package:domain/policies/action_policies/action_policy_permission.dart';
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
        final updateEmailPermission = bloc.updateEmailPermission(user);

        return ActionIcon(
          icon: Icons.email,
          isGreyedOut: updateEmailPermission is Denied,
          onPressed: () {
            switch (updateEmailPermission) {
              case Granted():
                ActionDialogHelper.show(
                  child: BlocProvider.value(
                    value: bloc,
                    child:
                        BlocPresentationListener<
                          UserAdministrationViewBloc,
                          UserAdministrationViewEvent
                        >(
                          listener: (_, event) async {
                            showAppFlushbar(
                              context: context,
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
                              ActionDialogHelper.hide();
                            }
                          },
                          child: ConfirmInputDialog(
                            title: 'Update Email',
                            label: 'New Email',
                            onCancel: () => ActionDialogHelper.hide(),
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
              case Denied(:final reason as UpdateUserEmailDeniedReason):
                showAppFlushbar(
                  context: context,
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
