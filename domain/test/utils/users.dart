import 'package:domain/entities/admin.dart';
import 'package:domain/entities/analyst.dart';
import 'package:domain/entities/user.dart';
import 'package:domain/value_objects/email.dart';
import 'package:domain/value_objects/id.dart';

final analyst =
    Analyst(userId: UserId.generate(), email: Email('analyst1@example.com'));

final admin =
    Admin(userId: UserId.generate(), email: Email('admin1@example.com'));

final user = User(userId: UserId.generate(), email: Email('user1@example.com'));

final otherUser =
    User(userId: UserId.generate(), email: Email('user2@example.com'));
