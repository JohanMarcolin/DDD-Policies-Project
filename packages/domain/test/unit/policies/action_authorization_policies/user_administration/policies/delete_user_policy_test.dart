import 'package:domain/policies/action_authorization_policies/user_administration/user_administration_policy.dart';
import 'package:domain/policies/policy_violation_exception.dart';
import 'package:test/test.dart';
import 'package:test_utils/mocks/mock_users.dart'
    show mockUser, otherMockUser, mockAdmin, otherMockAdmin, mockAnalyst, otherMockAnalyst;

void main() {
  final policy = DeleteUserPolicy();

  group('DeleteUserPolicy', () {
    group('isAuthorized', () {
      group('User', () {
        test('should authorize deleting self', () {
          expect(policy.isAuthorized(mockUser, mockUser), isTrue, reason: 'User should be able to delete self');
        });

        for (final other in [otherMockUser, mockAdmin, mockAnalyst]) {
          test('should not authorize deleting ${other.role.name}', () {
            expect(policy.isAuthorized(mockUser, other), isFalse,
                reason: 'User should not be able to delete ${other.role.name}');
          });
        }
      });
      group('Admin', () {
        test('should authorize deleting self', () {
          expect(policy.isAuthorized(mockAdmin, mockAdmin), isTrue, reason: 'Admin should be able to delete self');
        });

        for (final other in [mockUser, otherMockAdmin]) {
          test('should authorize deleting ${other.role.name}', () {
            expect(policy.isAuthorized(mockAdmin, other), isTrue,
                reason: 'Admin should be able to delete ${other.role.name}');
          });
        }
        test('should not authorize deleting analyst', () {
          expect(policy.isAuthorized(mockAdmin, mockAnalyst), isFalse,
              reason: 'Admin should not be able to delete analyst');
        });
      });
      group('Analyst', () {
        test('should not authorize deleting self', () {
          expect(policy.isAuthorized(mockAnalyst, mockAnalyst), isFalse,
              reason: 'Analyst should not be able to delete self');
        });

        for (final other in [mockUser, mockAdmin, otherMockAnalyst]) {
          test('should authorize deleting ${other.role.name}', () {
            expect(policy.isAuthorized(mockAnalyst, other), isTrue,
                reason: 'Analyst should be able to delete ${other.role.name}');
          });
        }
      });
    });
    group('apply', () {
      group('User', () {
        test('should authorize deleting self', () {
          policy.apply(
            actor: mockUser,
            resource: mockUser,
            onAuthorized: () {},
            onUnauthorized: (_) => fail('User should be able to delete self'),
          );
        });

        for (final other in [otherMockUser, mockAdmin, mockAnalyst]) {
          test('should not authorize deleting ${other.role.name}', () {
            policy.apply(
              actor: mockUser,
              resource: other,
              onAuthorized: () => fail('User should not be able to delete ${other.role.name}'),
              onUnauthorized: (reason) => expect(reason, isA<CanOnlyDeleteSelf>()),
            );
          });
        }
      });
      group('Admin', () {
        test('should authorize deleting self', () {
          policy.apply(
            actor: mockAdmin,
            resource: mockAdmin,
            onAuthorized: () {},
            onUnauthorized: (_) => fail('Admin should be able to delete self'),
          );
        });

        for (final other in [mockUser, otherMockAdmin]) {
          test('should authorize deleting ${other.role.name}', () {
            policy.apply(
              actor: mockAdmin,
              resource: other,
              onAuthorized: () {},
              onUnauthorized: (_) => fail('Admin should be able to delete ${other.role.name}'),
            );
          });
        }
        test('should not authorize deleting analyst', () {
          policy.apply(
            actor: mockAdmin,
            resource: mockAnalyst,
            onAuthorized: () => fail('Admin should not be able to delete analyst'),
            onUnauthorized: (reason) => expect(reason, isA<CannotDeleteAnalyst>()),
          );
        });
      });
      group('Analyst', () {
        test('should not authorize deleting self', () {
          policy.apply(
            actor: mockAnalyst,
            resource: mockAnalyst,
            onAuthorized: () => fail('Analyst should not be able to delete self'),
            onUnauthorized: (reason) => expect(reason, isA<CannotDeleteSelf>()),
          );
        });

        for (final other in [mockUser, mockAdmin, otherMockAnalyst]) {
          test('should authorize deleting ${other.role.name}', () {
            policy.apply(
              actor: mockAnalyst,
              resource: other,
              onAuthorized: () {},
              onUnauthorized: (_) => fail('Analyst should be able to delete ${other.role.name}'),
            );
          });
        }
      });
    });
    group('enforce', () {
      group('User', () {
        test('should authorize deleting self', () {
          expect(policy.enforce(mockUser, mockUser, onAuthorized: () => true), isTrue,
              reason: 'User should be able to delete self');
        });

        for (final other in [otherMockUser, mockAdmin, mockAnalyst]) {
          test('should not authorize deleting ${other.role.name}', () {
            expect(
              () => policy.enforce(mockUser, other, onAuthorized: () => true),
              throwsA(predicate((e) => e is PolicyViolationException && e.reason is CanOnlyDeleteSelf)),
              reason: 'User should not be able to delete ${other.role.name}',
            );
          });
        }
      });
      group('Admin', () {
        test('should authorize deleting self', () {
          expect(policy.enforce(mockAdmin, mockAdmin, onAuthorized: () => true), isTrue,
              reason: 'Admin should be able to delete self');
        });

        for (final other in [mockUser, otherMockAdmin]) {
          test('should authorize deleting ${other.role.name}', () {
            expect(policy.enforce(mockAdmin, other, onAuthorized: () => true), isTrue,
                reason: 'Admin should be able to delete ${other.role.name}');
          });
        }
        test('should not authorize deleting analyst', () {
          expect(
            () => policy.enforce(mockAdmin, mockAnalyst, onAuthorized: () => true),
            throwsA(predicate((e) => e is PolicyViolationException && e.reason is CannotDeleteAnalyst)),
            reason: 'Admin should not be able to delete analyst',
          );
        });
      });
      group('Analyst', () {
        test('should not authorize deleting self', () {
          expect(
            () => policy.enforce(mockAnalyst, mockAnalyst, onAuthorized: () => true),
            throwsA(predicate((e) => e is PolicyViolationException && e.reason is CannotDeleteSelf)),
            reason: 'Analyst should not be able to delete self',
          );
        });

        for (final other in [mockUser, mockAdmin, otherMockAnalyst]) {
          test('should authorize deleting ${other.role.name}', () {
            expect(policy.enforce(mockAnalyst, other, onAuthorized: () => true), isTrue,
                reason: 'Analyst should be able to delete ${other.role.name}');
          });
        }
      });
    });
  });
}
