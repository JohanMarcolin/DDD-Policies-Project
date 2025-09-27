import 'package:bloc_presentation/bloc_presentation.dart';
import 'package:client/presentation/views/user_administration_view/blocs/users_view_bloc/user_administration_view_bloc.dart';
import 'package:client/presentation/widgets/action_icon.dart';
import 'package:client/presentation/widgets/confirm_dialog.dart';
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
          isGreyedOut: !updateEmailPermission.isGranted,
          onPressed: () {
            switch (updateEmailPermission) {
              case Granted():
                showDialog(
                  context: context,
                  builder: (dialogContext) {
                    return BlocProvider.value(
                      value: bloc,
                      child:
                          BlocPresentationListener<
                            UserAdministrationViewBloc,
                            UserAdministrationViewEvent
                          >(
                            listener: (_, event) {
                              if (event is UserUpdateEmailInvalid) {
                                ScaffoldMessenger.of(dialogContext)
                                  ..hideCurrentSnackBar()
                                  ..showSnackBar(
                                    SnackBar(
                                      content: Text('Invalid email format'),
                                    ),
                                  );
                              }
                              if (event is UserUpdateEmailFailure) {
                                ScaffoldMessenger.of(dialogContext)
                                  ..hideCurrentSnackBar()
                                  ..showSnackBar(
                                    SnackBar(
                                      content: Text('Failed to update email'),
                                    ),
                                  );
                              }
                              if (event is UserUpdateEmailSuccess) {
                                Navigator.of(dialogContext).pop();
                                ScaffoldMessenger.of(dialogContext)
                                  ..hideCurrentSnackBar()
                                  ..showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Email updated successfully',
                                      ),
                                    ),
                                  );
                              }
                            },
                            child: ConfirmDialog(
                              title: 'Update Email',
                              label: 'New Email',
                              onConfirm: (value) {
                                bloc.add(
                                  UserUpdateEmailRequested(
                                    targetUser: user,
                                    newEmail: Email(value),
                                  ),
                                );
                              },
                            ),
                          ),
                    );
                  },
                );
              case Denied(:final reason as UpdateUserEmailDeniedReason):
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(switch (reason) {
                      CannotUpdateEmailOnAnalyst() =>
                        'You cannot update the email of an analyst.',
                      CanOnlyUpdateEmailOnSelf() =>
                        'You can only update your own email.',
                    }),
                  ),
                );
            }
          },
        );
      },
    );
  }
}
