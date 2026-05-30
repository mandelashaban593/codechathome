import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_html/flutter_html.dart';

import '../../config/api_config.dart';

class TermsCondScreen extends StatefulWidget {
  const TermsCondScreen({Key? key}) : super(key: key);

  @override
  State<TermsCondScreen> createState() => _TermsCondScreenState();
}

class _TermsCondScreenState extends State<TermsCondScreen> {
  String content = "Loading...";
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
      debugMessage = "Fetching terms & conditions...";
    });

    try {
      final url = Uri.parse("${baseUrl}info/terms/");

      final res = await http.get(
        url,
        headers: {"Content-Type": "application/json"},
      );

      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);

        setState(() {
          content = decoded is Map<String, dynamic>
              ? (decoded["content"] ?? "No terms available")
              : "Invalid response format";

          debugMessage = "Terms loaded successfully";
          isLoading = false;
        });
      } else {
        setState(() {
          content = "Server error: ${res.statusCode}";
          debugMessage = res.body;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        content = "Failed to load terms and conditions";
        debugMessage = e.toString();
        isLoading = false;
      });
    }
  }

  Widget buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
          )
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
        title: const Text("Terms & Conditions"),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: loadData,
          )
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  buildCard(
                    child: Text(
                      debugMessage,
                      style: const TextStyle(
                        color: Colors.green,
                        fontSize: 12,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  Expanded(
                    child: buildCard(
                      child: SingleChildScrollView(
                        child: (content.contains("<"))
                            ? Html(data: content)
                            : Text(
                                content,
                                style: const TextStyle(
                                  fontSize: 16,
                                  height: 1.5,
                                ),
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