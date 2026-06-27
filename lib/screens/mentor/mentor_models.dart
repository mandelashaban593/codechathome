class MentorRoom {

  final int room_id;
  final String studentUsername;
  final bool online;
  final int unreadCount;
  final String created;

  MentorRoom({
    required this.room_id,
    required this.studentUsername,
    required this.online,
    required this.unreadCount,
    required this.created,
  });

  factory MentorRoom.fromJson(
      Map<String, dynamic> json) {

    print("================================");
    print("MENTOR ROOM JSON");
    print(json);
    print("room_id = ${json["room_id"]}");
    print("================================");

    return MentorRoom(

      // FIXED
      room_id: json["room_id"] ?? 0,

      studentUsername:
          json["student_username"] ?? "",

      online:
          json["student_online"]?["is_online"] ?? false,

      unreadCount:
          json["unread"]?["count"] ?? 0,

      created:
          json["created"] ?? "",
    );
  }
}