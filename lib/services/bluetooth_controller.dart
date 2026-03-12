import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import '../models/game_type.dart'; // your enum

class BluetoothController with ChangeNotifier {
  FlutterBluetoothSerial bluetooth = FlutterBluetoothSerial.instance;

  // Bluetooth state
  bool isBluetoothEnabled = false;
  bool get isConnected => connection?.isConnected ?? false;

  // Discovered devices
  List<BluetoothDevice> nearbyDevices = [];

  // Connected device
  BluetoothConnection? connection;

  // Selected game
  GameType? currentGame;

  BluetoothController() {
    initBluetooth();
  }

  // Initialize Bluetooth
  Future<void> initBluetooth() async {
    isBluetoothEnabled = await bluetooth.isEnabled ?? false;
    notifyListeners();

    bluetooth.onStateChanged().listen((state) {
      isBluetoothEnabled = state == BluetoothState.STATE_ON;
      notifyListeners();
    });
  }

  // ================== Game Control Methods ==================

  void selectGame(GameType game) {
    currentGame = game;
    notifyListeners();
  }

  void moveUp() => sendData("MOVE_UP");
  void moveDown() => sendData("MOVE_DOWN");
  void moveLeft() => sendData("MOVE_LEFT");
  void moveRight() => sendData("MOVE_RIGHT");
  void performAction() => sendData("ACTION");

  // ================== Bluetooth Methods ==================

  Future<void> scanDevices() async {
    nearbyDevices.clear();

    bluetooth.startDiscovery().listen((result) {
      final device = result.device;
      if (!nearbyDevices.any((d) => d.address == device.address)) {
        nearbyDevices.add(device);
        notifyListeners();
      }
    }).onDone(() {
      debugPrint("Discovery done: found ${nearbyDevices.length} devices");
    });
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    try {
      connection = await BluetoothConnection.toAddress(device.address);
      debugPrint('Connected to ${device.name}');
      notifyListeners();
    } catch (e) {
      debugPrint('Connection failed: $e');
    }
  }

  Future<void> disconnect() async {
    await connection?.close();
    connection = null;
    notifyListeners();
  }

  void sendData(String data) {
    if (connection != null && connection!.isConnected) {
      connection!.output.add(utf8.encode(data + "\n")); // fixed Utf8Encoder
      debugPrint("Sent: $data");
    } else {
      debugPrint("No device connected.");
    }
  }
}