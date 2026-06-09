import 'package:flutter/material.dart';

class ChatInput extends StatelessWidget {

  final TextEditingController controller;
  final VoidCallback onSend;

  const ChatInput({
    super.key,
    required this.controller,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {

    return Container(
      padding: const EdgeInsets.all(8),
      color: Colors.white,
      child: Row(
        children: [

          Expanded(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: "Type message...",
                border: InputBorder.none,
              ),
            ),
          ),

          IconButton(
            icon: const Icon(
              Icons.send,
              color: Colors.blue,
            ),
            onPressed: onSend,
          ),
        ],
      ),
    );
  }
}