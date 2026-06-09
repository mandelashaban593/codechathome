import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../widgets/chat_bubble.dart';
import 'chat_controller.dart';
import 'chat_header.dart';
import 'chat_input.dart';
import 'chat_models.dart';

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
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final controller = ChatController();

  final TextEditingController msg = TextEditingController();
  final ScrollController scrollController = ScrollController();

  bool isOnline = false;
  String lastSeen = "";

  @override
  void initState() {
    super.initState();
    initChat();
  }

  // ================= INIT =================
  Future<void> initChat() async {
    await loadMessages();

    controller.startPolling(widget.roomId, () async {
      await loadMessages();
    });

    controller.markAsRead(widget.roomId, widget.username);

    await loadStatus();
  }

  // ================= LOAD MESSAGES =================
  Future<void> loadMessages() async {
    try {
      await controller.loadMessages(widget.roomId);

      setState(() {});

      WidgetsBinding.instance.addPostFrameCallback((_) {
        scrollToBottom();
      });

      print("Messages loaded: ${controller.messages.length}");
    } catch (e) {
      print("LOAD ERROR: $e");
    }
  }

  void scrollToBottom() {
    if (scrollController.hasClients) {
      scrollController.jumpTo(scrollController.position.maxScrollExtent);
    }
  }

  void scrollUp() {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        scrollController.offset - 120,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
  }

  void scrollDown() {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        scrollController.offset + 120,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
  }

  // ================= STATUS =================
  Future<void> loadStatus() async {
    try {
      final res = await controller.getStatus(widget.mentorUsername);

      final decoded = jsonDecode(res.body);

      setState(() {
        isOnline = decoded["is_online"] ?? false;
        lastSeen = decoded["last_seen"] ?? "";
      });
    } catch (e) {
      print("STATUS ERROR: $e");
    }
  }

  // ================= SEND MESSAGE =================
  Future<void> send() async {
    final text = msg.text.trim();
    if (text.isEmpty) return;

    print("SEND: $text | ROOM: ${widget.roomId}");

    try {
      await controller.sendMessage(
        widget.roomId,
        text,
        widget.username,
      );

      msg.clear();
      await loadMessages();
    } catch (e) {
      print("SEND ERROR: $e");
    }
  }

  // ================= KEYBOARD HANDLER =================
  void handleKey(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      final key = event.logicalKey;

      if (key == LogicalKeyboardKey.enter) {
        send();
      }

      if (key == LogicalKeyboardKey.arrowUp) {
        scrollUp();
      }

      if (key == LogicalKeyboardKey.arrowDown) {
        scrollDown();
      }
    }
  }

  // ================= MESSAGE UI =================
  Widget buildMessage(ChatMessage m) {
    return ChatBubble(
      message: m.message,
      isMe: m.username == widget.username,
      time: m.timestamp,
    );
  }

  @override
  void dispose() {
    controller.stopPolling();
    msg.dispose();
    scrollController.dispose();
    super.dispose();
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,

      appBar: AppBar(
        title: ChatHeader(
          title: widget.mentorUsername,
          isOnline: isOnline,
          lastSeen: lastSeen,
        ),
        backgroundColor: Colors.blue.shade800,
      ),

      body: Column(
        children: [
          Expanded(
            child: RawKeyboardListener(
              focusNode: FocusNode(),
              autofocus: true,
              onKey: handleKey,

              child: ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.all(10),
                itemCount: controller.messages.length,
                itemBuilder: (_, i) =>
                    buildMessage(controller.messages[i]),
              ),
            ),
          ),

          // ================= INPUT =================
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: msg,
                    onSubmitted: (_) => send(),
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