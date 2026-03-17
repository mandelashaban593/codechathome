import 'dart:html' as html;

class ControllerService {

  html.WebSocket? socket;

  Future connect(String ip) async {

    socket = html.WebSocket("ws://$ip:5000");

    socket!.onOpen.listen((event) {
      print("Connected to PC");
    });

  }

  void send(String command){

    if(socket != null){
      socket!.send(command);
    }

  }

  void disconnect(){

    socket?.close();

  }

}