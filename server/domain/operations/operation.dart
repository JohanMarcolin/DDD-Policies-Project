import '../entities/user.dart';
import '../policies/policy.dart';
import '../repositories/user_repository.dart';

part 'user_administration/view_users_operation.dart';

sealed class Operation<TSubject, TPolicy extends Policy, TRepository, TResult> {
  const Operation(
      {required this.subject, required this.policy, required this.repository});

  final TSubject subject;
  final TPolicy policy;
  final TRepository repository;

  TResult execute(
      {required TSubject subject,
      required TPolicy policy,
      required TRepository repository});
}
