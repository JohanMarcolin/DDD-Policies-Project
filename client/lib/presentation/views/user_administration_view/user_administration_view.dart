import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'blocs/users_view_bloc/user_administration_view_bloc.dart';
import 'components/user_tile.dart';
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
              if (state is UserAdministrationViewLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is UserAdministrationViewFailure) {
                return Center(child: Text('Failure loading users'));
              }
              if (state is UserAdministrationViewLoaded) {
                return ListView.builder(
                  itemCount: state.users.length,
                  itemBuilder: (context, index) =>
                      UserTile(user: state.users[index]),
                );
              }
              return const SizedBox.shrink();
            },
          ),
    );
  }
}
