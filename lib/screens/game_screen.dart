import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/bluetooth_controller.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final btController = Provider.of<BluetoothController>(context);

    return Scaffold(
      appBar: AppBar(title: Text("${btController.currentGame?.name ?? 'Game'} Control")),
      body: GestureDetector(
        onPanUpdate: (details) {
          if (details.delta.dx > 0) btController.moveRight();
          else if (details.delta.dx < 0) btController.moveLeft();
          if (details.delta.dy > 0) btController.moveDown();
          else if (details.delta.dy < 0) btController.moveUp();
        },
        onTap: () => btController.performAction(),
        child: Center(
          child: Text(
            "Use gestures to control the ${btController.currentGame?.name} game on any connected device",
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}