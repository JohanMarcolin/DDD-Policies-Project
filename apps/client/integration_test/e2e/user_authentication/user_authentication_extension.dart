part of 'user_authentication_test.dart';

extension UserAuthenticationExtension on WidgetTester {
  /// Tests the login functionality for a user.
  ///
  /// Starts the app, logs in with the provided user's credentials, and verifies
  /// that the UserAdministrationView and UserList are displayed after a successful login.
  ///
  /// - [user]: The user whose login functionality is being tested.
  Future<void> testLogin(UserTestFixture user) async {
    final roleName = user.role.name;
    await startApp();
    await login(email: user.email, password: user.password);
    final userAdministrationView = find.byType(UserAdministrationView);

    expect(
      userAdministrationView,
      findsOne,
      reason: 'Should show UserAdministrationView after successful login for $roleName',
    );
    expect(
      userAdministrationView.findDescendant(UserList),
      findsOne,
      reason: 'Should show UserList in UserAdministrationView for $roleName',
    );
  }

  /// Tests session persistence for a user.
  ///
  /// Restarts the app and verifies that the user remains logged in, ensuring
  /// that the UserAdministrationView is displayed directly without showing the LoginView.
  ///
  /// - [user]: The user whose session persistence is being tested.
  Future<void> testSessionPersistence(UserTestFixture user) async {
    final roleName = user.role.name;
    await startApp();

    expect(
      find.byType(LoginView),
      findsNothing,
      reason: 'LoginView should not be shown after app restart for $roleName',
    );

    expect(
      find.byType(UserAdministrationView),
      findsOne,
      reason: 'Should show UserAdministrationView directly after app restart for $roleName',
    );
  }

  /// Tests the logout functionality for a user.
  ///
  /// Simulates a logout action and verifies that the LoginView is displayed after logout.
  ///
  /// - [user]: The user whose logout functionality is being tested.
  Future<void> testLogout(UserTestFixture user) async {
    await tap(find.byIcon(Icons.logout));
    await pumpAndSettle();
    expect(find.byType(LoginView), findsOne, reason: 'Should show LoginView after logout for ${user.role.name}');
  }
}
