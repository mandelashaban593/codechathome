class StudentRoom {
  final int room_id;
  final String mentorUsername;
  final String created;

  final bool mentorOnline;
  final bool studentOnline;

  final int unreadCount;

  StudentRoom({
    required this.room_id,
    required this.mentorUsername,
    required this.created,
    required this.mentorOnline,
    required this.studentOnline,
    required this.unreadCount,
  });

  factory StudentRoom.fromJson(Map<String, dynamic> json) {
    return StudentRoom(
      room_id: json["room_id"] ?? 0,
      mentorUsername: json["mentor_username"] ?? "",
      created: json["created"] ?? "",

      mentorOnline:
          json["mentor_online"]?["is_online"] ?? false,

      studentOnline:
          json["student_online"]?["is_online"] ?? false,

      unreadCount:
          json["unread"]?["count"] ?? 0,
    );
  }
}