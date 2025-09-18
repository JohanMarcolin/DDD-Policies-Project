import 'package:client/infrastructure/apis/auth_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

typedef Token = String;
typedef AccessToken = String;
typedef RefreshToken = String;
typedef TokenKey = String;

class AuthTokenService {
  static const _accessTokenKey = 'accessToken';
  static const _refreshTokenKey = 'refreshToken';

  Future<AccessToken?> refreshAndGetAccessToken({required AuthApi authApi}) async {
    await authApi.refreshAccessToken();
    return await accessToken;
  }

  Future<AccessToken?> get accessToken async =>
      await _getToken(key: _accessTokenKey);

  Future<bool> get hasAccessToken async => (await accessToken) != null;

  Future<RefreshToken?> get refreshToken async =>
      await _getToken(key: _refreshTokenKey);

  Future<bool> get hasRefreshToken async => (await refreshToken) != null;

  Future<void> saveTokens({
    required AccessToken accessToken,
    required RefreshToken refreshToken,
  }) async {
    await setAccessToken(accessToken: accessToken);
    await setRefreshToken(refreshToken: refreshToken);
  }

  Future<void> clearTokens() async {
    await setAccessToken(accessToken: null);
    await setRefreshToken(refreshToken: null);
  }

  Future<void> setAccessToken({AccessToken? accessToken}) async {
    await _setToken(key: _accessTokenKey, value: accessToken);
  }

  Future<void> setRefreshToken({RefreshToken? refreshToken}) async {
    await _setToken(key: _refreshTokenKey, value: refreshToken);
  }

  Future<Token?> _getToken({required TokenKey key}) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  Future<void> _setToken({required TokenKey key, required Token? value}) async {
    final prefs = await SharedPreferences.getInstance();
    if (value == null) {
      await prefs.remove(key);
    } else {
      await prefs.setString(key, value);
    }
  }
}
