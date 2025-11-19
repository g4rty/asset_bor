import 'package:shared_preferences/shared_preferences.dart';

class AuthStorage {
  static const _keyUserId = 'loggedInUserId';
  static const _keySessionCookie = 'sessionCookie';

  // Save logged-in user ID.
  static Future<void> setUserId(int id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyUserId, id);
  }

  static Future<void> setSessionCookie(String cookie) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySessionCookie, cookie);
  }

  // Retrieve stored user ID. Returns null if none.
  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyUserId);
  }

  static Future<String?> getSessionCookie() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keySessionCookie);
  }

  // Clear stored user ID (logout).
  static Future<void> clearUserId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserId);
    await prefs.remove(_keySessionCookie);
  }

  static Future<Map<String, String>> withSessionCookie(
    Map<String, String>? headers,
  ) async {
    final current = <String, String>{};
    if (headers != null) current.addAll(headers);
    final cookie = await getSessionCookie();
    if (cookie != null && cookie.isNotEmpty) {
      current['cookie'] = cookie;
    }
    return current;
  }
}
