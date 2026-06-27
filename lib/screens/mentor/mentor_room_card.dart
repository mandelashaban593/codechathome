import 'package:flutter/material.dart';
import 'mentor_models.dart';

class MentorRoomCard
    extends StatelessWidget {

  final MentorRoom room;
  final VoidCallback onTap;

  const MentorRoomCard({
    super.key,
    required this.room,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {

    return Card(
      child: ListTile(

        leading: Stack(
          children: [

            const CircleAvatar(
              child:
                  Icon(Icons.person),
            ),

            Positioned(
              bottom: 0,
              right: 0,

              child: Container(
                width: 12,
                height: 12,

                decoration:
                    BoxDecoration(
                  color: room.online
                      ? Colors.green
                      : Colors.grey,

                  shape:
                      BoxShape.circle,
                ),
              ),
            ),
          ],
        ),

        title:
            Text(room.studentUsername),

        subtitle:
            Text(room.created),

        trailing:
            room.unreadCount > 0
                ? CircleAvatar(
                    radius: 12,

                    backgroundColor:
                        Colors.red,

                    child: Text(
                      room.unreadCount
                          .toString(),

                      style:
                          const TextStyle(
                        color:
                            Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  )
                : const Icon(
                    Icons.chat),

        onTap: onTap,
      ),
    );
  }
}