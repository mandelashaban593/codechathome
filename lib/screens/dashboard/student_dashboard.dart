import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../chat/chat_screen.dart';
import '../need/need_list.dart';
import '../need/create_need.dart';
import '../profile/profile_screen.dart';

class StudentDashboard extends StatefulWidget {
  final String username;

  const StudentDashboard({
    Key? key,
    required this.username,
  }) : super(key: key);

  @override
  State<StudentDashboard> createState() =>
      _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {

  List rooms = [];
  bool isLoading = false;

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
        MaterialPageRoute(builder: (_) => CreateNeed()),
      );
    }

    if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => NeedList()),
      );
    }

    if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ProfileScreen()),
      );
    }
  }

  Widget sidebarItem(IconData icon, String title, int index) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      onTap: () => onMenuTap(index),
    );
  }

  //---------------- FETCH ----------------

  Future fetchRooms() async {
    setState(() => isLoading = true);

    try {
      final res = await ApiService.post(
        "chat/rooms/",
        {
          "username": widget.username,
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

  void openmentorRoom(dynamic room) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          roomId: room["id"],
          username: widget.username,

          // FIXED: must match constructor exactly
          mentorUsername: room["mentor_username"] ?? "",

          
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

  //---------------- SIDEBAR ----------------

  Widget buildSidebar() {
    return Container(
      color: Colors.blue.shade900,
      child: SafeArea(
        child: ListView(
          children: [
            const SizedBox(height: 40),
            const Text(
              "Student Panel",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),

            sidebarItem(Icons.dashboard, "Dashboard", 0),
            sidebarItem(Icons.add, "Create Need", 1),
            sidebarItem(Icons.list, "My Needs", 2),
            sidebarItem(Icons.person, "Profile", 3),

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

  //---------------- UI ----------------

  @override
  Widget build(BuildContext context) {
    bool mobile = MediaQuery.of(context).size.width < 700;

    Widget content = Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(10),
          child: TextField(
            controller: searchController,
            decoration: const InputDecoration(
              hintText: "Search mentor",
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
                        title: Text(
                          room["mentor_username"]?.toString() ?? "Unknown",
                        ),
                        subtitle: Text(
                          room["created"]?.toString() ?? "",
                        ),
                        trailing: const Icon(Icons.chat),
                        onTap: () => openmentorRoom(room),
                      ),
                    );
                  },
                ),
        )
      ],
    );

    return Scaffold(
      appBar: mobile
          ? AppBar(title: const Text("Student Dashboard"))
          : null,

      drawer: mobile
          ? Drawer(child: buildSidebar())
          : null,

      body: mobile
          ? content
          : Row(
              children: [
                SizedBox(width: 250, child: buildSidebar()),
                Expanded(child: content),
              ],
            ),
    );
  }
}