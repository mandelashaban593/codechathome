import '../../services/api_service.dart';

class MentorApi {

  static Future<dynamic> dashboard(
      String username,
      String search,
      int page) async {

    return ApiService.post(
      "chat/mentor/dashboard/",
      {
        "username": username,
        "search": search,
        "page": page.toString(),
      },
    );
  }

  static Future heartbeat(String username) async {

    return ApiService.post(
      "heartbeat/",
      {
        "username": username,
      },
    );
  }

  static Future registerFCM(
      String username,
      String token) async {

    return ApiService.post(
      "register-fcm/",
      {
        "username": username,
        "fcm_token": token,
      },
    );
  }

  static Future goOffline(
      String username) async {

    return ApiService.post(
      "go-offline/",
      {
        "username": username,
      },
    );
  }
}