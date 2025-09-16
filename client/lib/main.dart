import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:io';
import 'presentation/workspace_screen.dart';

// =====================
// CONFIGURE YOUR SERVER BASE URL HERE
// For Android emulator: http://10.0.2.2:8080
// For Windows/macOS/Linux desktop: http://localhost:8080
// For real device: http://<YOUR_PC_LAN_IP>:8080 (e.g. http://192.168.1.100:8080)
const String kBaseUrl = 'http://10.0.2.2:8080'; // CHANGE THIS AS NEEDED
// =====================

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');
    setState(() {
      _isAuthenticated = accessToken != null;
    });
  }

  void _onLoginSuccess() {
    setState(() {
      _isAuthenticated = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'User Admin App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: _isAuthenticated
          ? const WorkspaceScreen()
          : LoginScreen(onLoginSuccess: _onLoginSuccess),
    );
  }
}

class LoginScreen extends StatefulWidget {
  final VoidCallback onLoginSuccess;
  const LoginScreen({super.key, required this.onLoginSuccess});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _login() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    // Use the configurable baseUrl above
    final url = Uri.parse('$kBaseUrl/auth/login');
    try {
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': _usernameController.text,
              'password': _passwordController.text,
            }),
          )
          .timeout(const Duration(seconds: 8));
      print('Login response: ${response.statusCode} ${response.body}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();
        // Fix: extract tokens from the nested 'result' field
        final result = data['result'];
        await prefs.setString('accessToken', result['accessToken'] ?? '');
        await prefs.setString('refreshToken', result['refreshToken'] ?? '');
        widget.onLoginSuccess();
      } else {
        setState(() {
          _error = 'Login failed: ${response.body}';
        });
      }
    } on SocketException catch (e) {
      print('SocketException: $e');
      setState(() {
        _error = 'Network error: $e';
      });
    } on TimeoutException catch (e) {
      print('TimeoutException: $e');
      setState(() {
        _error = 'Request timed out. Is the server running?';
      });
    } catch (e, stack) {
      print('Login error: $e\n$stack');
      setState(() {
        _error = 'Error: $e';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ElevatedButton(
              onPressed: _loading ? null : _login,
              child: _loading
                  ? const CircularProgressIndicator()
                  : const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}

// WorkspaceScreen moved to presentation/workspace_screen.dart
