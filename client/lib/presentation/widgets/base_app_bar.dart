import 'package:client/infrastructure/auth_bloc/auth_bloc.dart';
import 'package:client/presentation/widgets/action_snack_bar_helper.dart';
import 'package:error_codes/error_codes.dart';
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
        BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthFailure) {
              ActionSnackBarHelper.show(
                message: (() {
                  if (state.errorCode is LogoutErrorCode) {
                    return switch (state.errorCode as LogoutErrorCode) {
                      LogoutCouldNotRevokeRefreshToken() =>
                        'Could not log out. Please try again.',
                      LogoutMissingRefreshToken() =>
                        'Missing refresh token. Please log in again.',
                      LogoutMissingUser() =>
                        'Missing user. Please log in again.',
                    };
                  } else {
                    return 'Authentication failure. Please try again.';
                  }
                })(),
              );
            }
          },
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
