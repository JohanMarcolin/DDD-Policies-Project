import 'dart:convert';
import 'package:domain/value_objects/role.dart';
import 'package:test/test.dart';
import 'package:http/http.dart' as http;
import '../utils/factories/test_server_factory.dart';

void main() {
  group('Test Controller', () {
    setUp(() async {
      await TestServerFactory.start(enableTestRoutes: true);
    });

    tearDown(() async {
      await TestServerFactory.stop();
    });

    Future<http.Response> createAllTestFixtures() => http.post(
          Uri.parse('${TestServerFactory.baseUrl}/test/create-all-user-fixtures'),
        );

    test('creates all user fixtures', () async {
      final response = await createAllTestFixtures();
      expect(response.statusCode, 201);

      final body = jsonDecode(response.body);
      expect(body['isSuccess'], isTrue);

      final data = body['data'];
      expect(data, isList);

      for (final role in Role.values) {
        final fixture = data.firstWhere(
          (user) => user['role'] == role.name,
          orElse: () => null,
        );
        expect(fixture, isNotNull, reason: 'Fixture for role ${role.name} not found');
        expect(fixture, contains('userId'));
        expect(fixture, contains('email'));
        expect(fixture, contains('password'));
      }
    });

    test('deletes all user fixtures', () async {
      await createAllTestFixtures();

      final response = await http.delete(
        Uri.parse('${TestServerFactory.baseUrl}/test/delete-all-user-fixtures'),
      );
      expect(response.statusCode, 204);
    });

    test('creates user fixture for role', () async {
      for (final role in Role.values) {
        final response = await http.post(
          Uri.parse('${TestServerFactory.baseUrl}/test/create-user-fixture/${role.name}'),
        );
        expect(response.statusCode, 201);
        final body = jsonDecode(response.body);
        expect(body['isSuccess'], isTrue);

        final data = body['data'];
        expect(data['role'], role.name);
        expect(data, contains('userId'));
        expect(data, contains('email'));
        expect(data, contains('password'));
      }
    });
  });
}
