import 'package:client/infrastructure/apis/auth_api.dart';
import 'package:client/infrastructure/apis/test_api.dart';
import 'package:client/infrastructure/auth_bloc/auth_bloc.dart';
import 'package:client/presentation/views/login_view/login_view.dart';
import 'package:client/presentation/views/user_administration_view/blocs/users_view_bloc/user_administration_view_bloc.dart';
import 'package:client/presentation/views/user_administration_view/user_administration_view.dart';
import 'package:domain/entities/user.dart';
import 'package:domain/policies/action_policies/action_policy.dart';
import 'package:domain/policies/validation_policies/validation_policy.dart';
import 'package:domain/repositories/user_repository.dart';
import 'package:domain/services/user_administration/user_administration_service.dart';
import 'package:domain/value_objects/email.dart';
import 'package:domain/value_objects/id.dart';
import 'package:domain/value_objects/password.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:client/main.dart' as app;

import '../../../test/bloc/utils/mock_users.dart' show mockUser;
import 'widget_finder_extension.dart';

class MockAuthApi extends Mock implements AuthApi {}

class MockUserRepository extends Mock implements UserRepository {}

extension WidgetTesterExtension on WidgetTester {
  static late AuthBloc _authBlocWithStubs;
  static late UserAdministrationViewBloc _blocWithStubs;

  AuthBloc get authBlocWithStubs => _authBlocWithStubs;
  UserAdministrationViewBloc get blocWithStubs => _blocWithStubs;

  Future<void> renderWidgetWithBlocStubs({
    required Widget testWidget,
    User? currentUser,
    MockAuthApi? mockAuthApi,
    MockUserRepository? mockUserRepository,
  }) async {
    final user = currentUser ?? mockUser;
    final repository = mockUserRepository ?? MockUserRepository();
    final authApi = mockAuthApi ?? MockAuthApi();

    _authBlocWithStubs = AuthBloc(authApi: authApi);

    final stubbedUserAdministrationService =
        _getStubbedUserAdministrationService(repository);

    _blocWithStubs = _getStubbedUserAdministrationViewBloc(
      user,
      stubbedUserAdministrationService,
    );

    await pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>.value(value: _authBlocWithStubs),
          BlocProvider<UserAdministrationViewBloc>.value(value: _blocWithStubs),
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

  UserAdministrationService _getStubbedUserAdministrationService(
    MockUserRepository mockUserRepository,
  ) {
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

extension WidgetTesterLoginExtension on WidgetTester {
  Future<void> login({required Email email, required Password password}) async {
    final loginView = find.byType(LoginView);

    expect(loginView, findsOne, reason: 'Should show LoginView on app start');

    await enterText(loginView.findDescendant(LoginEmailField), email.value);
    await enterText(
      loginView.findDescendant(LoginPasswordField),
      password.value,
    );

    await tap(loginView.findDescendant(LoginButton));
    await pumpAndSettle();
  }
}

extension WidgetTesterTileFinderExtension on WidgetTester {
  Finder findUserTileByUserId(UserId userId) {
    return find.byWidgetPredicate(
      (widget) => widget is UserTile && widget.user.userId == userId,
    );
  }

  Finder findUserTileByEmail(Email email) {
    return find.byWidgetPredicate(
      (widget) => widget is UserTile && widget.user.email.value == email.value,
    );
  }

  Future<void> assertUserTileIsVisible({
    required UserTestFixture initiator,
    required UserTestFixture target,
  }) async {
    await _assertUserTileVisibility(
      initiator: initiator,
      target: target,
      shouldBeVisible: true,
    );
  }

  Future<void> assertUserTileIsNotVisible({
    required UserTestFixture initiator,
    required UserTestFixture target,
  }) async {
    await _assertUserTileVisibility(
      initiator: initiator,
      target: target,
      shouldBeVisible: false,
    );
  }

  Future<void> _assertUserTileVisibility({
    required UserTestFixture initiator,
    required UserTestFixture target,
    required bool shouldBeVisible,
  }) async {
    var targetUserId = target.user.userId;
    var targetUserRole = target.user.role.name;

    await startApp();
    await login(email: initiator.email, password: initiator.password);

    final targetUserTile = findUserTileByUserId(targetUserId);
    expect(
      targetUserTile,
      shouldBeVisible ? findsOne : findsNothing,
      reason:
          'UserTile ${shouldBeVisible ? "should" : "should not"} be found for $targetUserRole target',
    );

    await logout();
  }
}

extension WidgetTesterConfirmButtonExtension on WidgetTester {
  Finder findConfirmButton() {
    return find.byWidgetPredicate(
      (widget) =>
          widget is TextButton &&
          widget.child is Text &&
          (widget.child as Text).data == 'Confirm',
    );
  }
}

extension WidgetTesterStartAppExtension on WidgetTester {
  Future<void> startApp() async {
    app.main();
    await pumpAndSettle();
  }
}

extension WidgetTesterLogoutExtension on WidgetTester {
  Future<void> logout() async {
    await tap(find.byIcon(Icons.logout));
    await pumpAndSettle();
    expect(
      find.byType(LoginView),
      findsOne,
      reason: 'Should show LoginView after logout',
    );
  }
}
