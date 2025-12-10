import 'package:domain/entities/admin.dart';
import 'package:domain/entities/analyst.dart';
import 'package:domain/entities/user.dart';
import 'package:domain/value_objects/email.dart';
import 'package:domain/value_objects/id.dart';

/// Shared mock user objects for domain unit tests.
///
/// Provides [User], [Admin], and [Analyst] instances with unique IDs and emails.

final analyst = Analyst(userId: UserId.generate(), email: Email('analyst1@example.com'));

final otherAnalyst = Analyst(userId: UserId.generate(), email: Email('analyst2@example.com'));

final admin = Admin(userId: UserId.generate(), email: Email('admin1@example.com'));

final otherAdmin = Admin(userId: UserId.generate(), email: Email('admin2@example.com'));

final user = User(userId: UserId.generate(), email: Email('user1@example.com'));

final otherUser = User(userId: UserId.generate(), email: Email('user2@example.com'));
