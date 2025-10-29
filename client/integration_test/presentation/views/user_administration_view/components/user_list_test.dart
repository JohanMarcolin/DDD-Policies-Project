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
late List<User> users;

extension on WidgetTester {
  Future<void> renderUserList() async {
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
            child: Material(child: UserList(users: users)),
          ),
        ),
      ),
    );
  }
}

Future<void> main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    currentUser = mockUser;
    mockUserRepository = MockUserRepository();
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
    users = mockUsers;
  });

  group('userList', () {
    testWidgets('displays user list with all users', (
      WidgetTester tester,
    ) async {
      await tester.renderUserList();

      final userList = find.byType(UserList);
      expect(userList, findsOne);

      expect(userList.findDescendant(UserTile), findsExactly(users.length));

      for (final user in users) {
        final userTileFinder = find.descendant(
          of: userList,
          matching: find.byWidgetPredicate((widget) {
            return widget is UserTile && widget.user.userId == user.userId;
          }),
        );
        expect(userTileFinder, findsOne);
      }
    });
  });
}
