import 'package:client/infrastructure/apis/user_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'infrastructure/auth_bloc/auth_bloc.dart';
import 'infrastructure/user_repository.dart';
import 'presentation/users_view/blocs/users_view_bloc/users_view_bloc.dart';
import 'presentation/workspace_screen.dart';

const String kBaseUrl = 'http://10.0.2.2:8080';
// =====================

void main() {
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => AuthBloc()..add(AuthCheckRequested()),
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
          if (state is AuthAuthenticated) {
            return BlocProvider(
              create: (_) => UsersViewBloc(
                userRepository: UserRepository(UserApi()),
                accessToken: state.accessToken,
              )..add(UsersFetchRequested()),
              child: const WorkspaceScreen(),
            );
          }
          if (state is AuthLoading) {
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

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _login() {
    BlocProvider.of<AuthBloc>(context).add(
      AuthLoginRequested(_usernameController.text, _passwordController.text, (
        email,
        password,
      ) async {
        final url = Uri.parse('$kBaseUrl/auth/login');
        final response = await http
            .post(
              url,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({'email': email, 'password': password}),
            )
            .timeout(const Duration(seconds: 8));
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final result = data['result'];
          return {
            'accessToken': result['accessToken'] ?? '',
            'refreshToken': result['refreshToken'] ?? '',
          };
        } else {
          throw Exception('Login failed: ${response.body}');
        }
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthFailure) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: const Text('Login')),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  controller: _usernameController,
                  decoration: const InputDecoration(labelText: 'Username'),
                ),
                TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                ),
                const SizedBox(height: 20),
                if (state is AuthLoading) const CircularProgressIndicator(),
                ElevatedButton(
                  onPressed: state is AuthLoading ? null : _login,
                  child: const Text('Login'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// WorkspaceScreen moved to presentation/workspace_screen.dart
