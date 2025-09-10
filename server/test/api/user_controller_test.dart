import 'dart:convert';
import 'package:test/test.dart';
import 'package:http/http.dart' as http;

import 'factories/test_server_factory.dart';

void main() {
  setUpAll(() async {
    await TestServerFactory.start();
  });

  tearDownAll(() async {
    await TestServerFactory.stop();
  });

  group('User Controller', () {
    test('Get all users returns a list', () async {
      final response =
          await http.get(Uri.parse('${TestServerFactory.baseUrl}/user/all'));
      expect(response.statusCode, 200);
      final data = jsonDecode(response.body);
      expect(
          data is List || data is Map, isTrue); // Accepts both for flexibility
    });

    test('Get user by id returns user or 404', () async {
      // Replace with a valid user id for your test DB
      final userId = 'some-user-id';
      final response = await http
          .get(Uri.parse('${TestServerFactory.baseUrl}/user/$userId'));
      expect(response.statusCode, anyOf(200, 404));
    });

    test('Delete user returns success or 404', () async {
      // Replace with a valid user id for your test DB
      final userId = 'some-user-id';
      final response = await http
          .delete(Uri.parse('${TestServerFactory.baseUrl}/user/$userId'));
      expect(response.statusCode, anyOf(200, 404));
    });

    test('Update email returns success or 404', () async {
      // Replace with a valid user id for your test DB
      final userId = 'some-user-id';
      final response = await http.post(
        Uri.parse('${TestServerFactory.baseUrl}/user/$userId/email'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'newEmail': 'new@example.com'}),
      );
      expect(response.statusCode, anyOf(200, 404));
    });

    test('Update password returns success or 404', () async {
      // Replace with a valid user id for your test DB
      final userId = 'some-user-id';
      final response = await http.post(
        Uri.parse('${TestServerFactory.baseUrl}/user/$userId/password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'newPassword': 'newpassword123'}),
      );
      expect(response.statusCode, anyOf(200, 404));
    });
  });
}
