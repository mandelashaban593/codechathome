// lib/screens/receiver_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class ReceiverScreen extends StatefulWidget {
  const ReceiverScreen({super.key});

  @override
  State<ReceiverScreen> createState() => _ReceiverScreenState();
}

class _ReceiverScreenState extends State<ReceiverScreen> {
  BluetoothServerSocket? server;
  String received = "";

  @override
  void initState() {
    super.initState();
    startServer();
  }

  void startServer() async {
    server = await FlutterBluetoothSerial.instance
        .listenForIncomingConnections();
    server!.listen((connection) {
      connection.input!.listen((data) {
        setState(() {
          received = String.fromCharCodes(data);
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Receiver Mode")),
      body: Center(child: Text("Received: $received")),
    );
  }
}