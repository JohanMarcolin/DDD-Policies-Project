import 'package:domain/policies/action_authorization_policies/user_administration/user_administration_policy.dart';
import 'package:domain/policies/policy_violation_exception.dart';
import 'package:domain/policies/value_validation_policies/user_credentials/user_credential_policy.dart';
import 'package:domain/services/user_administration/user_administration_service.dart';
import 'package:domain/value_objects/email.dart';
import 'package:domain/value_objects/password.dart';
import 'package:test/test.dart';
import '../../utils/repositories/dummy_user_repository.dart';

import '../../utils/mock/mock_users.dart';

void main() {
  late UserAdministrationService userAdministrationService;

  setUp(() {
    userAdministrationService = UserAdministrationService(
      userRepository: DummyUserRepository([user, otherUser, admin, otherAdmin, analyst, otherAnalyst]),
      viewUserPolicy: ViewUserPolicy(),
      updateUserEmailPolicy: UpdateUserEmailPolicy(),
      updateUserPasswordPolicy: UpdateUserPasswordPolicy(),
      deleteUserPolicy: DeleteUserPolicy(),
      userEmailValidationPolicy: UserEmailValidationPolicy(),
      userPasswordValidationPolicy: UserPasswordValidationPolicy(),
    );
  });

  group('UserAdministrationService', () {
    group('viewUsers', () {
      group('User', () {
        test('should be able to view self', () async {
          final self = user;
          final users = await userAdministrationService.viewUsers(initiator: self);
          expect(users, contains(self));
        });
        test('should be able to view other users', () async {
          final users = await userAdministrationService.viewUsers(initiator: user);
          expect(users, contains(otherUser));
        });
        test('should be able to view admins', () async {
          final users = await userAdministrationService.viewUsers(initiator: user);
          expect(users, contains(admin));
          expect(users, contains(otherAdmin));
        });
        test('should not be able to view analysts', () async {
          final users = await userAdministrationService.viewUsers(initiator: user);
          expect(users, isNot(contains(analyst)));
          expect(users, isNot(contains(otherAnalyst)));
        });
      });
      group('Admin', () {
        test('should be able to view self', () async {
          final self = admin;
          final users = await userAdministrationService.viewUsers(initiator: self);
          expect(users, contains(self));
        });
        test('should be able to view users', () async {
          final users = await userAdministrationService.viewUsers(initiator: admin);
          expect(users, contains(user));
          expect(users, contains(otherUser));
        });
        test('should be able to view other admins', () async {
          final users = await userAdministrationService.viewUsers(initiator: admin);
          expect(users, contains(otherAdmin));
        });
        test('should not be able to view analysts', () async {
          final users = await userAdministrationService.viewUsers(initiator: admin);
          expect(users, isNot(contains(analyst)));
          expect(users, isNot(contains(otherAnalyst)));
        });
      });
      group('Analyst', () {
        test('should be able to view self', () async {
          final self = analyst;
          final users = await userAdministrationService.viewUsers(initiator: self);
          expect(users, contains(self));
        });
        test('should be able to view users', () async {
          final users = await userAdministrationService.viewUsers(initiator: analyst);
          expect(users, contains(user));
          expect(users, contains(otherUser));
        });
        test('should be able to view admins', () async {
          final users = await userAdministrationService.viewUsers(initiator: analyst);
          expect(users, contains(admin));
          expect(users, contains(otherAdmin));
        });
        test('should be able to view other analysts', () async {
          final users = await userAdministrationService.viewUsers(initiator: analyst);
          expect(users, contains(otherAnalyst));
        });
      });
    });
    group('viewUser', () {
      group('User', () {
        test('should be able to view self', () async {
          final self = user;
          final viewedUser = await userAdministrationService.viewUser(initiator: self, userId: self.userId);
          expect(viewedUser, equals(self));
        });
        test('should be able to view other users', () async {
          final viewedUser = await userAdministrationService.viewUser(initiator: user, userId: otherUser.userId);
          expect(viewedUser, equals(otherUser));
        });
        test('should be able to view admins', () async {
          final viewedUser = await userAdministrationService.viewUser(initiator: user, userId: admin.userId);
          expect(viewedUser, equals(admin));
        });
        test('should not be able to view analysts', () async {
          expect(
            () async => await userAdministrationService.viewUser(initiator: user, userId: analyst.userId),
            throwsA(
              predicate(
                  (e) => e is PolicyViolationException<ViewUserUnauthorizedReason> && e.reason == CannotViewAnalyst()),
            ),
          );
        });
      });
      group('Admin', () {
        test('should be able to view self', () async {
          final self = admin;
          final viewedUser = await userAdministrationService.viewUser(initiator: self, userId: self.userId);
          expect(viewedUser, equals(self));
        });
        test('should be able to view users', () async {
          final viewedUser = await userAdministrationService.viewUser(initiator: admin, userId: user.userId);
          expect(viewedUser, equals(user));
        });
        test('should be able to view other admins', () async {
          final viewedUser = await userAdministrationService.viewUser(initiator: admin, userId: otherAdmin.userId);
          expect(viewedUser, equals(otherAdmin));
        });
        test('should not be able to view analysts', () async {
          expect(
            () async => await userAdministrationService.viewUser(initiator: admin, userId: analyst.userId),
            throwsA(
              predicate(
                  (e) => e is PolicyViolationException<ViewUserUnauthorizedReason> && e.reason == CannotViewAnalyst()),
            ),
          );
        });
      });
      group('Analyst', () {
        test('should be able to view self', () async {
          final self = analyst;
          final viewedUser = await userAdministrationService.viewUser(initiator: self, userId: self.userId);
          expect(viewedUser, equals(self));
        });
        test('should be able to view users', () async {
          final viewedUser = await userAdministrationService.viewUser(initiator: analyst, userId: user.userId);
          expect(viewedUser, equals(user));
        });
        test('should be able to view admins', () async {
          final viewedUser = await userAdministrationService.viewUser(initiator: analyst, userId: admin.userId);
          expect(viewedUser, equals(admin));
        });
        test('should be able to view other analysts', () async {
          final viewedUser = await userAdministrationService.viewUser(initiator: analyst, userId: otherAnalyst.userId);
          expect(viewedUser, equals(otherAnalyst));
        });
      });
    });
    group('authorizeViewUser', () {
      group('User', () {
        test('should authorize viewing self', () {
          final self = user;
          final result = userAdministrationService.authorizeViewUser(
            initiator: self,
            target: self,
            onAuthorized: () => true,
            onUnauthorized: (reason) => false,
          );
          expect(result, isTrue);
        });
        test('should authorize viewing other users', () {
          final result = userAdministrationService.authorizeViewUser(
            initiator: user,
            target: otherUser,
            onAuthorized: () => true,
            onUnauthorized: (reason) => false,
          );
          expect(result, isTrue);
        });
        test('should authorize viewing admins', () {
          final result = userAdministrationService.authorizeViewUser(
            initiator: user,
            target: admin,
            onAuthorized: () => true,
            onUnauthorized: (reason) => false,
          );
          expect(result, isTrue);
        });
        test('should not authorize viewing analysts', () {
          final result = userAdministrationService.authorizeViewUser(
            initiator: user,
            target: analyst,
            onAuthorized: () => true,
            onUnauthorized: (reason) => false,
          );
          expect(result, isFalse);
        });
      });
      group('Admin', () {
        test('should authorize viewing self', () {
          final self = admin;
          final result = userAdministrationService.authorizeViewUser(
            initiator: self,
            target: self,
            onAuthorized: () => true,
            onUnauthorized: (reason) => false,
          );
          expect(result, isTrue);
        });
        test('should authorize viewing users', () {
          final result = userAdministrationService.authorizeViewUser(
            initiator: admin,
            target: user,
            onAuthorized: () => true,
            onUnauthorized: (reason) => false,
          );
          expect(result, isTrue);
        });
        test('should authorize viewing other admins', () {
          final result = userAdministrationService.authorizeViewUser(
            initiator: admin,
            target: otherAdmin,
            onAuthorized: () => true,
            onUnauthorized: (reason) => false,
          );
          expect(result, isTrue);
        });
        test('should not authorize viewing analysts', () {
          final result = userAdministrationService.authorizeViewUser(
            initiator: admin,
            target: analyst,
            onAuthorized: () => true,
            onUnauthorized: (reason) => false,
          );
          expect(result, isFalse);
        });
      });
      group('Analyst', () {
        test('should authorize viewing self', () {
          final self = analyst;
          final result = userAdministrationService.authorizeViewUser(
            initiator: self,
            target: self,
            onAuthorized: () => true,
            onUnauthorized: (reason) => false,
          );
          expect(result, isTrue);
        });
        test('should authorize viewing users', () {
          final result = userAdministrationService.authorizeViewUser(
            initiator: analyst,
            target: user,
            onAuthorized: () => true,
            onUnauthorized: (reason) => false,
          );
          expect(result, isTrue);
        });
        test('should authorize viewing admins', () {
          final result = userAdministrationService.authorizeViewUser(
            initiator: analyst,
            target: admin,
            onAuthorized: () => true,
            onUnauthorized: (reason) => false,
          );
          expect(result, isTrue);
        });
        test('should authorize viewing other analysts', () {
          final result = userAdministrationService.authorizeViewUser(
            initiator: analyst,
            target: otherAnalyst,
            onAuthorized: () => true,
            onUnauthorized: (reason) => false,
          );
          expect(result, isTrue);
        });
      });
    });
    group('deleteUser', () {
      group('User', () {
        test('should be able to delete self', () async {
          final self = user;
          await userAdministrationService.deleteUser(initiator: self, target: self);
          final users = await userAdministrationService.viewUsers(initiator: self);
          expect(users, isNot(contains(self)));
        });

        test('should not be able to delete other users', () async {
          expect(
            () async => await userAdministrationService.deleteUser(initiator: user, target: otherUser),
            throwsA(
              predicate((e) =>
                  e is PolicyViolationException<DeleteUserUnauthorizedReason> && e.reason == CanOnlyDeleteSelf()),
            ),
          );
        });

        test('should not be able to delete admins', () async {
          expect(
            () async => await userAdministrationService.deleteUser(initiator: user, target: admin),
            throwsA(
              predicate((e) =>
                  e is PolicyViolationException<DeleteUserUnauthorizedReason> && e.reason == CanOnlyDeleteSelf()),
            ),
          );
        });

        test('should not be able to delete analysts', () async {
          expect(
            () async => await userAdministrationService.deleteUser(initiator: user, target: analyst),
            throwsA(
              predicate((e) =>
                  e is PolicyViolationException<DeleteUserUnauthorizedReason> && e.reason == CanOnlyDeleteSelf()),
            ),
          );
        });
      });
      group('Admin', () {
        test('should be able to delete self', () async {
          final self = admin;
          await userAdministrationService.deleteUser(initiator: self, target: self);
          final users = await userAdministrationService.viewUsers(initiator: self);
          expect(users, isNot(contains(self)));
        });

        test('should be able to delete users', () async {
          final target = otherUser;
          await userAdministrationService.deleteUser(initiator: admin, target: target);
          final users = await userAdministrationService.viewUsers(initiator: admin);
          expect(users, isNot(contains(target)));
        });

        test('should be able to delete other admins', () async {
          final target = otherAdmin;
          await userAdministrationService.deleteUser(initiator: admin, target: target);
          final users = await userAdministrationService.viewUsers(initiator: admin);
          expect(users, isNot(contains(target)));
        });

        test('should not be able to delete analysts', () async {
          expect(
            () async => await userAdministrationService.deleteUser(initiator: admin, target: analyst),
            throwsA(
              predicate((e) =>
                  e is PolicyViolationException<DeleteUserUnauthorizedReason> && e.reason == CannotDeleteAnalyst()),
            ),
          );
        });
      });
      group('Analyst', () {
        test('should not be able to delete self', () async {
          expect(
            () async => await userAdministrationService.deleteUser(initiator: analyst, target: analyst),
            throwsA(
              predicate(
                  (e) => e is PolicyViolationException<DeleteUserUnauthorizedReason> && e.reason == CannotDeleteSelf()),
            ),
          );
        });

        test('should be able to delete users', () async {
          final target = otherUser;
          await userAdministrationService.deleteUser(initiator: analyst, target: target);
          final users = await userAdministrationService.viewUsers(initiator: analyst);
          expect(users, isNot(contains(target)));
        });

        test('should be able to delete admins', () async {
          final target = otherAdmin;
          await userAdministrationService.deleteUser(initiator: analyst, target: target);
          final users = await userAdministrationService.viewUsers(initiator: analyst);
          expect(users, isNot(contains(target)));
        });

        test('should be able to delete other analysts', () async {
          final target = otherAnalyst;
          await userAdministrationService.deleteUser(initiator: analyst, target: target);
          final users = await userAdministrationService.viewUsers(initiator: analyst);
          expect(users, isNot(contains(target)));
        });
      });
    });
    group('authorizeDeleteUser', () {
      group('User', () {
        test('should authorize deleting self', () {
          final self = user;
          final result = userAdministrationService.authorizeDeleteUser(
            initiator: self,
            target: self,
            onAuthorized: () => true,
            onUnauthorized: (reason) => false,
          );
          expect(result, isTrue);
        });
        test('should not authorize deleting other users', () {
          final result = userAdministrationService.authorizeDeleteUser(
            initiator: user,
            target: otherUser,
            onAuthorized: () => true,
            onUnauthorized: (reason) => false,
          );
          expect(result, isFalse);
        });
        test('should not authorize deleting admins', () {
          final result = userAdministrationService.authorizeDeleteUser(
            initiator: user,
            target: admin,
            onAuthorized: () => true,
            onUnauthorized: (reason) => false,
          );
          expect(result, isFalse);
        });
        test('should not authorize deleting analysts', () {
          final result = userAdministrationService.authorizeDeleteUser(
            initiator: user,
            target: analyst,
            onAuthorized: () => true,
            onUnauthorized: (reason) => false,
          );
          expect(result, isFalse);
        });
      });
      group('Admin', () {
        test('should authorize deleting self', () {
          final self = admin;
          final result = userAdministrationService.authorizeDeleteUser(
            initiator: self,
            target: self,
            onAuthorized: () => true,
            onUnauthorized: (reason) => false,
          );
          expect(result, isTrue);
        });
        test('should authorize deleting users', () {
          final result = userAdministrationService.authorizeDeleteUser(
            initiator: admin,
            target: user,
            onAuthorized: () => true,
            onUnauthorized: (reason) => false,
          );
          expect(result, isTrue);
        });
        test('should authorize deleting other admins', () {
          final result = userAdministrationService.authorizeDeleteUser(
            initiator: admin,
            target: otherAdmin,
            onAuthorized: () => true,
            onUnauthorized: (reason) => false,
          );
          expect(result, isTrue);
        });
        test('should not authorize deleting analysts', () {
          final result = userAdministrationService.authorizeDeleteUser(
            initiator: admin,
            target: analyst,
            onAuthorized: () => true,
            onUnauthorized: (reason) => false,
          );
          expect(result, isFalse);
        });
      });
      group('Analyst', () {
        test('should not authorize deleting self', () {
          final self = analyst;
          final result = userAdministrationService.authorizeDeleteUser(
            initiator: self,
            target: self,
            onAuthorized: () => true,
            onUnauthorized: (reason) => false,
          );
          expect(result, isFalse);
        });
        test('should authorize deleting users', () {
          final result = userAdministrationService.authorizeDeleteUser(
            initiator: analyst,
            target: otherUser,
            onAuthorized: () => true,
            onUnauthorized: (reason) => false,
          );
          expect(result, isTrue);
        });
        test('should authorize deleting admins', () {
          final result = userAdministrationService.authorizeDeleteUser(
            initiator: analyst,
            target: otherAdmin,
            onAuthorized: () => true,
            onUnauthorized: (reason) => false,
          );
          expect(result, isTrue);
        });
        test('should authorize deleting other analysts', () {
          final result = userAdministrationService.authorizeDeleteUser(
            initiator: analyst,
            target: otherAnalyst,
            onAuthorized: () => true,
            onUnauthorized: (reason) => false,
          );
          expect(result, isTrue);
        });
      });
    });
    group('updateUserEmail', () {
      group('User', () {
        test('should be able to update own email to a new valid email', () async {
          final self = user;
          final newEmail = Email('new.email@example.com');
          await userAdministrationService.updateUserEmail(initiator: self, target: self, newEmail: newEmail);
          final updatedUser = await userAdministrationService.viewUser(initiator: self, userId: self.userId);
          expect(updatedUser!.email, equals(newEmail));
        });
        test('should not be able to update own email to an invalid email', () async {
          final self = user;
          final newEmail = Email('invalid-email');
          expect(
            () async =>
                await userAdministrationService.updateUserEmail(initiator: self, target: self, newEmail: newEmail),
            throwsA(
              predicate((e) =>
                  e is PolicyViolationException<UpdateUserEmailUnauthorizedReason> && e.reason is EmailInvalidFormat),
            ),
          );
        });
        test('should not be able to update another user\'s email', () async {
          final self = user;
          final newEmail = Email('new.email@example.com');
          expect(
            () async =>
                await userAdministrationService.updateUserEmail(initiator: self, target: otherUser, newEmail: newEmail),
            throwsA(
              predicate((e) =>
                  e is PolicyViolationException<UpdateUserEmailUnauthorizedReason> &&
                  e.reason is CanOnlyUpdateEmailOnSelf),
            ),
          );
        });
        test('should not be able to update an admin\'s email', () async {
          final self = user;
          final newEmail = Email('new.email@example.com');
          expect(
            () async => await userAdministrationService.updateUserEmail(
                initiator: self, target: otherAdmin, newEmail: newEmail),
            throwsA(
              predicate((e) =>
                  e is PolicyViolationException<UpdateUserEmailUnauthorizedReason> &&
                  e.reason is CanOnlyUpdateEmailOnSelf),
            ),
          );
        });

        test('should not be able to update an analyst\'s email', () async {
          final self = user;
          final newEmail = Email('new.email@example.com');
          expect(
            () async => await userAdministrationService.updateUserEmail(
                initiator: self, target: otherAnalyst, newEmail: newEmail),
            throwsA(
              predicate((e) =>
                  e is PolicyViolationException<UpdateUserEmailUnauthorizedReason> &&
                  e.reason is CanOnlyUpdateEmailOnSelf),
            ),
          );
        });
      });
      group('Admin', () {
        test('should be able to update own email to a new valid email', () async {
          final self = admin;
          final newEmail = Email('new.email@example.com');
          await userAdministrationService.updateUserEmail(initiator: self, target: self, newEmail: newEmail);
          final updatedUser = await userAdministrationService.viewUser(initiator: self, userId: self.userId);
          expect(updatedUser!.email, equals(newEmail));
        });

        test('should not be able to update own email to an invalid email', () async {
          final self = admin;
          final newEmail = Email('invalid-email');
          expect(
            () async =>
                await userAdministrationService.updateUserEmail(initiator: self, target: self, newEmail: newEmail),
            throwsA(
              predicate((e) =>
                  e is PolicyViolationException<UpdateUserEmailUnauthorizedReason> && e.reason is EmailInvalidFormat),
            ),
          );
        });

        test('should be able to update a user\'s email to a new valid email', () async {
          final self = admin;
          final newEmail = Email('new.email@example.com');
          await userAdministrationService.updateUserEmail(initiator: self, target: otherUser, newEmail: newEmail);
          final updatedUser = await userAdministrationService.viewUser(initiator: self, userId: otherUser.userId);
          expect(updatedUser!.email, equals(newEmail));
        });

        test('should not be able to update an analyst\'s email', () async {
          final self = admin;
          final newEmail = Email('new.email@example.com');
          expect(
            () async => await userAdministrationService.updateUserEmail(
                initiator: self, target: otherAnalyst, newEmail: newEmail),
            throwsA(
              predicate((e) =>
                  e is PolicyViolationException<UpdateUserEmailUnauthorizedReason> &&
                  e.reason is CanOnlyUpdateEmailOnSelf),
            ),
          );
        });
      });
      group('Analyst', () {
        test('should be able to update own email to a new valid email', () async {
          final self = analyst;
          final newEmail = Email('new.email@example.com');
          await userAdministrationService.updateUserEmail(initiator: self, target: self, newEmail: newEmail);
          final updatedUser = await userAdministrationService.viewUser(initiator: self, userId: self.userId);
          expect(updatedUser!.email, equals(newEmail));
        });
        test('should not be able to update own email to an invalid email', () async {
          final self = analyst;
          final newEmail = Email('invalid-email');
          expect(
            () async =>
                await userAdministrationService.updateUserEmail(initiator: self, target: self, newEmail: newEmail),
            throwsA(
              predicate((e) =>
                  e is PolicyViolationException<UpdateUserEmailUnauthorizedReason> && e.reason is EmailInvalidFormat),
            ),
          );
        });
        test('should be able to update a user\'s email to a new valid email', () async {
          final self = analyst;
          final newEmail = Email('new.email@example.com');
          await userAdministrationService.updateUserEmail(initiator: self, target: otherUser, newEmail: newEmail);
          final updatedUser = await userAdministrationService.viewUser(initiator: self, userId: otherUser.userId);
          expect(updatedUser!.email, equals(newEmail));
        });

        test('should be able to update an admin\'s email to a new valid email', () async {
          final self = analyst;
          final newEmail = Email('new.email@example.com');
          await userAdministrationService.updateUserEmail(initiator: self, target: otherAdmin, newEmail: newEmail);
          final updatedUser = await userAdministrationService.viewUser(initiator: self, userId: otherAdmin.userId);
          expect(updatedUser!.email, equals(newEmail));
        });
      });
    });
    group('validateUserEmail', () {
      group('valid email', () {
        test('should pass validation for a well-formed email', () {
          final email = Email('new.email@example.com');
          userAdministrationService.validateUserEmail(
            email,
            onValid: () {
              // If this callback is called, the email is valid.
            },
            onInvalid: (reason) {
              fail('Expected email to be valid, but got invalid reason: $reason');
            },
          );
        });
      });
      group('invalid email', () {
        test('should fail validation for an improperly formatted email', () {
          final email = Email('invalid-email');
          userAdministrationService.validateUserEmail(
            email,
            onValid: () {
              fail('Expected email to be invalid, but it was validated as valid.');
            },
            onInvalid: (reason) {
              expect(reason, isA<EmailInvalidFormat>());
            },
          );
        });
      });
    });
    group('authorizeUpdateUserEmail', () {
      group('User', () {
        test('should authorize updating own email', () {
          final self = user;
          final result = userAdministrationService.authorizeUpdateUserEmail(
            initiator: self,
            target: self,
            onAuthorized: () => true,
            onUnauthorized: (reason) => false,
          );
          expect(result, isTrue);
        });
        test('should not authorize updating another user\'s email', () {
          final result = userAdministrationService.authorizeUpdateUserEmail(
            initiator: user,
            target: otherUser,
            onAuthorized: () => true,
            onUnauthorized: (reason) => false,
          );
          expect(result, isFalse);
        });
        test('should not authorize updating an admin\'s email', () {
          final result = userAdministrationService.authorizeUpdateUserEmail(
            initiator: user,
            target: admin,
            onAuthorized: () => true,
            onUnauthorized: (reason) => false,
          );
          expect(result, isFalse);
        });
        test('should not authorize updating an analyst\'s email', () {
          final result = userAdministrationService.authorizeUpdateUserEmail(
            initiator: user,
            target: analyst,
            onAuthorized: () => true,
            onUnauthorized: (reason) => false,
          );
          expect(result, isFalse);
        });
      });
      group('Admin', () {
        test('should authorize updating own email', () {
          final self = admin;
          final result = userAdministrationService.authorizeUpdateUserEmail(
            initiator: self,
            target: self,
            onAuthorized: () => true,
            onUnauthorized: (reason) => false,
          );
          expect(result, isTrue);
        });
        test('should authorize updating a user\'s email', () {
          final result = userAdministrationService.authorizeUpdateUserEmail(
            initiator: admin,
            target: otherUser,
            onAuthorized: () => true,
            onUnauthorized: (reason) => false,
          );
          expect(result, isTrue);
        });
        test('should not authorize updating an analyst\'s email', () {
          final result = userAdministrationService.authorizeUpdateUserEmail(
            initiator: admin,
            target: analyst,
            onAuthorized: () => true,
            onUnauthorized: (reason) => false,
          );
          expect(result, isFalse);
        });
      });
      group('Analyst', () {
        test('should authorize updating own email', () {
          final self = analyst;
          final result = userAdministrationService.authorizeUpdateUserEmail(
            initiator: self,
            target: self,
            onAuthorized: () => true,
            onUnauthorized: (reason) => false,
          );
          expect(result, isTrue);
        });
        test('should authorize updating a user\'s email', () {
          final result = userAdministrationService.authorizeUpdateUserEmail(
            initiator: analyst,
            target: otherUser,
            onAuthorized: () => true,
            onUnauthorized: (reason) => false,
          );
          expect(result, isTrue);
        });
        test('should authorize updating an admin\'s email', () {
          final result = userAdministrationService.authorizeUpdateUserEmail(
            initiator: analyst,
            target: otherAdmin,
            onAuthorized: () => true,
            onUnauthorized: (reason) => false,
          );
          expect(result, isTrue);
        });
        test('should authorize updating another analyst\'s email', () {
          final result = userAdministrationService.authorizeUpdateUserEmail(
            initiator: analyst,
            target: otherAnalyst,
            onAuthorized: () => true,
            onUnauthorized: (reason) => false,
          );
          expect(result, isTrue);
        });
      });
    });
    group('updateUserPassword', () {
      group('User', () {
        test('should be able to update own password to a new valid password', () async {
          final self = user;
          final newPassword = Password('NewPassword123!');
          await userAdministrationService.updateUserPassword(initiator: self, target: self, newPassword: newPassword);
          // No direct way to verify password, but no exception means success
        });
        test('should not be able to update own password to an invalid password', () async {
          final self = user;
          final newPassword = Password('short');
          expect(
            () async => await userAdministrationService.updateUserPassword(
                initiator: self, target: self, newPassword: newPassword),
            throwsA(
              predicate((e) =>
                  e is PolicyViolationException<UpdateUserPasswordUnauthorizedReason> && e.reason is PasswordTooShort),
            ),
          );
        });
        test('should not be able to update another user\'s password', () async {
          final self = user;
          final newPassword = Password('NewPassword123!');
          expect(
            () async => await userAdministrationService.updateUserPassword(
                initiator: self, target: otherUser, newPassword: newPassword),
            throwsA(
              predicate((e) =>
                  e is PolicyViolationException<UpdateUserPasswordUnauthorizedReason> &&
                  e.reason is CanOnlyUpdatePasswordOnSelf),
            ),
          );
        });
        test('should not be able to update an admin\'s password', () async {
          final self = user;
          final newPassword = Password('NewPassword123!');
          expect(
            () async => await userAdministrationService.updateUserPassword(
                initiator: self, target: otherAdmin, newPassword: newPassword),
            throwsA(
              predicate((e) =>
                  e is PolicyViolationException<UpdateUserPasswordUnauthorizedReason> &&
                  e.reason is CanOnlyUpdatePasswordOnSelf),
            ),
          );
        });
        test('should not be able to update an analyst\'s password', () async {
          final self = user;
          final newPassword = Password('NewPassword123!');
          expect(
            () async => await userAdministrationService.updateUserPassword(
                initiator: self, target: otherAnalyst, newPassword: newPassword),
            throwsA(
              predicate((e) =>
                  e is PolicyViolationException<UpdateUserPasswordUnauthorizedReason> &&
                  e.reason is CanOnlyUpdatePasswordOnSelf),
            ),
          );
        });
      });
      group('Admin', () {
        test('should be able to update own password to a new valid password', () async {
          final self = admin;
          final newPassword = Password('NewPassword123!');
          await userAdministrationService.updateUserPassword(initiator: self, target: self, newPassword: newPassword);
        });
        test('should not be able to update own password to an invalid password', () async {
          final self = admin;
          final newPassword = Password('short');
          expect(
            () async => await userAdministrationService.updateUserPassword(
                initiator: self, target: self, newPassword: newPassword),
            throwsA(
              predicate((e) =>
                  e is PolicyViolationException<UpdateUserPasswordUnauthorizedReason> && e.reason is PasswordTooShort),
            ),
          );
        });
        test('should be able to update a user\'s password to a new valid password', () async {
          final self = admin;
          final newPassword = Password('NewPassword123!');
          await userAdministrationService.updateUserPassword(
              initiator: self, target: otherUser, newPassword: newPassword);
        });
        test('should be able to update another admin\'s password to a new valid password', () async {
          final self = admin;
          final newPassword = Password('NewPassword123!');
          await userAdministrationService.updateUserPassword(
              initiator: self, target: otherAdmin, newPassword: newPassword);
        });
        test('should not be able to update an analyst\'s password', () async {
          final self = admin;
          final newPassword = Password('NewPassword123!');
          expect(
            () async => await userAdministrationService.updateUserPassword(
                initiator: self, target: otherAnalyst, newPassword: newPassword),
            throwsA(
              predicate((e) =>
                  e is PolicyViolationException<UpdateUserPasswordUnauthorizedReason> &&
                  e.reason is CanOnlyUpdatePasswordOnSelf),
            ),
          );
        });
      });
      group('Analyst', () {
        test('should be able to update own password to a new valid password', () async {
          final self = analyst;
          final newPassword = Password('NewPassword123!');
          await userAdministrationService.updateUserPassword(initiator: self, target: self, newPassword: newPassword);
        });
        test('should not be able to update own password to an invalid password', () async {
          final self = analyst;
          final newPassword = Password('short');
          expect(
            () async => await userAdministrationService.updateUserPassword(
                initiator: self, target: self, newPassword: newPassword),
            throwsA(
              predicate((e) =>
                  e is PolicyViolationException<UpdateUserPasswordUnauthorizedReason> && e.reason is PasswordTooShort),
            ),
          );
        });
        test('should not be able to update another user\'s password', () async {
          final self = analyst;
          final newPassword = Password('NewPassword123!');
          expect(
            () async => await userAdministrationService.updateUserPassword(
                initiator: self, target: otherUser, newPassword: newPassword),
            throwsA(
              predicate((e) =>
                  e is PolicyViolationException<UpdateUserPasswordUnauthorizedReason> &&
                  e.reason is CanOnlyUpdatePasswordOnSelf),
            ),
          );
        });
        test('should not be able to update an admin\'s password', () async {
          final self = analyst;
          final newPassword = Password('NewPassword123!');
          expect(
            () async => await userAdministrationService.updateUserPassword(
                initiator: self, target: otherAdmin, newPassword: newPassword),
            throwsA(
              predicate((e) =>
                  e is PolicyViolationException<UpdateUserPasswordUnauthorizedReason> &&
                  e.reason is CanOnlyUpdatePasswordOnSelf),
            ),
          );
        });
        test('should not be able to update an analyst\'s password', () async {
          final self = analyst;
          final newPassword = Password('NewPassword123!');
          expect(
            () async => await userAdministrationService.updateUserPassword(
                initiator: self, target: otherAnalyst, newPassword: newPassword),
            throwsA(
              predicate((e) =>
                  e is PolicyViolationException<UpdateUserPasswordUnauthorizedReason> &&
                  e.reason is CanOnlyUpdatePasswordOnSelf),
            ),
          );
        });
      });
    });
    group('validateUserPassword', () {
      group('valid password', () {
        
      });
      group('invalid password', () {});
    });
    group('generateUserPassword', () {
      group('generates password of correct length', () {});
      group('generates different passwords on subsequent calls', () {});
    });
    group('authorizeUpdateUserPassword', () {
      group('User', () {});
      group('Admin', () {});
      group('Analyst', () {});
    });
  });
}
