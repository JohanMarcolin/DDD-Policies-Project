import 'package:client/infrastructure/apis/auth_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

typedef Token = String;
typedef AccessToken = String;
typedef RefreshToken = String;
typedef TokenKey = String;

/// Manages authentication tokens in local storage.
///
/// Provides methods to save, retrieve, clear, and refresh tokens for user authentication, using [SharedPreferences] for persistence.
class AuthTokenService {
  static const TokenKey _accessTokenKey = 'accessToken';
  static const TokenKey _refreshTokenKey = 'refreshToken';

  /// Refreshes the access token via [AuthApi] and returns the new token.
  /// Throws [AuthApiException] on failure.
  Future<AccessToken?> refreshAndGetAccessToken({required AuthApi authApi}) async {
    await authApi.refreshAccessToken();
    return await accessToken;
  }

  /// Gets the stored [AccessToken], or `null` if absent.
  Future<AccessToken?> get accessToken async => await _getToken(key: _accessTokenKey);

  /// Returns `true` if an [AccessToken] is stored.
  Future<bool> get hasAccessToken async => (await accessToken) != null;

  /// Gets the stored [RefreshToken], or `null` if absent.
  Future<RefreshToken?> get refreshToken async => await _getToken(key: _refreshTokenKey);

  /// Returns `true` if a [RefreshToken] is stored.
  Future<bool> get hasRefreshToken async => (await refreshToken) != null;

  /// Stores both [accessToken] and [refreshToken], overwriting any existing tokens.
  Future<void> storeTokens({required AccessToken accessToken, required RefreshToken refreshToken}) async {
    await setAccessToken(accessToken: accessToken);
    await setRefreshToken(refreshToken: refreshToken);
  }

  /// Removes both [AccessToken] and [RefreshToken] from storage.
  Future<void> clearTokens() async {
    await setAccessToken(accessToken: null);
    await setRefreshToken(refreshToken: null);
  }

  /// Sets or removes the [accessToken].
  Future<void> setAccessToken({AccessToken? accessToken}) async {
    await _setToken(key: _accessTokenKey, value: accessToken);
  }

  /// Sets or removes the [refreshToken].
  Future<void> setRefreshToken({RefreshToken? refreshToken}) async {
    await _setToken(key: _refreshTokenKey, value: refreshToken);
  }

  /// Gets a token by [key] from storage.
  Future<Token?> _getToken({required TokenKey key}) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  /// Sets or removes a token by [key]. Removes if [value] is `null`.
  Future<void> _setToken({required TokenKey key, required Token? value}) async {
    final prefs = await SharedPreferences.getInstance();
    if (value == null) {
      await prefs.remove(key);
    } else {
      await prefs.setString(key, value);
    }
  }
}
