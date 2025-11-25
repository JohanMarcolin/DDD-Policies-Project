import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:api_error_codes/api_error_codes.dart';
import 'package:uuid/uuid.dart';
import 'package:domain/entities/user.dart';
import 'package:domain/value_objects/email.dart';
import 'package:domain/value_objects/id.dart';
import 'package:domain/value_objects/role.dart';
import '../databases/in_memory_refresh_token_database.dart';
import '../http/exceptions/request_exceptions.dart';

typedef AccessToken = String;
typedef RefreshToken = String;

/// Service for generating, verifying, and revoking JWT access and refresh tokens.
///
/// Handles token signing, validation, and extraction of user claims for authentication and authorization.
class TokenService {
  TokenService({required InMemoryRefreshTokenDatabase refreshTokenDatabase})
      : _refreshTokenDatabase = refreshTokenDatabase;

  final InMemoryRefreshTokenDatabase _refreshTokenDatabase;

  static final SecretKey _key = SecretKey(Uuid().v4());
  final Duration _accessTokenExpiration = Duration(minutes: 5);
  final Duration _refreshTokenExpiration = Duration(days: 7);

  /// Generates a signed JWT [AccessToken] for the given [user].
  AccessToken generateAccessToken(User user) {
    final jwt = JWT({
      'id': user.userId.value,
      'username': user.email.value,
      'role': user.role.name,
    });
    return _signToken(jwt, _accessTokenExpiration);
  }

  /// Returns true if the [token] is a valid, false otherwise.
  bool isValidAccessToken(AccessToken token) {
    try {
      verifyAccessToken(token);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Verifies the [token] as a valid access token and returns the decoded [JWT].
  ///
  /// Throws [InvalidAccessTokenException] if verification fails.
  JWT verifyAccessToken(AccessToken token) {
    final verifiedAccessToken = _verifyToken(token);
    if (verifiedAccessToken == null) {
      throw InvalidAccessTokenException(TokenInvalidAccessToken());
    }
    return verifiedAccessToken;
  }

  /// Generates a signed JWT [RefreshToken] for the given [user] and stores it in the database.
  Future<RefreshToken> generateRefreshToken(User user) async {
    final jwt = JWT({'id': user.userId.value});
    final token = _signToken(jwt, _refreshTokenExpiration);
    await _refreshTokenDatabase.put(user.userId, token);
    return token;
  }

  /// Returns true if the [token] is valid, false otherwise.
  Future<bool> isValidRefreshToken(RefreshToken token) async {
    try {
      await verifyRefreshToken(token);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Verifies the [token] as a valid [RefreshToken] and returns the decoded [JWT].
  ///
  /// Throws [InvalidRefreshTokenException] if verification fails or the token is not found in the database.
  Future<JWT> verifyRefreshToken(RefreshToken token) async {
    final verifiedRefreshToken = _verifyToken(token);

    if (verifiedRefreshToken == null) {
      throw InvalidRefreshTokenException(TokenInvalidRefreshToken());
    }

    final tokenId = extractUserId(verifiedRefreshToken);

    final storedToken = await _refreshTokenDatabase.get(tokenId);

    if (storedToken == null || storedToken != token) {
      throw InvalidRefreshTokenException(TokenInvalidRefreshToken());
    }

    return verifiedRefreshToken;
  }

  /// Revokes the [RefreshToken] for the given [user] by deleting it from the database.
  Future<void> revokeRefreshToken(User user) async => await _refreshTokenDatabase.delete(user.userId);

  String _signToken(JWT token, Duration expiration) => token.sign(_key, expiresIn: expiration);

  JWT? _verifyToken(String token) => JWT.tryVerify(token, _key);

  /// Extracts the [UserId] from the [token] claims.
  ///
  /// Throws [InvalidUserClaimsException] if the claim is missing or invalid.
  UserId extractUserId(JWT token) {
    final claims = _extractTokenClaims(token);
    final id = claims['id'];
    if (id == null) {
      throw InvalidUserClaimsException(TokenInvalidUserIdInToken());
    }
    return UserId(id);
  }

  /// Extracts the user [Email] from the [token] claims.
  ///
  /// Throws [InvalidUserClaimsException] if the claim is missing or invalid.
  Email extractUserEmail(JWT token) {
    final claims = _extractTokenClaims(token);
    final email = claims['username'];
    if (email == null) {
      throw InvalidUserClaimsException(TokenInvalidUserEmailInToken());
    }
    return Email(email);
  }

  /// Extracts the user [Role] from the [token] claims.
  ///
  /// Throws [InvalidUserClaimsException] if the claim is missing or invalid.
  Role extractUserRole(JWT token) {
    final claims = _extractTokenClaims(token);
    final role = claims['role'];

    switch (role) {
      case 'analyst':
        return Role.analyst;
      case 'admin':
        return Role.admin;
      case 'user':
        return Role.user;
      default:
        throw InvalidUserClaimsException(TokenInvalidUserRoleInToken());
    }
  }

  Map<String, dynamic> _extractTokenClaims(JWT token) => token.payload;
}
