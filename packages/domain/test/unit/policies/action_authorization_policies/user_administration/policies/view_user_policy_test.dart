import 'package:domain/policies/action_authorization_policies/user_administration/user_administration_policy.dart';
import 'package:domain/policies/policy_violation_exception.dart';
import 'package:test/test.dart';
import 'package:test_utils/mocks/mock_users.dart';

void main() {
  final policy = ViewUserPolicy();

  group('ViewUserPolicy', () {
    group('isAuthorized', () {
      group('User', () {
        test('should authorize viewing own user', () {
          expect(policy.isAuthorized(mockUser, mockUser), isTrue, reason: 'User should be able to view own user');
        });

        for (final other in [otherMockUser, mockAdmin]) {
          test('should authorize viewing ${other.role.name}', () {
            expect(policy.isAuthorized(mockUser, other), isTrue,
                reason: 'User should be able to view ${other.role.name}');
          });
        }
        test('should not authorize viewing analyst', () {
          expect(policy.isAuthorized(mockUser, mockAnalyst), isFalse,
              reason: 'User should not be able to view analyst');
        });
      });
      group('Admin', () {
        test('should authorize viewing own user', () {
          expect(policy.isAuthorized(mockAdmin, mockAdmin), isTrue, reason: 'Admin should be able to view own user');
        });

        for (final other in [mockUser, otherMockAdmin]) {
          test('should authorize viewing ${other.role.name}', () {
            expect(policy.isAuthorized(mockAdmin, other), isTrue,
                reason: 'Admin should be able to view ${other.role.name}');
          });
        }
        test('should not authorize viewing analyst', () {
          expect(policy.isAuthorized(mockAdmin, mockAnalyst), isFalse,
              reason: 'Admin should not be able to view analyst');
        });
      });
      group('Analyst', () {
        test('should authorize viewing own user', () {
          expect(policy.isAuthorized(mockAnalyst, mockAnalyst), isTrue,
              reason: 'Analyst should be able to view own user');
        });

        for (final other in [mockUser, mockAdmin, otherMockAnalyst]) {
          test('should authorize viewing ${other.role.name}', () {
            expect(policy.isAuthorized(mockAnalyst, other), isTrue,
                reason: 'Analyst should be able to view ${other.role.name}');
          });
        }
      });
    });
    group('apply', () {
      group('User', () {
        test('should authorize viewing own user', () {
          policy.apply(
            actor: mockUser,
            resource: mockUser,
            onAuthorized: () {},
            onUnauthorized: (_) => fail('User should be able to view own user'),
          );
        });

        for (final other in [otherMockUser, mockAdmin]) {
          test('should authorize viewing ${other.role.name}', () {
            policy.apply(
              actor: mockUser,
              resource: other,
              onAuthorized: () {},
              onUnauthorized: (_) => fail('User should be able to view ${other.role.name}'),
            );
          });
        }
        test('should not authorize viewing analyst', () {
          policy.apply(
            actor: mockUser,
            resource: mockAnalyst,
            onAuthorized: () => fail('User should not be able to view analyst'),
            onUnauthorized: (reason) => expect(reason, isA<CannotViewAnalyst>()),
          );
        });
      });
      group('Admin', () {
        test('should authorize viewing own user', () {
          policy.apply(
            actor: mockAdmin,
            resource: mockAdmin,
            onAuthorized: () {},
            onUnauthorized: (_) => fail('Admin should be able to view own user'),
          );
        });

        for (final other in [otherMockAdmin, mockUser]) {
          test('should authorize viewing ${other.role.name}', () {
            policy.apply(
              actor: mockAdmin,
              resource: other,
              onAuthorized: () {},
              onUnauthorized: (_) => fail('Admin should be able to view ${other.role.name}'),
            );
          });
        }
        test('should not authorize viewing analyst', () {
          policy.apply(
            actor: mockAdmin,
            resource: mockAnalyst,
            onAuthorized: () => fail('Admin should not be able to view analyst'),
            onUnauthorized: (reason) => expect(reason, isA<CannotViewAnalyst>()),
          );
        });
      });
      group('Analyst', () {
        test('should authorize viewing own user', () {
          policy.apply(
            actor: mockAnalyst,
            resource: mockAnalyst,
            onAuthorized: () {},
            onUnauthorized: (_) => fail('Analyst should be able to view own user'),
          );
        });

        for (final other in [mockUser, mockAdmin, otherMockAnalyst]) {
          test('should authorize viewing ${other.role.name}', () {
            policy.apply(
              actor: mockAnalyst,
              resource: other,
              onAuthorized: () {},
              onUnauthorized: (_) => fail('Analyst should be able to view ${other.role.name}'),
            );
          });
        }
      });
    });
    group('enforce', () {
      group('User', () {
        test('should authorize viewing own user', () {
          expect(policy.enforce(mockUser, mockUser, onAuthorized: () => true), isTrue,
              reason: 'User should be able to view own user');
        });

        for (final other in [otherMockUser, mockAdmin]) {
          test('should authorize viewing ${other.role.name}', () {
            expect(policy.enforce(mockUser, other, onAuthorized: () => true), isTrue,
                reason: 'User should be able to view ${other.role.name}');
          });
        }
        test('should not authorize viewing analyst', () {
          expect(
            () => policy.enforce(mockUser, mockAnalyst, onAuthorized: () => true),
            throwsA(predicate((e) => e is PolicyViolationException && e.reason is CannotViewAnalyst)),
            reason: 'User should not be able to view analyst',
          );
        });
      });
      group('Admin', () {
        test('should authorize viewing own user', () {
          expect(policy.enforce(mockAdmin, mockAdmin, onAuthorized: () => true), isTrue,
              reason: 'Admin should be able to view own user');
        });

        for (final other in [otherMockAdmin, mockUser]) {
          test('should authorize viewing ${other.role.name}', () {
            expect(policy.enforce(mockAdmin, other, onAuthorized: () => true), isTrue,
                reason: 'Admin should be able to view ${other.role.name}');
          });
        }
        test('should not authorize viewing analyst', () {
          expect(
            () => policy.enforce(mockAdmin, mockAnalyst, onAuthorized: () => true),
            throwsA(predicate((e) => e is PolicyViolationException && e.reason is CannotViewAnalyst)),
            reason: 'Admin should not be able to view analyst',
          );
        });
      });
      group('Analyst', () {
        test('should authorize viewing own user', () {
          expect(policy.enforce(mockAnalyst, mockAnalyst, onAuthorized: () => true), isTrue,
              reason: 'Analyst should be able to view own user');
        });

        for (final other in [mockUser, mockAdmin, otherMockAnalyst]) {
          test('should authorize viewing ${other.role.name}', () {
            expect(policy.enforce(mockAnalyst, other, onAuthorized: () => true), isTrue,
                reason: 'Analyst should be able to view ${other.role.name}');
          });
        }
      });
    });
  });
}
