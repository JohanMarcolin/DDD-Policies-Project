import 'package:client/infrastructure/apis/auth_api.dart';
import 'package:client/infrastructure/auth_bloc/auth_bloc.dart';
import 'package:client/infrastructure/services/auth_token_service.dart';
import 'package:client/presentation/views/user_administration_view/blocs/users_view_bloc/user_administration_view_bloc.dart';
import 'package:client/presentation/views/user_administration_view/user_administration_view.dart';
import 'package:domain/entities/user.dart';
import 'package:domain/policies/action_policies/action_policy.dart';
import 'package:domain/policies/validation_policies/validation_policy.dart';
import 'package:domain/repositories/user_repository.dart';
import 'package:domain/services/user_administration/user_administration_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../../test/bloc/utils/mock_users.dart';
import '../../../../utils/extensions/widget_finder_extension.dart';

class MockUserRepository extends Mock implements UserRepository {}

late MockUserRepository mockUserRepository;
late UserAdministrationViewBloc userAdministrationViewBloc;
late User currentUser;
late List<User> targetUsers;

extension on WidgetTester {
  Future<void> renderUserTile({
    required User currentUser,
    required User targetUser,
  }) async {
    userAdministrationViewBloc = UserAdministrationViewBloc(
      currentUser: currentUser,
      userAdministrationService: UserAdministrationService(
        userRepository: mockUserRepository,
        viewUserPolicy: ViewUserPolicy(),
        updateUserEmailPolicy: UpdateUserEmailPolicy(),
        updateUserPasswordPolicy: UpdateUserPasswordPolicy(),
        deleteUserPolicy: DeleteUserPolicy(),
        emailValidationPolicy: EmailValidationPolicy(),
        passwordValidationPolicy: PasswordValidationPolicy(),
      ),
    );

    await pumpWidget(
      BlocProvider<UserAdministrationViewBloc>.value(
        value: userAdministrationViewBloc,
        child: MaterialApp(
          home: MultiBlocProvider(
            providers: [
              BlocProvider<AuthBloc>.value(
                value: AuthBloc(
                  authApi: AuthApi(authTokenService: AuthTokenService()),
                ),
              ),
              BlocProvider<UserAdministrationViewBloc>.value(
                value: userAdministrationViewBloc,
              ),
            ],
            child: Material(child: UserTile(user: targetUser)),
          ),
        ),
      ),
    );
  }
}

Future<void> main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    mockUserRepository = MockUserRepository();
  });

  group('UserTile', () {
    testWidgets('displays user tile with all required components', (
      WidgetTester tester,
    ) async {
      await tester.renderUserTile(
        currentUser: mockUser,
        targetUser: otherMockUser,
      );

      final userTile = find.byType(UserTile);
      expect(userTile, findsOne);

      expect(find.text(otherMockUser.role.name), findsOne);
      expect(find.text(otherMockUser.email.value), findsOne);
      expect(userTile.findDescendant(UpdateUserEmailIcon), findsOne);
      expect(userTile.findDescendant(UpdateUserPasswordIcon), findsOne);
      expect(userTile.findDescendant(DeleteUserIcon), findsOne);
    });
  });
}
