import 'package:bloc_presentation/bloc_presentation.dart';
import 'package:client/presentation/widgets/action_dialog_helper.dart';
import 'package:client/presentation/widgets/action_icon.dart';
import 'package:client/presentation/widgets/action_snack_bar_helper.dart';
import 'package:client/presentation/widgets/confirm_input_dialog.dart';
import 'package:domain/entities/user.dart';
import 'package:domain/policies/action_policies/action_policy.dart';
import 'package:domain/policies/validation_policies/validation_policy.dart';
import 'package:domain/value_objects/email.dart';
import 'package:domain/value_objects/password.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'blocs/users_view_bloc/user_administration_view_bloc.dart';
import '../../widgets/base_app_bar.dart';

part 'components/delete_user/delete_user_icon.dart';
part 'components/update_user_email/update_user_email_icon.dart';
part 'components/update_user_email/update_user_email_dialog_child.dart';
part 'components/update_user_password/update_user_password_icon.dart';
part 'components/update_user_password/update_user_password_dialog_child.dart';
part 'components/user_action_icon.dart';
part 'components/user_list.dart';
part 'components/user_tile.dart';

class UserAdministrationView extends StatelessWidget {
  const UserAdministrationView({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: context.read<UserAdministrationViewBloc>(),
      child: Scaffold(
        appBar: const BaseAppBar(title: 'User Administration'),
        body:
            BlocBuilder<
              UserAdministrationViewBloc,
              UserAdministrationViewState
            >(
              builder: (context, state) {
                return switch (state) {
                  UserAdministrationViewLoading() => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  UserAdministrationViewFailure() => Center(
                    child: Text('Failure loading users'),
                  ),
                  UserAdministrationViewLoaded(:final users) => UserList(
                    users: users,
                  ),
                  _ => const SizedBox.shrink(),
                };
              },
            ),
      ),
    );
  }
}
