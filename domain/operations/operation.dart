import '../entities/user.dart';
import '../policies/policy.dart';
import '../repositories/user_repository.dart';

part 'user_administration/view_users_operation.dart';

sealed class Operation<TRequester, TPolicy extends Policy, TRepository,
    TResult> {
  const Operation();

  TResult execute(
      {required TRequester requester,
      required TPolicy policy,
      required TRepository repository});
}
