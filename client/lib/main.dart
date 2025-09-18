import 'package:client/infrastructure/apis/auth_api.dart';
import 'package:client/infrastructure/apis/user_api.dart';
import 'package:client/infrastructure/services/auth_token_service.dart';
import 'package:client/presentation/users_view/components/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'infrastructure/auth_bloc/auth_bloc.dart';
import 'infrastructure/repositories/http_user_repository.dart';
import 'presentation/users_view/blocs/users_view_bloc/users_view_bloc.dart';
import 'presentation/users_view.dart';

void main() {
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) =>
              AuthBloc(authApi: AuthApi(authTokenService: AuthTokenService()))
                ..add(AuthRefreshRequested()),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'User Admin App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is Authenticated) {
            return BlocProvider(
              create: (_) => UsersViewBloc(
                userRepository: HttpUserRepository(
                  userApi: UserApi(
                    authApi: AuthApi(authTokenService: AuthTokenService()),
                    authTokenService: AuthTokenService(),
                  ),
                ),
              )..add(UsersFetchRequested()),
              child: const UsersView(),
            );
          }
          if (state is UsersViewLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          return const LoginScreen();
        },
      ),
    );
  }
}
