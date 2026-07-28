// lib/screens/admin/admin_dashboard_controller.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../services/auth_service.dart';
import '../../config/api_config.dart';
import 'admin_models.dart';

class AdminDashboardController {
static String get baseUrl => ApiConfig.baseUrl.endsWith('/')
      ? ApiConfig.baseUrl.substring(0, ApiConfig.baseUrl.length - 1)
      : ApiConfig.baseUrl;
      
  List<AdminRoom> rooms = [];
  List<AdminUser> users = [];
  AdminStats stats = AdminStats.empty();

  Future<Map<String, String>> _headers() async {
    final token = await AuthService.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Token $token',
    };
  }

  // =====================================================
  // STATS
  // =====================================================
  Future<void> loadStats() async {
    final res = await http.get(
      Uri.parse('$baseUrl/admin/stats/'),
      headers: await _headers(),
    );
    if (res.statusCode == 200) {
      stats = AdminStats.fromJson(jsonDecode(res.body));
    } else {
      throw Exception('Failed to load stats (${res.statusCode})');
    }
  }

  // =====================================================
  // ROOMS
  // =====================================================
  Future<void> loadRooms({String search = '', int page = 1}) async {
    final uri = Uri.parse('$baseUrl/admin/rooms/').replace(queryParameters: {
      if (search.isNotEmpty) 'search': search,
      'page': '$page',
    });
    final res = await http.get(uri, headers: await _headers());
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      rooms = data.map((e) => AdminRoom.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load rooms (${res.statusCode})');
    }
  }

  Future<Map<String, dynamic>> loadRoomDetail(int roomId) async {
    final res = await http.get(
      Uri.parse('$baseUrl/admin/rooms/$roomId/'),
      headers: await _headers(),
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }
    throw Exception('Failed to load room detail (${res.statusCode})');
  }

  Future<void> deleteMessage(int messageId) async {
    final res = await http.delete(
      Uri.parse('$baseUrl/admin/messages/$messageId/'),
      headers: await _headers(),
    );
    if (res.statusCode != 204) {
      throw Exception('Failed to delete message (${res.statusCode})');
    }
  }

  // =====================================================
  // USERS
  // =====================================================
  Future<void> loadUsers({String role = '', String search = ''}) async {
    final uri = Uri.parse('$baseUrl/admin/users/').replace(queryParameters: {
      if (role.isNotEmpty) 'role': role,
      if (search.isNotEmpty) 'search': search,
    });
    final res = await http.get(uri, headers: await _headers());
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      users = data.map((e) => AdminUser.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load users (${res.statusCode})');
    }
  }

  Future<void> setUserActive(int userId, bool activate) async {
    final action = activate ? 'reactivate' : 'suspend';
    final res = await http.post(
      Uri.parse('$baseUrl/admin/users/$userId/$action/'),
      headers: await _headers(),
    );
    if (res.statusCode != 200) {
      throw Exception('Failed to $action user (${res.statusCode})');
    }
  }

  Future<void> changeUserRole(int userId, String role) async {
    final res = await http.post(
      Uri.parse('$baseUrl/admin/users/$userId/role/'),
      headers: await _headers(),
      body: jsonEncode({'role': role}),
    );
    if (res.statusCode != 200) {
      throw Exception('Failed to change role (${res.statusCode})');
    }
  }
}