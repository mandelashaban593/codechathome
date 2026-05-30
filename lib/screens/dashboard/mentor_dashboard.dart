import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../chat/chat_screen.dart';
import '../need/need_list.dart';
import '../profile/profile_screen.dart';

class MentorDashboard extends StatefulWidget {
  final String username;

  const MentorDashboard({
    Key? key,
    required this.username,
  }) : super(key: key);

  @override
  State<MentorDashboard> createState() => _MentorDashboardState();
}

class _MentorDashboardState extends State<MentorDashboard> {

  List rooms = [];
  bool isLoading = false;

  int page = 1;

  final searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    fetchRooms();
  }

  @override
  void dispose() {
    searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  //---------------- MENU ----------------

  void onMenuTap(int index) {
    Navigator.pop(context);

    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => NeedList()),
      );
    }

    if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ProfileScreen()),
      );
    }
  }

  //---------------- FETCH ----------------

  Future fetchRooms() async {
    setState(() => isLoading = true);

    try {
      final res = await ApiService.post(
        "chat/drooms/",
        {
          "username": widget.username,
          "page": page.toString(),
          "search": searchController.text,
        },
      );

      final decoded = jsonDecode(res.body);

      rooms = decoded is Map
          ? decoded["rooms"] ?? []
          : [];

    } catch (e) {
      rooms = [];
    }

    setState(() => isLoading = false);
  }

  //---------------- CHAT ----------------

  void openChat(room) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          roomId: room["id"],
          username: widget.username,

          // FIXED (case sensitive)
          mentorUsername: widget.username,
        ),
      ),
    );
  }

  //---------------- SIDEBAR ----------------

  Widget sidebarItem(IconData icon, String title, int index) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      onTap: () => onMenuTap(index),
    );
  }

  Widget buildSidebar() {
    return Container(
      color: Colors.blue.shade900,
      child: SafeArea(
        child: ListView(
          children: [
            const SizedBox(height: 40),
            const Text(
              "Mentor Panel",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),

            sidebarItem(Icons.dashboard, "Dashboard", 0),
            sidebarItem(Icons.people, "Needs", 1),
            sidebarItem(Icons.person, "Profile", 2),

            const Spacer(),

            ListTile(
              leading: const Icon(Icons.logout, color: Colors.white),
              title: const Text(
                "Logout",
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  "/login",
                  (r) => false,
                );
              },
            )
          ],
        ),
      ),
    );
  }

  //---------------- SEARCH DEBOUNCE ----------------

  void onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      fetchRooms();
    });
  }

  //---------------- CONTENT ----------------

  Widget dashboard() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(10),
          child: TextField(
            controller: searchController,
            decoration: const InputDecoration(
              hintText: "Search Need",
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: onSearchChanged,
          ),
        ),

        Expanded(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: rooms.length,
                  itemBuilder: (_, i) {
                    final room = rooms[i] ?? {};

                    return Card(
                      child: ListTile(
                        leading: const Icon(
                          Icons.person,
                          color: Colors.blue,
                        ),
                        title: Text(
                          room["student_username"] ?? "",
                        ),
                        subtitle: Text(
                          room["created"]?.toString() ?? "",
                        ),
                        trailing: const Icon(Icons.chat),
                        onTap: () => openChat(room),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  //---------------- MAIN ----------------

  @override
  Widget build(BuildContext context) {
    bool mobile = MediaQuery.of(context).size.width < 700;

    return Scaffold(
      appBar: mobile
          ? AppBar(title: const Text("Mentor Dashboard"))
          : null,

      drawer: mobile
          ? Drawer(child: buildSidebar())
          : null,

      body: mobile
          ? dashboard()
          : Row(
              children: [
                SizedBox(width: 250, child: buildSidebar()),
                Expanded(child: dashboard()),
              ],
            ),
    );
  }
}