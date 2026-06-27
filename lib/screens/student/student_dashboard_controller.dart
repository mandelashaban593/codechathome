import 'dart:async';
import 'dart:convert';

import 'student_api.dart';
import 'student_models.dart';

class StudentDashboardController {

  List<StudentRoom> rooms = [];

  Timer? heartbeatTimer;
  Timer? refreshTimer;

  Future<List<StudentRoom>> loadRooms(
    String username,
    String search,
    int page,
  ) async {

    final res = await StudentApi.dashboard(
      username,
      search,
      page,
    );

    final body = jsonDecode(res.body);

    List data = body["rooms"] ?? [];

    rooms = data
        .map((e) => StudentRoom.fromJson(e))
        .toList();

    return rooms;
  }

  void startHeartbeat(String username) {

    heartbeatTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) {
        StudentApi.heartbeat(username);
      },
    );
  }

  void startAutoRefresh(
      Function callback) {

    refreshTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => callback(),
    );
  }

  void stopTimers() {
    heartbeatTimer?.cancel();
    refreshTimer?.cancel();
  }
}