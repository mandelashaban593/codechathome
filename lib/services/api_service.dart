import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'auth_service.dart';

class ApiService {

  static Future<Map<String, String>> headers() async {
    final token = await AuthService.getToken();
    return {
      "Authorization": "Token $token"
    };
  }

  static Future post(String url, Map body, {bool auth=false}) async {
    return await http.post(
      Uri.parse(ApiConfig.baseUrl + url),
      headers: auth ? await headers() : {},
      body: body,
    );
  }

  static Future get(String url) async {
    return await http.get(
      Uri.parse(ApiConfig.baseUrl + url),
      headers: await headers(),
    );
  }
}