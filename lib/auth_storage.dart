import 'package:shared_preferences/shared_preferences.dart';

class AuthStorage {
  static const _keyUserId = 'loggedInUserId';

  /// Save logged-in user ID.
  static Future<void> setUserId(int id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyUserId, id);
  }

  /// Retrieve stored user ID. Returns null if none.
  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyUserId);
  }

  /// Clear stored user ID (logout).
  static Future<void> clearUserId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserId);
  }
}