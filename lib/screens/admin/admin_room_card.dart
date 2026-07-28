// lib/screens/admin/admin_room_card.dart

import 'package:flutter/material.dart';
import 'admin_models.dart';

class AdminRoomCard extends StatelessWidget {
  final AdminRoom room;
  final VoidCallback onTap;

  const AdminRoomCard({
    Key? key,
    required this.room,
    required this.onTap,
  }) : super(key: key);

  Widget _statusDot(bool online) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: online ? Colors.green : Colors.grey,
        shape: BoxShape.circle,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        onTap: onTap,
        leading: room.isFlagged
            ? const Icon(Icons.flag, color: Colors.redAccent)
            : const Icon(Icons.chat_bubble_outline),
        title: Row(
          children: [
            _statusDot(room.studentOnline.isOnline),
            const SizedBox(width: 4),
            Text(room.studentUsername),
            const SizedBox(width: 12),
            const Icon(Icons.arrow_right_alt, size: 16),
            const SizedBox(width: 12),
            _statusDot(room.mentorOnline.isOnline),
            const SizedBox(width: 4),
            Text(room.mentorUsername),
          ],
        ),
        subtitle: Text(
          'Payment: ${room.paymentStatus.isEmpty ? "n/a" : room.paymentStatus} • '
          'Unread S:${room.unreadStudent.count} M:${room.unreadMentor.count}',
        ),
        trailing: room.isFlagged
            ? const Chip(
                label: Text('Flagged'),
                backgroundColor: Color(0xFFFFE1E1),
              )
            : null,
      ),
    );
  }
}
