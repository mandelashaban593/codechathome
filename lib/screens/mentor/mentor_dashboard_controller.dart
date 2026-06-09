import 'dart:async';
import 'dart:convert';

import 'mentor_api.dart';
import 'mentor_models.dart';

class MentorDashboardController {

  Timer? heartbeatTimer;
  Timer? refreshTimer;

  List<MentorRoom> rooms = [];

  Future<List<MentorRoom>> loadRooms(
      String username,
      String search,
      int page) async {

    final response =
        await MentorApi.dashboard(
            username,
            search,
            page);

    final body =
        jsonDecode(response.body);

    List data =
        body["rooms"] ?? [];

    rooms = data
        .map((e) =>
            MentorRoom.fromJson(e))
        .toList();

    return rooms;
  }

  void startHeartbeat(
      String username) {

    heartbeatTimer =
        Timer.periodic(
      const Duration(seconds: 30),
      (_) {
        MentorApi.heartbeat(
            username);
      },
    );
  }

  void stopHeartbeat() {
    heartbeatTimer?.cancel();
  }

  void startAutoRefresh(
      Function callback) {

    refreshTimer =
        Timer.periodic(
      const Duration(seconds: 10),
      (_) => callback(),
    );
  }

  void stopAutoRefresh() {
    refreshTimer?.cancel();
  }
}