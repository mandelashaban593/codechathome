import 'package:web_socket_channel/web_socket_channel.dart';
import '../config/api_config.dart';
import 'dart:convert';

class SocketService {
  late WebSocketChannel channel;

  connect(room) {
    channel = WebSocketChannel.connect(
      Uri.parse("${ApiConfig.socketUrl}$room/"),
    );
  }

  send(String message) {
    channel.sink.add(jsonEncode({"message": message}));
  }

  stream() {
    return channel.stream;
  }

  close() {
    channel.sink.close();
  }
}