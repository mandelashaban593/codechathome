import 'package:shared_preferences/shared_preferences.dart';

class AuthService {

  static Future saveUser(String token, String role, String username) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("token", token);
    prefs.setString("role", role);
    prefs.setString("username", username);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  static Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("role");
  }

  static Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("username");
  }

  static Future logout() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }
}