import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../application/user_usecases.dart';
import '../../../../infrastructure/user_repository.dart';
import '../../../infrastructure/mappers/user_mapper.dart';

class WorkspaceScreen extends StatefulWidget {
  const WorkspaceScreen({super.key});

  @override
  State<WorkspaceScreen> createState() => _WorkspaceScreenState();
}

class _WorkspaceScreenState extends State<WorkspaceScreen> {
  late final UserRepository _repository;
  late final ListUsersUseCase _listUsers;
  late final RemoveUserUseCase _removeUser;
  late final UpdateUserEmailUseCase _updateEmail;
  late final UpdateUserPasswordUseCase _updatePassword;
  List<User> _users = [];
  bool _loading = true;
  String? _error;
  String? _accessToken;

  @override
  void initState() {
    super.initState();
    _repository = UserRepository();
    _listUsers = ListUsersUseCase(_repository);
    _removeUser = RemoveUserUseCase(_repository);
    _updateEmail = UpdateUserEmailUseCase(_repository);
    _updatePassword = UpdateUserPasswordUseCase(_repository);
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    if (token == null) {
      setState(() {
        _error = 'Not authenticated.';
        _loading = false;
      });
      return;
    }
    _accessToken = token;
    try {
      final users = await _listUsers(token);
      setState(() {
        _users = users;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _removeUserById(String userId) async {
    if (_accessToken == null) return;
    try {
      await _removeUser(_accessToken!, userId);
      _loadUsers();
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    }
  }

  Future<void> _updateUserEmail(String userId) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Email'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'New Email'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Update'),
          ),
        ],
      ),
    );
    if (result != null && result.isNotEmpty && _accessToken != null) {
      try {
        await _updateEmail(_accessToken!, userId, result);
        _loadUsers();
      } catch (e) {
        setState(() {
          _error = e.toString();
        });
      }
    }
  }

  Future<void> _updateUserPassword(String userId) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Password'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'New Password'),
          obscureText: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Update'),
          ),
        ],
      ),
    );
    if (result != null && result.isNotEmpty && _accessToken != null) {
      try {
        await _updatePassword(_accessToken!, userId, result);
      } catch (e) {
        setState(() {
          _error = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Administration')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text(_error!))
          : ListView.builder(
              itemCount: _users.length,
              itemBuilder: (context, index) {
                final user = _users[index];
                return ListTile(
                  title: Text(user.username),
                  subtitle: Text(user.email),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.email),
                        tooltip: 'Update Email',
                        onPressed: () => _updateUserEmail(user.id),
                      ),
                      IconButton(
                        icon: const Icon(Icons.lock),
                        tooltip: 'Update Password',
                        onPressed: () => _updateUserPassword(user.id),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        tooltip: 'Remove User',
                        onPressed: () => _removeUserById(user.id),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
