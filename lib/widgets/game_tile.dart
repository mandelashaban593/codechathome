import 'package:flutter/material.dart';
import '../models/game_type.dart';

class GameTile extends StatelessWidget {
  final GameType gameType;
  final VoidCallback onTap;

  const GameTile({super.key, required this.gameType, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: ListTile(
          leading: const Icon(Icons.videogame_asset),
          title: Text(gameType.name),
        ),
      ),
    );
  }
}