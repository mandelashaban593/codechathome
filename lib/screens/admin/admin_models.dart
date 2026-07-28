// lib/screens/admin/admin_models.dart
//
// Plain data classes for the admin dashboard. Mirrors the shape returned by
// admin_serializers.py — keep both in sync if you add/remove fields.

class OnlineStatus {
  final bool isOnline;
  final String lastSeen;

  OnlineStatus({required this.isOnline, required this.lastSeen});

  factory OnlineStatus.fromJson(Map<String, dynamic> json) {
    return OnlineStatus(
      isOnline: json['is_online'] ?? false,
      lastSeen: json['last_seen'] ?? 'Never',
    );
  }
}

class UnreadInfo {
  final int count;
  final bool hasAlert;

  UnreadInfo({required this.count, required this.hasAlert});

  factory UnreadInfo.fromJson(Map<String, dynamic> json) {
    return UnreadInfo(
      count: json['count'] ?? 0,
      hasAlert: json['has_alert'] ?? false,
    );
  }
}

class AdminRoom {
  final int roomId;
  final String created;
  final String studentUsername;
  final String mentorUsername;
  final String paymentStatus;
  final bool studentPaid;
  final bool mentorPaid;
  final OnlineStatus studentOnline;
  final OnlineStatus mentorOnline;
  final UnreadInfo unreadStudent;
  final UnreadInfo unreadMentor;
  final int lastMessageId;

  AdminRoom({
    required this.roomId,
    required this.created,
    required this.studentUsername,
    required this.mentorUsername,
    required this.paymentStatus,
    required this.studentPaid,
    required this.mentorPaid,
    required this.studentOnline,
    required this.mentorOnline,
    required this.unreadStudent,
    required this.unreadMentor,
    required this.lastMessageId,
  });

  factory AdminRoom.fromJson(Map<String, dynamic> json) {
    return AdminRoom(
      roomId: json['id'] ?? 0,
      created: json['created'] ?? '',
      studentUsername: json['student_username'] ?? '',
      mentorUsername: json['mentor_username'] ?? '',
      paymentStatus: json['payment_status'] ?? '',
      studentPaid: json['student_paid'] ?? false,
      mentorPaid: json['mentor_paid'] ?? false,
      studentOnline: OnlineStatus.fromJson(json['student_online'] ?? {}),
      mentorOnline: OnlineStatus.fromJson(json['mentor_online'] ?? {}),
      unreadStudent: UnreadInfo.fromJson(json['unread_student'] ?? {}),
      unreadMentor: UnreadInfo.fromJson(json['unread_mentor'] ?? {}),
      lastMessageId: json['last_message_id'] ?? 0,
    );
  }

  bool get isFlagged => unreadStudent.hasAlert || unreadMentor.hasAlert;
}

class AdminUser {
  final int id;
  final String username;
  final String email;
  final String role;
  final String phone;
  final List<String> skills;
  final bool isActive;

  AdminUser({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    required this.phone,
    required this.skills,
    required this.isActive,
  });

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    return AdminUser(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      phone: json['phone'] ?? '',
      skills: List<String>.from(json['skills'] ?? []),
      isActive: json['is_active'] ?? true,
    );
  }
}

class AdminStats {
  final int totalRooms;
  final int roomsToday;
  final int flaggedRooms;
  final int onlineMentors;
  final int onlineStudents;
  final int totalUsers;

  AdminStats({
    required this.totalRooms,
    required this.roomsToday,
    required this.flaggedRooms,
    required this.onlineMentors,
    required this.onlineStudents,
    required this.totalUsers,
  });

  factory AdminStats.empty() => AdminStats(
        totalRooms: 0,
        roomsToday: 0,
        flaggedRooms: 0,
        onlineMentors: 0,
        onlineStudents: 0,
        totalUsers: 0,
      );

  factory AdminStats.fromJson(Map<String, dynamic> json) {
    return AdminStats(
      totalRooms: json['total_rooms'] ?? 0,
      roomsToday: json['rooms_today'] ?? 0,
      flaggedRooms: json['flagged_rooms'] ?? 0,
      onlineMentors: json['online_mentors'] ?? 0,
      onlineStudents: json['online_students'] ?? 0,
      totalUsers: json['total_users'] ?? 0,
    );
  }
}
