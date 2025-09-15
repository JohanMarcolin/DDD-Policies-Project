import 'package:test/test.dart';

import '../../../domain/entities/user.dart';
import '../../../domain/value_objects/email.dart';
import '../../../domain/value_objects/id.dart';
import '../../../domain/value_objects/role.dart';

void main() {
  group('User', () {
    final id1 = UserId('1');
    final id2 = UserId('2');
    final email1 = Email('user1@example.com');
    final email2 = Email('user2@example.com');

    test('equality is based on id', () {
      final userA = User(userId: id1, email: email1);
      final userB = User(userId: id1, email: email2);
      expect(userA, equals(userB));
    });

    test('isSameAs returns true for same id', () {
      final userA = User(userId: id1, email: email1);
      final userB = User(userId: id1, email: email2);
      expect(userA.isSameAs(userB), isTrue);
    });

    test('isSameAs returns false for different id', () {
      final userA = User(userId: id1, email: email1);
      final userB = User(userId: id2, email: email2);
      expect(userA.isSameAs(userB), isFalse);
    });

    test('isAdmin returns true only for admin role', () {
      final admin = User(userId: id1, email: email1, role: Role.admin);
      final user = User(userId: id2, email: email2, role: Role.user);
      expect(admin.isAdmin(), isTrue);
      expect(user.isAdmin(), isFalse);
    });

    test('isAnalyst returns true only for analyst role', () {
      final analyst = User(userId: id1, email: email1, role: Role.analyst);
      final user = User(userId: id2, email: email2, role: Role.user);
      expect(analyst.isAnalyst(), isTrue);
      expect(user.isAnalyst(), isFalse);
    });
  });
}
