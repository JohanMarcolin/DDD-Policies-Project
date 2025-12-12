import 'package:domain/policies/action_authorization_policies/user_administration/user_administration_policy.dart';
import 'package:domain/policies/policy_violation_exception.dart';
import 'package:test/test.dart';
import 'package:test_utils/mocks/mock_users.dart';

void main() {
  final policy = UpdateUserEmailPolicy();

  group('UpdateUserEmailPolicy', () {
    group('isAuthorized', () {
      group('User', () {
        test('should authorize updating own email', () {
          expect(policy.isAuthorized(mockUser, mockUser), isTrue, reason: 'User should be able to update own email');
        });

        for (final other in [otherMockUser, mockAdmin, mockAnalyst]) {
          test('should not authorize updating ${other.role.name} email', () {
            expect(policy.isAuthorized(mockUser, other), isFalse,
                reason: 'User should not be able to update ${other.role.name} email');
          });
        }
      });
      group('Admin', () {
        test('should authorize updating own email', () {
          expect(policy.isAuthorized(mockAdmin, mockAdmin), isTrue, reason: 'Admin should be able to update own email');
        });

        for (final other in [otherMockAdmin, mockUser]) {
          test('should authorize updating ${other.role.name} email', () {
            expect(policy.isAuthorized(mockAdmin, other), isTrue,
                reason: 'Admin should be able to update ${other.role.name} email');
          });
        }
        test('should not authorize updating analyst email', () {
          expect(policy.isAuthorized(mockAdmin, mockAnalyst), isFalse,
              reason: 'Admin should not be able to update analyst email');
        });
      });
      group('Analyst', () {
        test('should authorize updating own email', () {
          expect(policy.isAuthorized(mockAnalyst, mockAnalyst), isTrue,
              reason: 'Analyst should be able to update own email');
        });

        for (final other in [mockUser, mockAdmin, otherMockAnalyst]) {
          test('should authorize updating ${other.role.name} email', () {
            expect(policy.isAuthorized(mockAnalyst, other), isTrue,
                reason: 'Analyst should be able to update ${other.role.name} email');
          });
        }
      });
    });
    group('apply', () {
      group('User', () {
        test('should authorize updating own email', () {
          policy.apply(
            actor: mockUser,
            resource: mockUser,
            onAuthorized: () {},
            onUnauthorized: (_) => fail('User should be able to update own email'),
          );
        });

        for (final other in [otherMockUser, mockAdmin, mockAnalyst]) {
          test('should not authorize updating ${other.role.name} email', () {
            policy.apply(
              actor: mockUser,
              resource: other,
              onAuthorized: () => fail('User should not be able to update ${other.role.name} email'),
              onUnauthorized: (reason) => expect(reason, isA<CanOnlyUpdateEmailOnSelf>()),
            );
          });
        }
      });
      group('Admin', () {
        test('should authorize updating own email', () {
          policy.apply(
            actor: mockAdmin,
            resource: mockAdmin,
            onAuthorized: () {},
            onUnauthorized: (_) => fail('Admin should be able to update own email'),
          );
        });

        for (final other in [otherMockAdmin, mockUser]) {
          test('should authorize updating ${other.role.name} email', () {
            policy.apply(
              actor: mockAdmin,
              resource: other,
              onAuthorized: () {},
              onUnauthorized: (_) => fail('Admin should be able to update ${other.role.name} email'),
            );
          });
        }
        test('should not authorize updating analyst email', () {
          policy.apply(
            actor: mockAdmin,
            resource: mockAnalyst,
            onAuthorized: () => fail('Admin should not be able to update analyst email'),
            onUnauthorized: (reason) => expect(reason, isA<CannotUpdateEmailOnAnalyst>()),
          );
        });
      });
      group('Analyst', () {
        test('should authorize updating own email', () {
          policy.apply(
            actor: mockAnalyst,
            resource: mockAnalyst,
            onAuthorized: () {},
            onUnauthorized: (_) => fail('Analyst should be able to update own email'),
          );
        });

        for (final other in [mockUser, mockAdmin, otherMockAnalyst]) {
          test('should authorize updating ${other.role.name} email', () {
            policy.apply(
              actor: mockAnalyst,
              resource: other,
              onAuthorized: () {},
              onUnauthorized: (_) => fail('Analyst should be able to update ${other.role.name} email'),
            );
          });
        }
      });
    });
    group('enforce', () {
      group('User', () {
        test('should authorize updating own email', () {
          expect(policy.enforce(mockUser, mockUser, onAuthorized: () => true), isTrue,
              reason: 'User should be able to update own email');
        });

        for (final other in [otherMockUser, mockAdmin, mockAnalyst]) {
          test('should not authorize updating ${other.role.name} email', () {
            expect(
              () => policy.enforce(mockUser, other, onAuthorized: () => true),
              throwsA(predicate((e) => e is PolicyViolationException && e.reason is CanOnlyUpdateEmailOnSelf)),
              reason: 'User should not be able to update ${other.role.name} email',
            );
          });
        }
      });
      group('Admin', () {
        test('should authorize updating own email', () {
          expect(policy.enforce(mockAdmin, mockAdmin, onAuthorized: () => true), isTrue,
              reason: 'Admin should be able to update own email');
        });

        for (final other in [otherMockAdmin, mockUser]) {
          test('should authorize updating ${other.role.name} email', () {
            expect(policy.enforce(mockAdmin, other, onAuthorized: () => true), isTrue,
                reason: 'Admin should be able to update ${other.role.name} email');
          });
        }
        test('should not authorize updating analyst email', () {
          expect(
            () => policy.enforce(mockAdmin, mockAnalyst, onAuthorized: () => true),
            throwsA(predicate((e) => e is PolicyViolationException && e.reason is CannotUpdateEmailOnAnalyst)),
            reason: 'Admin should not be able to update analyst email',
          );
        });
      });
      group('Analyst', () {
        test('should authorize updating own email', () {
          expect(policy.enforce(mockAnalyst, mockAnalyst, onAuthorized: () => true), isTrue,
              reason: 'Analyst should be able to update own email');
        });

        for (final other in [mockUser, mockAdmin, otherMockAnalyst]) {
          test('should authorize updating ${other.role.name} email', () {
            expect(policy.enforce(mockAnalyst, other, onAuthorized: () => true), isTrue,
                reason: 'Analyst should be able to update ${other.role.name} email');
          });
        }
      });
    });
  });
}
