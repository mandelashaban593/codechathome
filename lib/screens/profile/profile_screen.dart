import 'dart:convert';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map data = {};

  load() async {
    var res = await ApiService.get("profiles/");
    var list = jsonDecode(res.body);

    if (list.isNotEmpty) {
      setState(() => data = list[0]);
    }
  }

  update() async {
    await ApiService.post("profiles/update/${data["id"]}/", {
      "phone": data["phone"]
    }, auth: true);
  }

  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Profile")),
      body: data.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Text("Username: ${data["username"]}"),
                Text("Role: ${data["role"]}"),
                TextField(
                  decoration: InputDecoration(labelText: "Phone"),
                  onChanged: (v) => data["phone"] = v,
                ),
                ElevatedButton(onPressed: update, child: Text("Update"))
              ],
            ),
    );
  }
}