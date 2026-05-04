import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  static const _keyToken = 'auth_access_token';

  TokenStorage._(this._prefs);
  final SharedPreferences _prefs;

  static Future<TokenStorage> create() async {
    final prefs = await SharedPreferences.getInstance();
    return TokenStorage._(prefs);
  }

  String? get accessToken => _prefs.getString(_keyToken);

  Future<void> setAccessToken(String? token) async {
    if (token == null || token.isEmpty) {
      await _prefs.remove(_keyToken);
    } else {
      await _prefs.setString(_keyToken, token);
    }
  }
}
