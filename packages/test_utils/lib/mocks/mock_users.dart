import 'package:domain/entities/admin.dart';
import 'package:domain/entities/analyst.dart';
import 'package:domain/entities/user.dart';
import 'package:domain/value_objects/email.dart';
import 'package:domain/value_objects/id.dart';

final mockUser = User(userId: UserId("user_id_1"), email: Email('user_email_11@example.com'));

final otherMockUser = User(userId: UserId("user_id_2"), email: Email('user_email_12@example.com'));

final mockAdmin = Admin(userId: UserId("admin_id_1"), email: Email('admin_email_1@example.com'));

final otherMockAdmin = Admin(userId: UserId("admin_id_2"), email: Email('admin_email_2@example.com'));

final mockAnalyst = Analyst(userId: UserId("analyst_id_1"), email: Email('analyst_email_1@example.com'));

final otherMockAnalyst = Analyst(userId: UserId("analyst_id_2"), email: Email('analyst_email_2@example.com'));

final mockUserPair = [mockUser, otherMockUser];

final allMockUserPairs = [mockUser, otherMockUser, mockAdmin, otherMockAdmin, mockAnalyst, otherMockAnalyst];
