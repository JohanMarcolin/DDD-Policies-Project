import 'package:client/infrastructure/auth_bloc/auth_bloc.dart';
import 'package:client/presentation/views/login_view/login_view.dart';
import 'package:client/presentation/views/user_administration_view/blocs/users_view_bloc/user_administration_view_bloc.dart';
import 'package:client/presentation/views/user_administration_view/user_administration_view.dart';
import 'package:domain/entities/user.dart';
import 'package:domain/policies/action_policies/action_policy.dart';
import 'package:domain/policies/validation_policies/validation_policy.dart';
import 'package:domain/services/user_administration/user_administration_service.dart';
import 'package:domain/value_objects/email.dart';
import 'package:domain/value_objects/id.dart';
import 'package:domain/value_objects/password.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:client/main.dart' as app;
import 'package:global_utils/user_test_fixture.dart';

import '../../../test/bloc/infrastructure/auth_bloc_test.dart';
import '../../../test/bloc/presentation/user_administration_view/mock_user_administration_view_bloc_factory.dart';
import '../../../test/bloc/utils/mock_users.dart' show mockUser;
import 'widget_finder_extensions.dart';

/// Extension on [WidgetTester] providing utilities to render widgets with stubbed [AuthBloc]
/// and [UserAdministrationViewBloc] BLoCs.
///
/// This extension is intended for integration tests that require injecting mock or stubbed
/// implementations of authentication and user administration logic. It simplifies the setup
/// of widget trees with test-specific BLoC instances and dependencies, allowing tests to
/// control authentication state and user data.
///
/// Typical usage:
/// - Call [renderWidgetWithBlocStubs] to pump a widget wrapped in stubbed BLoC providers.
/// - Access [authBlocWithStubs] and [userAdministrationViewBlocWithStubs] for direct BLoC manipulation.
/// - Customize the injected `currentUser`, `mockAuthApi`, or `mockUserRepository` for specific test scenarios.
extension WidgetTesterRenderWidgetWithBlocStubsExtension on WidgetTester {
  static late AuthBloc _authBlocWithStubs;
  static late UserAdministrationViewBloc _userAdministrationViewBlocWithStubs;

  AuthBloc get authBlocWithStubs => _authBlocWithStubs;
  UserAdministrationViewBloc get userAdministrationViewBlocWithStubs => _userAdministrationViewBlocWithStubs;

  Future<void> renderWidgetWithBlocStubs({
    required Widget testWidget,
    User? mockCurrentUser,
    MockAuthApi? mockAuthApi,
    MockUserRepository? mockUserRepository,
  }) async {
    final currentUser = mockCurrentUser ?? mockUser;
    final userRepository = mockUserRepository ?? MockUserRepository();
    final authApi = mockAuthApi ?? MockAuthApi();

    _authBlocWithStubs = AuthBloc(authApi: authApi);

    final stubbedUserAdministrationService = _getStubbedUserAdministrationService(userRepository);

    _userAdministrationViewBlocWithStubs = _getStubbedUserAdministrationViewBloc(
      currentUser,
      stubbedUserAdministrationService,
    );

    await pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>.value(value: _authBlocWithStubs),
          BlocProvider<UserAdministrationViewBloc>.value(value: _userAdministrationViewBlocWithStubs),
        ],
        child: MaterialApp(home: Material(child: testWidget)),
      ),
    );
  }

  UserAdministrationViewBloc _getStubbedUserAdministrationViewBloc(
    User currentUser,
    UserAdministrationService stubbedUserAdministrationService,
  ) {
    return UserAdministrationViewBloc(
      currentUser: currentUser,
      userAdministrationService: stubbedUserAdministrationService,
    );
  }

  UserAdministrationService _getStubbedUserAdministrationService(MockUserRepository mockUserRepository) {
    return UserAdministrationService(
      userRepository: mockUserRepository,
      viewUserPolicy: ViewUserPolicy(),
      updateUserEmailPolicy: UpdateUserEmailPolicy(),
      updateUserPasswordPolicy: UpdateUserPasswordPolicy(),
      deleteUserPolicy: DeleteUserPolicy(),
      emailValidationPolicy: EmailValidationPolicy(),
      passwordValidationPolicy: PasswordValidationPolicy(),
    );
  }
}

/// Extension methods on [WidgetTester] for login and logout actions in tests.
extension WidgetTesterLoginExtension on WidgetTester {
  Future<void> login({required Email email, required Password password}) async {
    final loginView = find.byType(LoginView);

    expect(loginView, findsOne, reason: 'Should show LoginView on app start');

    await enterText(loginView.findDescendant(LoginEmailField), email.value);
    await enterText(loginView.findDescendant(LoginPasswordField), password.value);

    await tap(loginView.findDescendant(LoginButton));
    await pumpAndSettle();
  }

  Future<void> logout() async {
    await tap(find.byIcon(Icons.logout));
    await pumpAndSettle();
    expect(find.byType(LoginView), findsOne, reason: 'Should show LoginView after logout');
  }
}

/// Extension methods on [WidgetTester] for finding and asserting visibility of UserTiles.
extension WidgetTesterTileFinderExtension on WidgetTester {
  Finder findUserTileByUserId(UserId userId) {
    return find.byWidgetPredicate((widget) => widget is UserTile && widget.user.userId == userId);
  }

  Finder findUserTileByEmail(Email email) {
    return find.byWidgetPredicate((widget) => widget is UserTile && widget.user.email.value == email.value);
  }

  Future<void> assertUserTileIsVisible({required UserTestFixture initiator, required UserTestFixture target}) async {
    await _assertUserTileVisibility(initiator: initiator, target: target, shouldBeVisible: true);
  }

  Future<void> assertUserTileIsNotVisible({required UserTestFixture initiator, required UserTestFixture target}) async {
    await _assertUserTileVisibility(initiator: initiator, target: target, shouldBeVisible: false);
  }

  Future<void> _assertUserTileVisibility({
    required UserTestFixture initiator,
    required UserTestFixture target,
    required bool shouldBeVisible,
  }) async {
    await startApp();
    await login(email: initiator.email, password: initiator.password);

    final targetUserTile = findUserTileByUserId(target.user.userId);
    expect(
      targetUserTile,
      shouldBeVisible ? findsOne : findsNothing,
      reason: 'UserTile ${shouldBeVisible ? "should" : "should not"} be found for ${target.user.role.name} target',
    );

    await logout();
  }
}

/// Extension method on [WidgetTester] to find the Confirm button in dialogs.
extension WidgetTesterConfirmButtonExtension on WidgetTester {
  Finder findConfirmButton() {
    return find.byWidgetPredicate(
      (widget) => widget is TextButton && widget.child is Text && (widget.child as Text).data == 'Confirm',
    );
  }
}

/// Extension method on [WidgetTester] to start the app for integration tests.
extension WidgetTesterStartAppExtension on WidgetTester {
  Future<void> startApp() async {
    app.main();
    await pumpAndSettle();
  }
}
