import 'package:flutter/material.dart';
import '../services/controller_service.dart';
import '../widgets/remote_button.dart';
import 'games_screen.dart';

class RemoteScreen extends StatelessWidget {

  final ControllerService service;

  RemoteScreen(this.service);

  Widget numButton(String n){
    return RemoteButton(
      label: n,
      onPressed: ()=>service.send(n)
    );
  }

  @override
  Widget build(BuildContext context){

    return Scaffold(

      appBar: AppBar(title: Text("Remote Control")),

      body: SingleChildScrollView(

        child: Column(

          children: [

            SizedBox(height:20),

            RemoteButton(
              label: "UP",
              onPressed: ()=>service.send("UP")
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                RemoteButton(
                  label: "LEFT",
                  onPressed: ()=>service.send("LEFT")
                ),

                RemoteButton(
                  label: "OK",
                  onPressed: ()=>service.send("OK")
                ),

                RemoteButton(
                  label: "RIGHT",
                  onPressed: ()=>service.send("RIGHT")
                )

              ],
            ),

            RemoteButton(
              label: "DOWN",
              onPressed: ()=>service.send("DOWN")
            ),

            SizedBox(height:30),

            Wrap(
              alignment: WrapAlignment.center,
              children: [

                numButton("1"),
                numButton("2"),
                numButton("3"),
                numButton("4"),
                numButton("5"),
                numButton("6"),
                numButton("7"),
                numButton("8"),
                numButton("9"),
                numButton("0")

              ],
            ),

            SizedBox(height:30),

            ElevatedButton(

              onPressed: (){

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_)=>GamesScreen(service)
                  )
                );

              },

              child: Text("Games")

            )

          ],

        ),

      ),

    );

  }

}