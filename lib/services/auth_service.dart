import 'package:shared_preferences/shared_preferences.dart';

class AuthService {

  // ==========================================
  // SAVE USER SESSION
  // ==========================================
  static Future<void> saveUser(
    String token,
    String role,
    String username,
  ) async {

    final prefs =
        await SharedPreferences.getInstance();

    await prefs.setString(
      "token",
      token,
    );

    await prefs.setString(
      "role",
      role,
    );

    await prefs.setString(
      "username",
      username,
    );

    print("================================");
    print("USER SESSION SAVED");
    print("TOKEN: $token");
    print("ROLE: $role");
    print("USERNAME: $username");
    print("================================");
  }

  // ==========================================
  // GET TOKEN
  // ==========================================
  static Future<String?> getToken() async {

    final prefs =
        await SharedPreferences.getInstance();

    final token =
        prefs.getString("token");

    print("AUTH TOKEN: $token");

    return token;
  }

  // ==========================================
  // GET ROLE
  // ==========================================
  static Future<String?> getRole() async {

    final prefs =
        await SharedPreferences.getInstance();

    return prefs.getString("role");
  }

  // ==========================================
  // GET USERNAME
  // ==========================================
  static Future<String?> getUsername() async {

    final prefs =
        await SharedPreferences.getInstance();

    return prefs.getString("username");
  }

  // ==========================================
  // CHECK LOGIN STATUS
  // ==========================================
  static Future<bool> isLoggedIn() async {

    final token =
        await getToken();

    return token != null &&
        token.isNotEmpty;
  }

  // ==========================================
  // CLEAR TOKEN ONLY
  // ==========================================
  static Future<void> clearToken() async {

    final prefs =
        await SharedPreferences.getInstance();

    await prefs.remove("token");

    print("TOKEN CLEARED");
  }

  // ==========================================
  // CLEAR USERNAME ONLY
  // ==========================================
  static Future<void> clearUsername() async {

    final prefs =
        await SharedPreferences.getInstance();

    await prefs.remove("username");

    print("USERNAME CLEARED");
  }

  // ==========================================
  // CLEAR ROLE ONLY
  // ==========================================
  static Future<void> clearRole() async {

    final prefs =
        await SharedPreferences.getInstance();

    await prefs.remove("role");

    print("ROLE CLEARED");
  }

  // ==========================================
  // LOGOUT
  // ==========================================
  static Future<void> logout() async {

    final prefs =
        await SharedPreferences.getInstance();

    final token =
        prefs.getString("token");

    final username =
        prefs.getString("username");

    final role =
        prefs.getString("role");

    print("================================");
    print("LOGOUT STARTED");
    print("TOKEN: $token");
    print("USERNAME: $username");
    print("ROLE: $role");
    print("================================");

    await prefs.remove("token");
    await prefs.remove("role");
    await prefs.remove("username");

    print("================================");
    print("USER LOGGED OUT SUCCESSFULLY");
    print("TOKEN CLEARED");
    print("ROLE CLEARED");
    print("USERNAME CLEARED");
    print("================================");
  }

  // ==========================================
  // CLEAR EVERYTHING
  // ==========================================
  static Future<void> clearAll() async {

    final prefs =
        await SharedPreferences.getInstance();

    await prefs.clear();

    print("ALL LOCAL STORAGE CLEARED");
  }
}