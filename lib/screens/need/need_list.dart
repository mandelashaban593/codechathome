import 'dart:convert';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class NeedList extends StatefulWidget {
  const NeedList({super.key});

  @override
  State<NeedList> createState() => _NeedListState();
}

class _NeedListState extends State<NeedList> {
  List data = [];
  List filtered = [];

  int page = 1;
  int perPage = 10;

  String search = "";
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    load();
  }

  //---------------- LOAD ----------------

  Future load() async {
    setState(() => isLoading = true);

    try {
      var res = await ApiService.get("learning-support/");
      final decoded = jsonDecode(res.body);

      data = decoded is List ? decoded : [];
      apply();
    } catch (e) {
      data = [];
      filtered = [];
    }

    setState(() => isLoading = false);
  }

  //---------------- FILTER ----------------

  void apply() {
    final q = search.toLowerCase();

    filtered = data.where((e) {
      final need = (e["learning_need"] ?? "").toString().toLowerCase();
      final mentor = (e["mentor"] ?? "").toString().toLowerCase();

      return need.contains(q) || mentor.contains(q);
    }).toList();

    setState(() => page = 1);
  }

  //---------------- PAGINATION ----------------

  List get paged {
    final start = (page - 1) * perPage;

    if (start >= filtered.length) return [];

    return filtered.skip(start).take(perPage).toList();
  }

  int get total {
    if (filtered.isEmpty) return 1;
    return (filtered.length / perPage).ceil();
  }

  bool get isLargeScreen {
    return MediaQuery.of(context).size.width >= 800;
  }

  //---------------- UI ----------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      drawer: isLargeScreen ? null : _buildSideBar(),

      appBar: AppBar(
        title: const Text("Learning Needs"),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _showSearchDialog,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: load,
          ),
        ],
      ),

      body: isLargeScreen
          ? Row(
              children: [
                _buildSideBar(),
                Expanded(child: _buildBody()),
              ],
            )
          : _buildBody(),
    );
  }

  //---------------- BODY ----------------

  Widget _buildBody() {
    return Column(
      children: [
        Expanded(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildList(),
        ),

        _buildPagination(),
      ],
    );
  }

  //---------------- SIDEBAR ----------------

  Widget _buildSideBar() {
    return Container(
      width: 260,
      color: Colors.blue.shade50,
      child: SafeArea(
        child: ListView(
          children: const [
            DrawerHeader(
              child: Text(
                "Menu",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.school),
              title: Text("Learning Needs"),
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text("Mentors"),
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text("Settings"),
            ),
          ],
        ),
      ),
    );
  }

  //---------------- LIST ----------------

  Widget _buildList() {
    if (paged.isEmpty) {
      return const Center(
        child: Text("No data found"),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: paged.length,
      itemBuilder: (_, i) {
        final e = paged[i] ?? {};

        return Card(
          elevation: 2,
          child: ListTile(
            title: Text(
              e["learning_need"]?.toString() ?? "Unknown Need",
              style: const TextStyle(color: Colors.black),
            ),
            subtitle: Text(
              "Mentor: ${e["mentor"] ?? ""}",
              style: const TextStyle(color: Colors.black54),
            ),
          ),
        );
      },
    );
  }

  //---------------- PAGINATION ----------------

  Widget _buildPagination() {
    if (filtered.isEmpty) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: page > 1 ? () => setState(() => page--) : null,
              child: const Text("Prev"),
            ),

            ...List.generate(total, (i) {
              final selected = page == i + 1;

              return GestureDetector(
                onTap: () => setState(() => page = i + 1),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.all(6),
                  child: Text(
                    "${i + 1}",
                    style: TextStyle(
                      color: selected ? Colors.blue : Colors.black,
                      fontWeight:
                          selected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }),

            TextButton(
              onPressed:
                  page < total ? () => setState(() => page++) : null,
              child: const Text("Next"),
            ),
          ],
        ),
      ),
    );
  }

  //---------------- SEARCH ----------------

  Future _showSearchDialog() async {
    final c = TextEditingController();

    final q = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Search"),
        content: TextField(controller: c),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, c.text),
            child: const Text("Search"),
          ),
        ],
      ),
    );

    if (q != null) {
      setState(() {
        search = q;
      });
      apply();
    }
  }
}