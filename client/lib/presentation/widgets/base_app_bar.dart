import 'package:client/infrastructure/auth_bloc/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BaseAppBar extends StatelessWidget implements PreferredSizeWidget {
  const BaseAppBar({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      actions: [
        BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is Authenticated) {
              return IconButton(
                icon: const Icon(Icons.logout),
                tooltip: 'Logout',
                onPressed: () {
                  context.read<AuthBloc>().add(AuthLogoutRequested());
                },
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
