import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_type.dart';
import '../widgets/game_tile.dart';
import '../services/bluetooth_controller.dart';
import 'game_screen.dart';
import 'bluetooth_scan_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final btController = Provider.of<BluetoothController>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text("Universal Game Controller")),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BluetoothScanScreen()),
              );
            },
            child: const Text("Scan & Connect to Any Device"),
          ),
          Expanded(
            child: ListView(
              children: GameType.values.map((game) {
                return GameTile(
                  gameType: game,
                  onTap: () {
                    btController.selectGame(game);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const GameScreen()),
                    );
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}