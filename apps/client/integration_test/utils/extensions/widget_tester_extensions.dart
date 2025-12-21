import 'package:client/infrastructure/apis/auth_api.dart';
import 'package:client/infrastructure/auth_bloc/auth_bloc.dart';
import 'package:client/presentation/views/login_view/login_view.dart';
import 'package:client/presentation/views/user_administration_view/blocs/users_view_bloc/user_administration_view_bloc.dart';
import 'package:client/presentation/views/user_administration_view/user_administration_view.dart';
import 'package:domain/entities/user.dart';
import 'package:domain/services/user_administration/user_administration_service.dart';
import 'package:domain/value_objects/email.dart';
import 'package:domain/value_objects/id.dart';
import 'package:domain/value_objects/password.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:client/main.dart' as app;
import 'package:test_utils/domain/user_administration_service.dart';
import 'package:test_utils/mocks/mock_user_repository.dart';
import 'package:test_utils/mocks/mock_users.dart';
import 'package:test_utils/fixtures/user/user_test_fixture.dart';

import '../../../test_utils/mock_auth_api.dart';
import 'widget_finder_extensions.dart';

/// This extension supports integration tests by providing utilities to set up
/// widget trees with mock or stubbed authentication and user administration logic.
/// It enables tests to manipulate BLoC states and customize data for specific scenarios.
///
/// Typical usage:
/// - Call [renderWidgetWithBlocStubs] to pump a widget wrapped in stubbed BLoC providers.
/// - Access [authBlocWithStubs] and [userAdministrationViewBlocWithStubs] for direct BLoC manipulation.
/// - Customize the injected `currentUser`, `mockAuthApi`, or `mockUserRepository` for specific test scenarios.
extension RenderWidgetWithBlocStubsExtension on WidgetTester {
  static late AuthBloc _authBlocWithStubs;
  static late UserAdministrationViewBloc _userAdministrationViewBlocWithStubs;

  /// Provides access to the stubbed [AuthBloc] instance.
  AuthBloc get authBlocWithStubs => _authBlocWithStubs;

  /// Provides access to the stubbed [UserAdministrationViewBloc] instance.
  UserAdministrationViewBloc get userAdministrationViewBlocWithStubs => _userAdministrationViewBlocWithStubs;

  /// Renders a widget wrapped in stubbed BLoC providers for integration tests.
  ///
  /// - [testWidget]: The widget to render.
  /// - [mockCurrentUser]: Optional mock user.
  /// - [mockAuthApi]: Optional mock authentication api.
  /// - [mockUserRepository]: Optional mock user repository.
  Future<void> renderWidgetWithBlocStubs({
    required Widget testWidget,
    User? mockCurrentUser,
    MockAuthApi? mockAuthApi,
    MockUserRepository? mockUserRepository,
  }) async {
    final currentUser = mockCurrentUser ?? mockUser;
    final userRepository = mockUserRepository ?? MockUserRepository();
    final authApi = mockAuthApi ?? MockAuthApi();

    _authBlocWithStubs = AuthBloc(authApi: authApi as AuthApi);

    final stubbedUserAdministrationService = createStubbedUserAdministrationService(userRepository);

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

  /// Creates a stubbed [UserAdministrationViewBloc] for integration tests.
  ///
  /// - [currentUser]: The current user.
  /// - [stubbedUserAdministrationService]: The stubbed user administration service.
  UserAdministrationViewBloc _getStubbedUserAdministrationViewBloc(
    User currentUser,
    UserAdministrationService stubbedUserAdministrationService,
  ) {
    return UserAdministrationViewBloc(
      currentUser: currentUser,
      userAdministrationService: stubbedUserAdministrationService,
    );
  }
}

/// Extension methods on [WidgetTester] for login and logout actions in tests.
extension LoginExtension on WidgetTester {
  /// Simulates a login action by entering credentials and tapping the login button.
  ///
  /// - [email]: The email to enter.
  /// - [password]: The password to enter.
  Future<void> login({required Email email, required Password password}) async {
    final loginView = find.byType(LoginView);

    expect(loginView, findsOne, reason: 'Should show LoginView on app start');

    await enterText(loginView.findDescendant(LoginEmailField), email.value);
    await enterText(loginView.findDescendant(LoginPasswordField), password.value);

    await tap(loginView.findDescendant(LoginButton));
    await pumpAndSettle();
  }

  /// Simulates a logout action by tapping the logout button.
  Future<void> logout() async {
    await tap(find.byIcon(Icons.logout));
    await pumpAndSettle();
    expect(find.byType(LoginView), findsOne, reason: 'Should show LoginView after logout');
  }
}

/// Extension methods on [WidgetTester] for finding and verifying visibility of UserTiles.
extension UserTileFinderExtension on WidgetTester {
  /// Finds a [UserTile] widget by the user's ID.
  ///
  /// - [userId]: The ID of the user to find.
  Finder findUserTileByUserId(UserId userId) {
    return find.byWidgetPredicate((widget) => widget is UserTile && widget.user.userId == userId);
  }

  /// Finds a [UserTile] widget by the user's email.
  ///
  /// - [email]: The email of the user to find.
  Finder findUserTileByEmail(Email email) {
    return find.byWidgetPredicate((widget) => widget is UserTile && widget.user.email.value == email.value);
  }

  /// Verifies that a [UserTile] is visible for the given initiator and target users.
  ///
  /// - [initiator]: The user initiating the action.
  /// - [target]: The target user whose tile visibility is being checked.
  Future<void> verifyUserTileIsVisible({required UserTestFixture initiator, required UserTestFixture target}) async {
    await _verifyUserTileVisibility(initiator: initiator, target: target, shouldBeVisible: true);
  }

  /// Verifies that a [UserTile] is not visible for the given initiator and target users.
  ///
  /// - [initiator]: The user initiating the action.
  /// - [target]: The target user whose tile visibility is being checked.
  Future<void> verifyUserTileIsNotVisible({required UserTestFixture initiator, required UserTestFixture target}) async {
    await _verifyUserTileVisibility(initiator: initiator, target: target, shouldBeVisible: false);
  }

  Future<void> _verifyUserTileVisibility({
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
extension ConfirmButtonExtension on WidgetTester {
  /// Finds the Confirm button in a dialog.
  Finder findConfirmButton() {
    return find.byWidgetPredicate(
      (widget) => widget is TextButton && widget.child is Text && (widget.child as Text).data == 'Confirm',
    );
  }
}

/// Extension method on [WidgetTester] to start the app for integration tests.
extension StartAppExtension on WidgetTester {
  /// Starts (or restarts) the app and waits for it to settle.
  Future<void> startApp() async {
    app.main();
    await pumpAndSettle();
  }
}
