import 'dart:convert';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class AdminDashboard extends StatefulWidget {
  final String username;

  const AdminDashboard({
    Key? key,
    required this.username,
  }) : super(key: key);

  @override
  _AdminDashboardState createState() =>
      _AdminDashboardState();
}

class _AdminDashboardState
    extends State<AdminDashboard> {

  List users = [];
  List need = [];

  bool isLoading = true;

  Future<void> load() async {

    try {

      var u =
      await ApiService.get(
          "profiles/"
      );

      var i =
      await ApiService.get(
          "learning-support/"
      );

      setState(() {

        users =
        jsonDecode(
            u.body);

        need =
        jsonDecode(
            i.body);

      });

    }

    catch(e){

      print(
          "Admin load error: $e"
      );

    }

    setState(() {
      isLoading=false;
    });

  }

  @override
  void initState() {
    super.initState();
    load();
  }

  Widget buildList(
      List list,
      String key){

    if(list.isEmpty){

      return Center(
        child:
        Text("No data"),
      );

    }

    return ListView(

      children:

      list.map((item){

        return ListTile(

          leading:
          Icon(
              Icons.arrow_right
          ),

          title:
          Text(

            item[key]
                ?.toString()

                ??

            "",

          ),

        );

      }).toList(),

    );

  }

  @override
  Widget build(
      BuildContext context){

    return DefaultTabController(

      length:2,

      child:

      Scaffold(

        appBar:

        AppBar(

          title:

          Text(

            "Admin Dashboard "
                "(${widget.username})",

          ),

          bottom:

          TabBar(

            tabs:[

              Tab(
                  text:
                  "Users"
              ),

              Tab(
                  text:
                  "Needs"
              ),

            ],

          ),

        ),

        body:

        isLoading

            ?

        Center(
            child:
            CircularProgressIndicator()
        )

            :

        TabBarView(

          children:[

            //---------------- USERS

            buildList(
                users,
                "username"
            ),

            //---------------- NEEDS

            buildList(
                need,
                "signs"
            ),

          ],

        ),

      ),

    );

  }

}