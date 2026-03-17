import 'package:flutter/material.dart';
import '../services/controller_service.dart';
import '../widgets/remote_button.dart';

class GamesScreen extends StatelessWidget {

  final ControllerService service;

  GamesScreen(this.service);

  List<String> games = [

    "Cutpoopia",
    "Cup2TV",
    "Rent ParTay",
    "Money Mouthy",
    "Aah Star",
    "MyaiLES",
    "DaBouKay",
    "GoZarr",
    "UnHousedDocs",
    "Pholossy",
    "ChexN",
    "Lite It Up",
    "cGames",
    "Casshey"

  ];

  @override
  Widget build(BuildContext context){

    return Scaffold(

      appBar: AppBar(title: Text("Games")),

      body: GridView.builder(

        padding: EdgeInsets.all(20),

        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 15,
          crossAxisSpacing: 15
        ),

        itemCount: games.length,

        itemBuilder:(context,index){

          return RemoteButton(

            label: games[index],

            onPressed: (){
              service.send("GAME:${games[index]}");
            }

          );

        },

      ),

    );

  }

}