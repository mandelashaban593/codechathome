import 'package:flutter/material.dart';

class ChatHeader extends StatelessWidget {

  final String title;
  final bool isOnline;
  final String lastSeen;

  const ChatHeader({
    super.key,
    required this.title,
    required this.isOnline,
    required this.lastSeen,
  });

  @override
  Widget build(BuildContext context) {

    return Row(
      children: [

        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(width: 10),

        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: isOnline
                ? Colors.green
                : Colors.grey,
            shape: BoxShape.circle,
          ),
        ),

        const SizedBox(width: 8),

        Text(
          isOnline ? "Online" : lastSeen,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}