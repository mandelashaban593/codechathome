import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../widgets/chat_bubble.dart';

class ChatScreen extends StatefulWidget {
  final int roomId;
  final String username;
  final String mentorUsername;

  const ChatScreen({
    Key? key,
    required this.roomId,
    required this.username,
    required this.mentorUsername,
  }) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List messages = [];
  int offset = 0;

  TextEditingController msg = TextEditingController();
  Timer? timer;

  @override
  void initState() {
    super.initState();
    load();

    // 🔁 Poll every 2 sec
    timer = Timer.periodic(const Duration(seconds: 2), (_) => load());
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  // ================= LOAD MESSAGES =================
  load() async {
    try {
      var res = await ApiService.post("chat/receive/", {
        "id": widget.roomId.toString(),
        "offset": offset.toString()
      });

      var data = jsonDecode(res.body);

      if (data["messages"] != null && data["messages"].isNotEmpty) {
        setState(() {
          for (var m in data["messages"]) {
            messages.add(m);
          }
          offset = messages.last["id"];
        });
      }
    } catch (e) {
      debugPrint("Chat load error: $e");
    }
  }

  // ================= SEND =================
  send() async {
    if (msg.text.trim().isEmpty) return;

    final text = msg.text.trim();

    try {
      await ApiService.post("chat/send/", {
        "chat_room_id": widget.roomId.toString(),
        "message": text,
        "username": widget.username
      });

      setState(() {
        messages.add({
          "message": text,
          "username": widget.username,
          "timestamp": "now"
        });
      });

      msg.clear();
    } catch (e) {
      debugPrint("Send error: $e");
    }
  }

  // ================= MESSAGE UI =================
  Widget buildMessage(m) {
    return ChatBubble(
      message: m["message"],
      isMe: m["username"] == widget.username,
      time: m["timestamp"] ?? "",
    );
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,

      appBar: AppBar(
        title: Text("Chat with ${widget.mentorUsername}"),
        backgroundColor: Colors.blue.shade800,
      ),

      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: messages.length,
              itemBuilder: (context, i) => buildMessage(messages[i]),
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: msg,
                    decoration: const InputDecoration(
                      hintText: "Type message...",
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.blue),
                  onPressed: send,
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}