import '../../services/api_service.dart';

class StudentApi {

  static Future dashboard(
    String username,
    String search,
    int page,
  ) {
    return ApiService.post(
      "chat/student/dashboard/",
      {
        "username": username,
        "search": search,
        "page": page.toString(),
      },
    );
  }

  static Future heartbeat(String username) {
    return ApiService.post(
      "heartbeat/",
      {"username": username},
    );
  }

  static Future registerFCM(
    String username,
    String token,
  ) {
    return ApiService.post(
      "register-fcm/",
      {
        "username": username,
        "fcm_token": token,
      },
    );
  }

  static Future goOffline(String username) {
    return ApiService.post(
      "go-offline/",
      {"username": username},
    );
  }
}