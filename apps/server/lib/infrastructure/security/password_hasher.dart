import 'package:bcrypt/bcrypt.dart';

import 'package:domain/value_objects/password.dart';

/// Provides password hashing and verification using `bcrypt`.
///
/// Used for securely storing and validating user passwords.
class PasswordHasher {
  /// Hashes the given [password] using and returns a [Password] containing the hash.
  Password hash(Password password) => Password(BCrypt.hashpw(password.value, BCrypt.gensalt()));

  /// Verifies that the [password] matches the [hashedPassword].
  /// Returns `true` if the password is valid, `false` otherwise.
  bool isVerified(Password password, Password hashedPassword) => BCrypt.checkpw(password.value, hashedPassword.value);
}
