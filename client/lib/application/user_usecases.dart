import '../infrastructure/user_repository.dart';
import '../infrastructure/models/user.dart';

class ListUsersUseCase {
  final UserRepository repository;
  ListUsersUseCase(this.repository);
  Future<List<User>> call(String accessToken) =>
      repository.listUsers(accessToken);
}

class RemoveUserUseCase {
  final UserRepository repository;
  RemoveUserUseCase(this.repository);
  Future<void> call(String accessToken, String userId) =>
      repository.removeUser(accessToken, userId);
}

class UpdateUserEmailUseCase {
  final UserRepository repository;
  UpdateUserEmailUseCase(this.repository);
  Future<void> call(String accessToken, String userId, String newEmail) =>
      repository.updateEmail(accessToken, userId, newEmail);
}

class UpdateUserPasswordUseCase {
  final UserRepository repository;
  UpdateUserPasswordUseCase(this.repository);
  Future<void> call(String accessToken, String userId, String newPassword) =>
      repository.updatePassword(accessToken, userId, newPassword);
}
