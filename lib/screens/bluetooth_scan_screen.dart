import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/bluetooth_controller.dart';

class BluetoothScanScreen extends StatelessWidget {
  const BluetoothScanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final btController = Provider.of<BluetoothController>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Scan Bluetooth Devices")),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () async => await btController.scanDevices(),
            child: const Text("Scan Nearby Devices"),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: btController.nearbyDevices.length,
              itemBuilder: (context, index) {
                final device = btController.nearbyDevices[index];
                return ListTile(
                  title: Text(device.name ?? "Unknown Device"),
                  subtitle: Text(device.address),
                  trailing: ElevatedButton(
                    child: const Text("Connect"),
                    onPressed: () async {
                      await btController.connectToDevice(device);
                      if (btController.isConnected) Navigator.pop(context);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}