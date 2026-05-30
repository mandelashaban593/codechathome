import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../config/api_config.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({Key? key}) : super(key: key);

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  Map<String, dynamic> contactData = {};
  String debugMessage = "";
  bool isLoading = true;

  final String baseUrl = ApiConfig.baseUrl;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    setState(() {
      isLoading = true;
      debugMessage = "Fetching contact info...";
    });

    try {
      final url = Uri.parse("${baseUrl}info/contact/");

      final res = await http.get(
        url,
        headers: {"Content-Type": "application/json"},
      );

      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);

        setState(() {
          contactData = decoded is Map<String, dynamic>
              ? decoded
              : {};
          debugMessage = "Contact loaded successfully";
          isLoading = false;
        });
      } else {
        setState(() {
          debugMessage = "Server error: ${res.statusCode}";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        debugMessage = "Exception: $e";
        isLoading = false;
      });
    }
  }

  Widget buildField(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        "$label: ${value?.toString() ?? '-'}",
        style: const TextStyle(fontSize: 15),
      ),
    );
  }

  Widget buildCard(Widget child) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6),
        ],
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF3FF),

      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text("Contact Us"),
        actions: [
          IconButton(
            onPressed: loadData,
            icon: const Icon(Icons.refresh),
          )
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  buildCard(
                    Text(
                      debugMessage,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),

                  const SizedBox(height: 12),

                  Expanded(
                    child: buildCard(
                      SingleChildScrollView(
                        child: contactData.isEmpty
                            ? const Text("No contact data found")
                            : Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    contactData["heading"] ?? "",
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  const SizedBox(height: 6),

                                  Text(
                                    contactData["subheading"] ?? "",
                                    style: const TextStyle(
                                      color: Colors.grey,
                                    ),
                                  ),

                                  const Divider(height: 25),

                                  buildField(
                                      "Title",
                                      contactData["title"]),
                                  buildField(
                                      "Address",
                                      contactData["address"]),
                                  buildField(
                                      "Phone",
                                      contactData["phone"]),
                                  buildField(
                                      "Email",
                                      contactData["email"]),
                                  buildField(
                                      "Hours",
                                      contactData["hours"]),
                                ],
                              ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}