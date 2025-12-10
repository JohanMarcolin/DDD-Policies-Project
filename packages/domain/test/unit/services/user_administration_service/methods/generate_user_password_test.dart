import 'package:domain/services/user_administration/user_administration_service.dart';
import 'package:test/test.dart';
import '../../../utils/services/user_administration_service.dart';

void main() {
  late UserAdministrationService userAdministrationService;

  setUp(() {
    userAdministrationService = createTestUserAdministrationService();
  });

  group('UserAdministrationService', () {
    group('generateUserPassword', () {
      test('generates a valid password', () {
        final password = userAdministrationService.generateUserPassword();
        final result = userAdministrationService.validateUserPassword(
          password,
          onValid: () => true,
          onInvalid: (_) => false,
        );
        expect(result, isTrue);
      });
      test('generates different passwords on subsequent calls', () {
        final password1 = userAdministrationService.generateUserPassword();
        final password2 = userAdministrationService.generateUserPassword();
        expect(password1.value, isNot(equals(password2.value)));
      });
    });
  });
}
