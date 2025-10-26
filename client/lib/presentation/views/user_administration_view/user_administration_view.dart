import 'package:client/presentation/views/user_administration_view/components/user_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'blocs/users_view_bloc/user_administration_view_bloc.dart';
import '../../widgets/base_app_bar.dart';

class UserAdministrationView extends StatelessWidget {
  const UserAdministrationView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BaseAppBar(title: 'User Administration'),
      body:
          BlocBuilder<UserAdministrationViewBloc, UserAdministrationViewState>(
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
    );
  }
}
