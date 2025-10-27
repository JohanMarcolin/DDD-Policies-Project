import 'package:client/infrastructure/apis/auth_api.dart';
import 'package:client/infrastructure/auth_bloc/auth_bloc.dart';
import 'package:client/infrastructure/services/auth_token_service.dart';
import 'package:client/presentation/views/user_administration_view/blocs/users_view_bloc/user_administration_view_bloc.dart';
import 'package:client/presentation/views/user_administration_view/components/update_user_email_icon.dart';
import 'package:client/presentation/widgets/action_icon.dart';
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
  Future<void> renderUpdateUserEmailIcon({
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
            child: Material(child: UpdateUserEmailIcon(user: targetUser)),
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

  group('UpdateUserEmailIcon', () {
    for (final currentUser in mockUsers) {
      for (final targetUser in mockUsers) {
        group(
          currentUser.isSameAs(targetUser)
              ? '${currentUser.role.name} acting on self'
              : '${currentUser.role.name} acting on ${targetUser.role.name}',
          () {
            final canUpdateEmail = UpdateUserEmailPolicy().authorize(
              currentUser,
              targetUser,
            );
            testWidgets(
              'should display ${canUpdateEmail.isAuthorized ? 'solid' : 'greyed out'} action icon',
              (WidgetTester tester) async {
                await tester.renderUpdateUserEmailIcon(
                  currentUser: currentUser,
                  targetUser: targetUser,
                );

                final updateEmailIcon = find.byType(UpdateUserEmailIcon);
                expect(updateEmailIcon, findsOne);

                final actionIcon = updateEmailIcon.findDescendant(ActionIcon);
                expect(actionIcon, findsOne);
                final actionIconWidget = tester.widget<ActionIcon>(actionIcon);

                switch (canUpdateEmail) {
                  case Authorized():
                    expect(actionIconWidget.isGreyedOut, isFalse);
                  case Unauthorized():
                    expect(actionIconWidget.isGreyedOut, isTrue);
                }
              },
            );
          },
        );
      }
    }
  });
}
