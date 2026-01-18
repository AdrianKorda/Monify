import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const _userIdKey = 'user_id';

  // Bejelentkezett felhasználó mentése
  static Future<void> saveUserId(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_userIdKey, userId);
  }

  // Bejelentkezett felhasználó lekérése
  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_userIdKey);
  }

  // Kijelentkezés (felhasználó ID törlése)
  static Future<void> clearUserId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userIdKey);
  }
}
