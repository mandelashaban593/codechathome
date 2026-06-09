import 'dart:async';
import 'dart:convert';

import 'chat_api.dart';
import 'chat_models.dart';

class ChatController {

  List<ChatMessage> messages = [];

  int offset = 0;

  Timer? poller;

  // Prevent duplicates
  final Set<int> messageIds = {};

  Future loadMessages(int roomId) async {

    final res = await ChatApi.receive(
      roomId,
      offset,
    );

    final data = jsonDecode(res.body);

    List newMessages = data["messages"] ?? [];

    for (var m in newMessages) {

      if (!messageIds.contains(m["id"])) {

        final msg =
            ChatMessage.fromJson(m);

        messages.add(msg);

        messageIds.add(msg.id);

        offset = msg.id;
      }
    }
  }

  Future sendMessage(
    int roomId,
    String message,
    String username,
  ) async {

    await ChatApi.send(
      roomId,
      message,
      username,
    );

    final temp = ChatMessage(
      id: DateTime.now()
          .millisecondsSinceEpoch,
      message: message,
      username: username,
      timestamp: "now",
    );

    messages.add(temp);
  }

  Future markAsRead(
    int roomId,
    String username,
  ) async {
    await ChatApi.markRead(
      roomId,
      username,
    );
  }

  void startPolling(
    int roomId,
    Function refresh,
  ) {
    poller = Timer.periodic(
      const Duration(seconds: 2),
      (_) async {
        await loadMessages(roomId);
        refresh();
      },
    );
  }

  void stopPolling() {
    poller?.cancel();
  }

  Future getStatus(String username) {
    return ChatApi.getStatus(username);
  }

  Future getFcmToken(String username) {
    return ChatApi.getFcmToken(username);
  }
}