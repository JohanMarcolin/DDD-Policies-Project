part of '../user_administration_view.dart';

class UserAdministrationAppBar extends StatelessWidget implements PreferredSizeWidget {
  const UserAdministrationAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('User Administration'),
      actions: [
        BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthFailure) {
              ActionSnackBarHelper.show(message: 'Logout failed. Please log in again or try again later.');
            } else {
              ActionSnackBarHelper.show(message: 'Logged out successfully.');
            }
          },
          builder: (context, state) {
            if (state is Authenticated) {
              return LogoutButton();
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }
}

class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.logout),
      tooltip: 'Logout',
      onPressed: () {
        context.read<AuthBloc>().add(AuthLogoutRequested());
      },
    );
  }
}
