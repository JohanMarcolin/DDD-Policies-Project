import 'package:bcrypt/bcrypt.dart';

import '../../../domain/value_objects/password.dart';

class PasswordHasher {
  Password hash(Password password) =>
      Password(BCrypt.hashpw(password.value, BCrypt.gensalt()));

  bool isVerified(Password password, Password hashedPassword) =>
      BCrypt.checkpw(password.value, hashedPassword.value);
}
