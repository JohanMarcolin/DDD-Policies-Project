import 'package:domain/policies/action_authorization_policies/user_administration/user_administration_policy.dart';
import 'package:domain/policies/policy_violation_exception.dart';
import 'package:test/test.dart';
import 'package:test_utils/mocks/mock_users.dart';

void main() {
  final policy = UpdateUserPasswordPolicy();

  group('UpdateUserPasswordPolicy', () {
    group('isAuthorized', () {
      group('User', () {
        test('should authorize updating own password', () {
          expect(policy.isAuthorized(mockUser, mockUser), isTrue);
        });

        for (final other in [otherMockUser, mockAdmin, mockAnalyst]) {
          test('should not authorize updating ${other.role.name} password', () {
            expect(policy.isAuthorized(mockUser, other), isFalse);
          });
        }
      });
      group('Admin', () {
        test('should authorize updating own password', () {
          expect(policy.isAuthorized(mockAdmin, mockAdmin), isTrue);
        });

        for (final other in [otherMockAdmin, mockUser]) {
          test('should authorize updating ${other.role.name} password', () {
            expect(policy.isAuthorized(mockAdmin, other), isTrue);
          });
        }
        test('should not authorize updating analyst password', () {
          expect(policy.isAuthorized(mockAdmin, mockAnalyst), isFalse);
        });
      });
      group('Analyst', () {
        test('should authorize updating own password', () {
          expect(policy.isAuthorized(mockAnalyst, mockAnalyst), isTrue);
        });

        for (final other in [mockUser, mockAdmin, otherMockAnalyst]) {
          test('should authorize updating ${other.role.name} password', () {
            expect(policy.isAuthorized(mockAnalyst, other), isTrue);
          });
        }
      });
    });
    group('apply', () {
      group('User', () {
        test('should authorize updating own password', () {
          policy.apply(
            actor: mockUser,
            resource: mockUser,
            onAuthorized: () {},
            onUnauthorized: (_) => fail('User should be able to update own password'),
          );
        });

        for (final other in [otherMockUser, mockAdmin, mockAnalyst]) {
          test('should not authorize updating ${other.role.name} password', () {
            policy.apply(
              actor: mockUser,
              resource: other,
              onAuthorized: () => fail('User should not be able to update ${other.role.name} password'),
              onUnauthorized: (reason) => expect(reason, isA<CanOnlyUpdatePasswordOnSelf>()),
            );
          });
        }
      });
      group('Admin', () {
        test('should authorize updating own password', () {
          policy.apply(
            actor: mockAdmin,
            resource: mockAdmin,
            onAuthorized: () {},
            onUnauthorized: (_) => fail('Admin should be able to update own password'),
          );
        });

        for (final other in [otherMockAdmin, mockUser]) {
          test('should authorize updating ${other.role.name} password', () {
            policy.apply(
              actor: mockAdmin,
              resource: other,
              onAuthorized: () {},
              onUnauthorized: (_) => fail('Admin should be able to update ${other.role.name} password'),
            );
          });
        }
        test('should not authorize updating analyst password', () {
          policy.apply(
            actor: mockAdmin,
            resource: mockAnalyst,
            onAuthorized: () => fail('Admin should not be able to update analyst password'),
            onUnauthorized: (reason) => expect(reason, isA<CannotUpdatePasswordOnAnalyst>()),
          );
        });
      });
      group('Analyst', () {
        test('should authorize updating own password', () {
          policy.apply(
            actor: mockAnalyst,
            resource: mockAnalyst,
            onAuthorized: () {},
            onUnauthorized: (_) => fail('Analyst should be able to update own password'),
          );
        });

        for (final other in [mockUser, mockAdmin, otherMockAnalyst]) {
          test('should authorize updating ${other.role.name} password', () {
            policy.apply(
              actor: mockAnalyst,
              resource: other,
              onAuthorized: () {},
              onUnauthorized: (_) => fail('Analyst should be able to update ${other.role.name} password'),
            );
          });
        }
      });
    });
    group('enforce', () {
      group('User', () {
        test('should authorize updating own password', () {
          expect(policy.enforce(mockUser, mockUser, onAuthorized: () => true), isTrue);
        });

        for (final other in [otherMockUser, mockAdmin, mockAnalyst]) {
          test('should not authorize updating ${other.role.name} password', () {
            expect(
              () => policy.enforce(mockUser, other, onAuthorized: () => true),
              throwsA(predicate((e) => e is PolicyViolationException && e.reason is CanOnlyUpdatePasswordOnSelf)),
            );
          });
        }
      });
      group('Admin', () {
        test('should authorize updating own password', () {
          expect(policy.enforce(mockAdmin, mockAdmin, onAuthorized: () => true), isTrue);
        });

        for (final other in [otherMockAdmin, mockUser]) {
          test('should authorize updating ${other.role.name} password', () {
            expect(policy.enforce(mockAdmin, other, onAuthorized: () => true), isTrue);
          });
        }
        test('should not authorize updating analyst password', () {
          expect(
            () => policy.enforce(mockAdmin, mockAnalyst, onAuthorized: () => true),
            throwsA(predicate((e) => e is PolicyViolationException && e.reason is CannotUpdatePasswordOnAnalyst)),
          );
        });
      });
      group('Analyst', () {
        test('should authorize updating own password', () {
          expect(policy.enforce(mockAnalyst, mockAnalyst, onAuthorized: () => true), isTrue);
        });

        for (final other in [mockUser, mockAdmin, otherMockAnalyst]) {
          test('should authorize updating ${other.role.name} password', () {
            expect(policy.enforce(mockAnalyst, other, onAuthorized: () => true), isTrue);
          });
        }
      });
    });
  });
}
