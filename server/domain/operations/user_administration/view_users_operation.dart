part of '../operation.dart';

class ViewUsersOperation
    extends Operation<User, ViewUserPolicy, UserRepository, List<User>> {
  const ViewUsersOperation(
      {required User subject,
      required ViewUserPolicy policy,
      required UserRepository repository})
      : super(subject: subject, policy: policy, repository: repository);

  @override
  List<User> execute(
      {required User subject,
      required ViewUserPolicy policy,
      required UserRepository repository}) {
    var filteredUsers = <User>[];

    for (final user in repository.users) {
      if (policy.isCompliant(subject: subject, object: user)) {
        filteredUsers.add(user);
      }
    }

    return filteredUsers;
  }
}
