import 'dart:convert';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class StudentList extends StatefulWidget {
  @override
  State<StudentList> createState() => _StudentListState();
}

class _StudentListState extends State<StudentList> {
  List data = [], filtered = [];

  int page = 1, perPage = 10;
  String search = "";
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future load() async {
    setState(() => isLoading = true);

    try {
      var res = await ApiService.get("Students/");
      data = jsonDecode(res.body);
      apply();
    } catch (e) {
      debugPrint("Error: $e");
      data = [];
    }

    setState(() => isLoading = false);
  }

  void apply() {
    filtered = data.where((e) {
      final username = (e["username"] ?? "").toLowerCase();
      final email = (e["email"] ?? "").toLowerCase();
      final phone = (e["phone"] ?? "").toLowerCase();

      return username.contains(search.toLowerCase()) ||
          email.contains(search.toLowerCase()) ||
          phone.contains(search.toLowerCase());
    }).toList();

    setState(() => page = 1);
  }

  List get paged {
    int start = (page - 1) * perPage;
    return filtered.skip(start).take(perPage).toList();
  }

  int get total => (filtered.length / perPage).ceil();

  void openSearch() async {
    var q = await showDialog(
      context: context,
      builder: (_) {
        TextEditingController c = TextEditingController();
        return AlertDialog(
          title: Text("Search Student"),
          content: TextField(
            controller: c,
            decoration: InputDecoration(
              hintText: "Username, Email or Phone",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, c.text),
              child: Text("OK"),
            ),
          ],
        );
      },
    );

    if (q != null) {
      search = q;
      apply();
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 800;

        return Scaffold(
          backgroundColor: Colors.white,

          // ✅ MOBILE SIDEBAR (Drawer)
          drawer: isDesktop ? null : _buildDrawer(),

          appBar: AppBar(
            title: Text("Students"),
            backgroundColor: Colors.blue,
            actions: [
              IconButton(
                icon: Icon(Icons.search),
                onPressed: openSearch,
              ),
            ],
          ),

          body: isLoading
              ? Center(child: CircularProgressIndicator(color: Colors.blue))
              : isDesktop
                  ? Row(
                      children: [
                        // ✅ SIDEBAR (DESKTOP)
                        _buildSideBar(),

                        // ✅ MAIN CONTENT (IMPORTANT FIX: Expanded prevents slim view)
                        Expanded(child: _buildMainContent()),
                      ],
                    )
                  : _buildMainContent(),
        );
      },
    );
  }

  // ================= SIDEBAR =================
  Widget _buildSideBar() {
    return Container(
      width: 250,
      color: Colors.blue.shade50,
      child: ListView(
        children: [
          DrawerHeader(
            child: Text(
              "Menu",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            leading: Icon(Icons.people),
            title: Text("Students"),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text("Settings"),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer() => _buildSideBar();

  // ================= MAIN CONTENT =================
  Widget _buildMainContent() {
    return Column(
      children: [
        Expanded(
          child: filtered.isEmpty
              ? Center(child: Text("No Students found"))
              : ListView(
                  children: paged
                      .map(
                        (e) => Card(
                          margin: EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          child: ListTile(
                            leading:
                                Icon(Icons.person, color: Colors.blue),
                            title: Text(
                              e["username"] ?? "",
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Email: ${e["email"] ?? ""}"),
                                Text("Phone: ${e["phone"] ?? ""}"),
                                Text("Role: ${e["role"] ?? ""}"),
                              ],
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
        ),

        // ================= PAGINATION =================
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed:
                  page > 1 ? () => setState(() => page--) : null,
              child: Text("Prev", style: TextStyle(color: Colors.blue)),
            ),

            ...List.generate(
              total,
              (i) => GestureDetector(
                onTap: () => setState(() => page = i + 1),
                child: Padding(
                  padding: EdgeInsets.all(4),
                  child: Text(
                    "${i + 1}",
                    style: TextStyle(
                      color: page == i + 1 ? Colors.blue : Colors.black,
                      fontWeight:
                          page == i + 1 ? FontWeight.bold : null,
                    ),
                  ),
                ),
              ),
            ),

            TextButton(
              onPressed:
                  page < total ? () => setState(() => page++) : null,
              child: Text("Next", style: TextStyle(color: Colors.blue)),
            ),
          ],
        )
      ],
    );
  }
}