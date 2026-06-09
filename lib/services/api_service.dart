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
  // POST REQUEST
  // =====================================================
  static Future<http.Response> post(
    String url,
    Map body, {
    bool auth = true,
  }) async {

    final fullUrl = ApiConfig.baseUrl + url;

    final Map<String, String> requestHeaders = auth
        ? await headers()
        : <String, String>{
            "Content-Type": "application/json",
          };

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

    final Map<String, String> requestHeaders = auth
        ? await headers()
        : <String, String>{};

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
}