import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/controller_service.dart';

class GamesScreen extends StatelessWidget {
  final ControllerService service;

  GamesScreen(this.service);

  // Game links
  final Map<String, String> gameLinks = {
    "Cuptoopia": "https://www.cuptoopia.com",
    "Cup2TV": "https://www.cup2tv.com",
    "ChexN": "https://www.chexn.com",
    "Lite It Up": "https://play.google.com", // placeholder
    "Aah Star": "https://www.aahstar.com",
    "MyPaiLES": "https://www.mypailes.com",
    "Rent ParTay": "https://www.rentpartay.com",
    "Money Mouthy": "https://www.moneymouthy.com",
    "Hashtag Dollars": "https://www.hashtagdollars.com",
    "UnHousedDocs": "https://www.unhouseddocs.com",
    "Casshey": "https://www.casshey.com",
    "GoZarr": "https://www.gozarr.com",
    "TQR, Inc": "https://www.tqrinc.com",
  };

  Future<void> openLink(String game) async {
    final url = Uri.parse(gameLinks[game]!);

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Widget controllerButton(String label, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: CircleBorder(),
        padding: EdgeInsets.all(20),
      ),
      onPressed: onPressed,
      child: Text(
        label,
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget gameButton(String name) {
    return GestureDetector(
      onTap: () async {
        service.send("GAME:$name");
        await openLink(name);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(color: Colors.black45, blurRadius: 5)
          ],
        ),
        padding: EdgeInsets.all(10),
        child: Center(
          child: Text(
            name,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("Game Controller"),
        backgroundColor: Colors.black,
      ),
      body: Column(
        children: [

          /// 🎮 TOP GAME BUTTON GRID
          Expanded(
            flex: 2,
            child: GridView.count(
              padding: EdgeInsets.all(10),
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              children: gameLinks.keys.map((game) {
                return gameButton(game);
              }).toList(),
            ),
          ),

          /// 🎮 CONTROLLER SECTION
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [

                /// 🔼 D-PAD (LEFT SIDE)
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    controllerButton("↑", Colors.red, () {
                      service.send("UP");
                    }),
                    Row(
                      children: [
                        controllerButton("←", Colors.blue, () {
                          service.send("LEFT");
                        }),
                        SizedBox(width: 10),
                        controllerButton("→", Colors.green, () {
                          service.send("RIGHT");
                        }),
                      ],
                    ),
                    controllerButton("↓", Colors.orange, () {
                      service.send("DOWN");
                    }),
                  ],
                ),

                /// 🎮 ACTION BUTTONS (RIGHT SIDE)
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    controllerButton("A", Colors.green, () {
                      service.send("A");
                    }),
                    SizedBox(height: 10),
                    controllerButton("B", Colors.red, () {
                      service.send("B");
                    }),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}