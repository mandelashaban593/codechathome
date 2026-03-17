import 'package:flutter/material.dart';
import 'screens/connect_screen.dart';

void main() {
  runApp(GALRemoteApp());
}

class GALRemoteApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "GAL Remote",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: ConnectScreen(),
    );
  }
}