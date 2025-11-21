import 'package:client/infrastructure/apis/auth_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

typedef Token = String;
typedef AccessToken = String;
typedef RefreshToken = String;
typedef TokenKey = String;

/// Service for managing authentication tokens using local storage.
///
/// Handles saving, retrieving, clearing, and refreshing access and refresh tokens
/// for user authentication. Uses [SharedPreferences] for persistent storage.
class AuthTokenService {
  static const TokenKey _accessTokenKey = 'accessToken';
  static const TokenKey _refreshTokenKey = 'refreshToken';

  /// Refreshes the access token using the provided [AuthApi] and returns the new access token.
  ///
  /// Throws [AuthApiException].
  Future<AccessToken?> refreshAndGetAccessToken({required AuthApi authApi}) async {
    await authApi.refreshAccessToken();
    return await accessToken;
  }

  /// Retrieves the stored current access token.
  Future<AccessToken?> get accessToken async => await _getToken(key: _accessTokenKey);

  /// Returns true if an access token is present in persistent storage.
  Future<bool> get hasAccessToken async => (await accessToken) != null;

  /// Retrieves the stored current refresh token.
  Future<RefreshToken?> get refreshToken async => await _getToken(key: _refreshTokenKey);

  /// Returns true if a refresh token is present in persistent storage.
  Future<bool> get hasRefreshToken async => (await refreshToken) != null;

  /// Saves both access and refresh tokens to persistent storage.
  ///
  /// Overwrites any existing tokens.
  Future<void> saveTokens({required AccessToken accessToken, required RefreshToken refreshToken}) async {
    await setAccessToken(accessToken: accessToken);
    await setRefreshToken(refreshToken: refreshToken);
  }

  /// Clears both access and refresh tokens from persistent storage.
  Future<void> clearTokens() async {
    await setAccessToken(accessToken: null);
    await setRefreshToken(refreshToken: null);
  }

  /// Sets the access token in persistent storage. Pass null to remove it.
  Future<void> setAccessToken({AccessToken? accessToken}) async {
    await _setToken(key: _accessTokenKey, value: accessToken);
  }

  /// Sets the refresh token in persistent storage. Pass null to remove it.
  Future<void> setRefreshToken({RefreshToken? refreshToken}) async {
    await _setToken(key: _refreshTokenKey, value: refreshToken);
  }

  /// Retrieves a token by [key] from persistent storage.
  Future<Token?> _getToken({required TokenKey key}) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  /// Sets or removes a token by [key] in persistent storage.
  ///
  /// If [value] is null, the token is removed.
  Future<void> _setToken({required TokenKey key, required Token? value}) async {
    final prefs = await SharedPreferences.getInstance();
    if (value == null) {
      await prefs.remove(key);
    } else {
      await prefs.setString(key, value);
    }
  }
}
