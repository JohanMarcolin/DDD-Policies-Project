part of '../operation.dart';

class ViewUsersOperation
    extends Operation<User, ViewUserPolicy, UserRepository, List<User>> {
  const ViewUsersOperation();

  @override
  List<User> execute(
      {required User requester,
      required ViewUserPolicy policy,
      required UserRepository repository}) {
    var visibleUsers = <User>[];

    for (final user in repository.users) {
      if (policy.isCompliant(requester: requester, target: user)) {
        visibleUsers.add(user);
      }
    }

    return visibleUsers;
  }
}
