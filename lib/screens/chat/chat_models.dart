class ChatMessage {
  final int id;
  final String message;
  final String username;
  final String timestamp;

  ChatMessage({
    required this.id,
    required this.message,
    required this.username,
    required this.timestamp,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json["id"] ?? 0,
      message: json["message"] ?? "",
      username: json["username"] ?? "",
      timestamp: json["timestamp"] ?? "",
    );
  }
}
