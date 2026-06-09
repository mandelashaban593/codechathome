import 'dart:convert';
import '../../services/api_service.dart';

class ChatApi {

  // =====================================================
  // RECEIVE MESSAGES
  // =====================================================
  static Future receive(int roomId, int offset) async {

    if (roomId <= 0) {
      throw Exception("Invalid roomId: $roomId");
    }

    print("CHAT RECEIVE → roomId=$roomId offset=$offset");

    return ApiService.post("chat/receive/", {
      "id": roomId.toString(),
      "offset": offset.toString(),
    });
  }

  // =====================================================
  // SEND MESSAGE
  // =====================================================
  static Future send(
    int roomId,
    String message,
    String username,
  ) async {

    if (roomId <= 0) {
      throw Exception("Cannot send message: invalid roomId");
    }

    if (message.trim().isEmpty) {
      throw Exception("Empty message not allowed");
    }

    print("CHAT SEND → roomId=$roomId user=$username msg=$message");

    return ApiService.post("chat/send/", {
      "chat_room_id": roomId.toString(),
      "message": message,
      "username": username,
    });
  }

  // =====================================================
  // MARK AS READ
  // =====================================================
  static Future markRead(
    int roomId,
    String username,
  ) async {

    if (roomId <= 0) {
      throw Exception("Invalid roomId for markRead");
    }

    return ApiService.post("chat/mark-read/", {
      "room_id": roomId.toString(),
      "username": username,
    });
  }

  // =====================================================
  // STATUS
  // =====================================================
  static Future getStatus(String username) async {

    return ApiService.post("chat/status/", {
      "username": username,
    });
  }

  // =====================================================
  // FCM TOKEN
  // =====================================================
  static Future getFcmToken(String username) async {

    return ApiService.get(
      "get-fcm-token/?username=$username",
    );
  }
}