import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import 'auth_service.dart';

class ApiService {

  // =====================================================
  // HEADERS (WITH TOKEN)
  // =====================================================
  static Future<Map<String, String>> headers() async {

    final token = await AuthService.getToken();

    return <String, String>{
      "Content-Type": "application/json",
      "Authorization": "Token $token",
    };
  }

  // =====================================================
  // HEADERS (WITHOUT TOKEN) — for public endpoints
  // =====================================================
  static Map<String, String> get publicHeaders => {
        "Content-Type": "application/json",
      };

  // =====================================================
  // POST REQUEST
  // =====================================================
  static Future<http.Response> post(
    String url,
    Map body, {
    bool auth = true,
  }) async {

    final fullUrl = ApiConfig.baseUrl + url;

    // ✅ FIX: when auth=false, always use publicHeaders (no token lookup)
    final Map<String, String> requestHeaders = auth
        ? await headers()
        : publicHeaders;

    final String encodedBody = jsonEncode(body);

    print("\n================ API REQUEST ================");
    print("URL: $fullUrl");
    print("HEADERS: $requestHeaders");
    print("BODY: $encodedBody");
    print("===========================================\n");

    final response = await http.post(
      Uri.parse(fullUrl),
      headers: requestHeaders,
      body: encodedBody,
    );

    print("\n================ API RESPONSE ================");
    print("URL: $fullUrl");
    print("STATUS CODE: ${response.statusCode}");
    print("BODY: ${response.body}");
    print("============================================\n");

    return response;
  }

  // =====================================================
  // GET REQUEST
  // =====================================================
  static Future<http.Response> get(
    String url, {
    bool auth = true,
  }) async {

    final fullUrl = ApiConfig.baseUrl + url;

    // ✅ FIX: when auth=false, use publicHeaders for consistency
    final Map<String, String> requestHeaders = auth
        ? await headers()
        : publicHeaders;

    print("\n================ API GET REQUEST ================");
    print("URL: $fullUrl");
    print("HEADERS: $requestHeaders");
    print("===============================================\n");

    final response = await http.get(
      Uri.parse(fullUrl),
      headers: requestHeaders,
    );

    print("\n================ API GET RESPONSE ================");
    print("URL: $fullUrl");
    print("STATUS CODE: ${response.statusCode}");
    print("BODY: ${response.body}");
    print("===============================================\n");

    return response;
  }

  // =====================================================
  // PASSWORD RESET — STEP 1 (OLD — link based)
  // POST /codechathome_api/password-reset/
  // Body: { "email": "user@example.com" }
  // No token needed — public endpoint
  // =====================================================
  static Future<Map<String, dynamic>> requestPasswordReset(
      String email) async {

    final fullUrl = '${ApiConfig.baseUrl}password-reset/';

    print("\n================ PASSWORD RESET REQUEST ================");
    print("URL: $fullUrl");
    print("BODY: { email: $email }");
    print("=======================================================\n");

    try {
      final response = await http.post(
        Uri.parse(fullUrl),
        headers: publicHeaders,
        body: jsonEncode({'email': email}),
      );

      print("\n================ PASSWORD RESET RESPONSE ================");
      print("STATUS CODE: ${response.statusCode}");
      print("BODY: ${response.body}");
      print("========================================================\n");

      return jsonDecode(response.body);

    } catch (e) {
      print("PASSWORD RESET ERROR: $e");
      return {
        'success': false,
        'message': 'Network error. Please check your connection.',
      };
    }
  }

  // =====================================================
  // PASSWORD RESET — STEP 2 (OLD — link based)
  // GET /codechathome_api/password-reset/confirm/<uidb64>/<token>/
  // Validates the reset link before showing the form
  // No token needed — public endpoint
  // =====================================================
  static Future<Map<String, dynamic>> validateResetLink(
      String uidb64, String token) async {

    final fullUrl =
        '${ApiConfig.baseUrl}password-reset/confirm/$uidb64/$token/';

    print("\n================ VALIDATE RESET LINK ================");
    print("URL: $fullUrl");
    print("uidb64: $uidb64");
    print("token: $token");
    print("=====================================================\n");

    try {
      final response = await http.get(
        Uri.parse(fullUrl),
        headers: publicHeaders,
      );

      print("\n================ VALIDATE RESET LINK RESPONSE ================");
      print("STATUS CODE: ${response.statusCode}");
      print("BODY: ${response.body}");
      print("==============================================================\n");

      return jsonDecode(response.body);

    } catch (e) {
      print("VALIDATE RESET LINK ERROR: $e");
      return {
        'success': false,
        'message': 'Network error. Please check your connection.',
      };
    }
  }

  // =====================================================
  // PASSWORD RESET — STEP 3 (OLD — link based)
  // POST /codechathome_api/password-reset/confirm/<uidb64>/<token>/
  // Body: { "new_password": "...", "confirm_password": "..." }
  // No token needed — public endpoint
  // =====================================================
  static Future<Map<String, dynamic>> confirmPasswordResetByLink(
      String uidb64,
      String token,
      String newPassword,
      String confirmPassword) async {

    final fullUrl =
        '${ApiConfig.baseUrl}password-reset/confirm/$uidb64/$token/';

    print("\n================ CONFIRM PASSWORD RESET (LINK) ================");
    print("URL: $fullUrl");
    print("uidb64: $uidb64");
    print("token: $token");
    print("==============================================================\n");

    try {
      final response = await http.post(
        Uri.parse(fullUrl),
        headers: publicHeaders,
        body: jsonEncode({
          'new_password':     newPassword,
          'confirm_password': confirmPassword,
        }),
      );

      print("\n================ CONFIRM PASSWORD RESET (LINK) RESPONSE ================");
      print("STATUS CODE: ${response.statusCode}");
      print("BODY: ${response.body}");
      print("=======================================================================\n");

      return jsonDecode(response.body);

    } catch (e) {
      print("CONFIRM PASSWORD RESET (LINK) ERROR: $e");
      return {
        'success': false,
        'message': 'Network error. Please check your connection.',
      };
    }
  }

  // =====================================================
  // PASSWORD RESET — STEP 1 (NEW — code based)
  // POST /codechathome_api/password-reset/send-code/
  // Body: { "email": "user@example.com" }
  // No token needed — public endpoint
  // Sends a 6-digit code to the user's email
  // =====================================================
  static Future<Map<String, dynamic>> sendResetCode(
      String email) async {

    final fullUrl = '${ApiConfig.baseUrl}password-reset/send-code/';

    print("\n================ SEND RESET CODE ================");
    print("URL: $fullUrl");
    print("BODY: { email: $email }");
    print("=================================================\n");

    try {
      final response = await http.post(
        Uri.parse(fullUrl),
        headers: publicHeaders,
        body: jsonEncode({'email': email}),
      );

      print("\n================ SEND RESET CODE RESPONSE ================");
      print("STATUS CODE: ${response.statusCode}");
      print("BODY: ${response.body}");
      print("==========================================================\n");

      return jsonDecode(response.body);

    } catch (e) {
      print("SEND RESET CODE ERROR: $e");
      return {
        'success': false,
        'message': 'Network error. Please check your connection.',
      };
    }
  }

  // =====================================================
  // PASSWORD RESET — STEP 2 (NEW — code based)
  // POST /codechathome_api/password-reset/verify-code/
  // Body: { "email": "user@example.com", "code": "482910" }
  // No token needed — public endpoint
  // Verifies the 6-digit code entered by the user
  // =====================================================
  static Future<Map<String, dynamic>> verifyResetCode(
      String email, String code) async {

    final fullUrl = '${ApiConfig.baseUrl}password-reset/verify-code/';

    print("\n================ VERIFY RESET CODE ================");
    print("URL: $fullUrl");
    print("BODY: { email: $email, code: $code }");
    print("===================================================\n");

    try {
      final response = await http.post(
        Uri.parse(fullUrl),
        headers: publicHeaders,
        body: jsonEncode({
          'email': email,
          'code':  code,
        }),
      );

      print("\n================ VERIFY RESET CODE RESPONSE ================");
      print("STATUS CODE: ${response.statusCode}");
      print("BODY: ${response.body}");
      print("============================================================\n");

      return jsonDecode(response.body);

    } catch (e) {
      print("VERIFY RESET CODE ERROR: $e");
      return {
        'success': false,
        'message': 'Network error. Please check your connection.',
      };
    }
  }

  // =====================================================
  // PASSWORD RESET — RESEND CODE (NEW — code based)
  // POST /codechathome_api/password-reset/resend-code/
  // Body: { "email": "user@example.com" }
  // No token needed — public endpoint
  // Generates and sends a fresh 6-digit code
  // =====================================================
  static Future<Map<String, dynamic>> resendResetCode(
      String email) async {

    final fullUrl = '${ApiConfig.baseUrl}password-reset/resend-code/';

    print("\n================ RESEND RESET CODE ================");
    print("URL: $fullUrl");
    print("BODY: { email: $email }");
    print("===================================================\n");

    try {
      final response = await http.post(
        Uri.parse(fullUrl),
        headers: publicHeaders,
        body: jsonEncode({'email': email}),
      );

      print("\n================ RESEND RESET CODE RESPONSE ================");
      print("STATUS CODE: ${response.statusCode}");
      print("BODY: ${response.body}");
      print("============================================================\n");

      return jsonDecode(response.body);

    } catch (e) {
      print("RESEND RESET CODE ERROR: $e");
      return {
        'success': false,
        'message': 'Network error. Please check your connection.',
      };
    }
  }

  // =====================================================
  // PASSWORD RESET — STEP 3 (NEW — code based)
  // POST /codechathome_api/password-reset/confirm/
  // Body: {
  //   "email": "user@example.com",
  //   "code": "482910",
  //   "new_password": "...",
  //   "confirm_password": "..."
  // }
  // No token needed — public endpoint
  // Final step — saves the new password to database
  // =====================================================
  static Future<Map<String, dynamic>> confirmPasswordReset(
      String email,
      String code,
      String newPassword,
      String confirmPassword) async {

    final fullUrl = '${ApiConfig.baseUrl}password-reset/confirm/';

    print("\n================ CONFIRM PASSWORD RESET (CODE) ================");
    print("URL: $fullUrl");
    print("BODY: { email: $email, code: $code }");
    print("==============================================================\n");

    try {
      final response = await http.post(
        Uri.parse(fullUrl),
        headers: publicHeaders,
        body: jsonEncode({
          'email':            email,
          'code':             code,
          'new_password':     newPassword,
          'confirm_password': confirmPassword,
        }),
      );

      print("\n================ CONFIRM PASSWORD RESET (CODE) RESPONSE ================");
      print("STATUS CODE: ${response.statusCode}");
      print("BODY: ${response.body}");
      print("=======================================================================\n");

      return jsonDecode(response.body);

    } catch (e) {
      print("CONFIRM PASSWORD RESET (CODE) ERROR: $e");
      return {
        'success': false,
        'message': 'Network error. Please check your connection.',
      };
    }
  }
}