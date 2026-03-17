import 'package:flutter/material.dart';
import '../services/controller_service.dart';
import 'remote_screen.dart';

class ConnectScreen extends StatefulWidget {
  @override
  _ConnectScreenState createState()=>_ConnectScreenState();
}

class _ConnectScreenState extends State<ConnectScreen>{

  TextEditingController ipController = TextEditingController();
  ControllerService service = ControllerService();

  connect() async{

    await service.connect(ipController.text);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RemoteScreen(service)
      )
    );

  }

  @override
  Widget build(BuildContext context){

    return Scaffold(

      appBar: AppBar(title: Text("Connect to PC")),

      body: Padding(

        padding: EdgeInsets.all(20),

        child: Column(

          children: [

            TextField(
              controller: ipController,
              decoration: InputDecoration(
                labelText: "Enter PC IP Address"
              ),
            ),

            SizedBox(height:20),

            ElevatedButton(
              onPressed: connect,
              child: Text("Connect")
            )

          ],

        ),

      ),

    );

  }
}