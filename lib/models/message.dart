class MessageModel {
  final String message;
  final String sender;

  MessageModel({
    required this.message,
    required this.sender,
  });

  factory MessageModel.fromJson(Map json) {
    return MessageModel(
      message: json['message'] ?? '',
      sender: json['sender'] ?? '',
    );
  }
}