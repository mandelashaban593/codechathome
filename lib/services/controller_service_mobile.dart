import 'dart:io';

class ControllerService {

  WebSocket? socket;

  Future connect(String ip) async {

    socket = await WebSocket.connect("ws://$ip:5000");

    print("Connected to PC");

  }

  void send(String command){

    if(socket != null){
      socket!.add(command);
    }

  }

  void disconnect(){

    socket?.close();

  }

}