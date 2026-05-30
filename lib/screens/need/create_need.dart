import 'dart:convert';
import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../auth/home_login_screen.dart';
import '../auth/register_screen.dart';

import '../infopages/contact_screen.dart';
import '../infopages/privacy_screen.dart';
import '../infopages/termscond_screen.dart';

class CreateNeed extends StatefulWidget {
  const CreateNeed({Key? key}) : super(key: key);

  @override
  State<CreateNeed> createState() => _CreateNeedState();
}

class _CreateNeedState extends State<CreateNeed> {
  final firstName = TextEditingController();
  final learningNeed = TextEditingController();
  final phone = TextEditingController();

  final List<String> mentors = [
    "mentor_shaban",
    "mentor_hans"
  ];

  String? selectedMentor;
  bool isLoading = false;

  @override
  void dispose() {
    firstName.dispose();
    learningNeed.dispose();
    phone.dispose();
    super.dispose();
  }

  void showMsg(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> create() async {
    if (firstName.text.trim().isEmpty) {
      showMsg("First name is required");
      return;
    }

    if (selectedMentor == null) {
      showMsg("Please select a Mentor");
      return;
    }

    setState(() => isLoading = true);

    try {
      final username = firstName.text.trim();

      final res = await ApiService.post(
        "learning-support/create/",
        {
          "student": username,
          "mentor": selectedMentor ?? "",
          "learning_need": learningNeed.text.trim(),
          "phone": phone.text.trim(),
        },
      );



      Map<String, dynamic> data = {};
      try {
        data = jsonDecode(res.body);
      } catch (_) {}

      if (res.statusCode == 200) {
        showMsg("Need submitted successfully");

        final checkRes = await ApiService.post(
          "check-user/",
          {"username": username},
        );

        Map<String, dynamic> checkData = {};
        try {
          checkData = jsonDecode(checkRes.body);
        } catch (_) {}

        if (checkData["exists"] == true) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const HomeLoginScreen(),
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  RegisterScreen(username: username),
            ),
          );
        }
      } else {
        showMsg(
          data["error"]?.toString() ?? "Something went wrong",
        );
      }
    } catch (e) {
      showMsg("Network error");
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Widget buildTopNavigation() {
    return Row(
      children: [
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const HomeLoginScreen(),
              ),
            );
          },
          child: const Text(
            "Login",
            style: TextStyle(color: Colors.white),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const RegisterScreen(),
              ),
            );
          },
          child: const Text(
            "Register",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget buildFooter() {
    return Container(
      width: double.infinity,
      color: Colors.blue,
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 20,
            children: [
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ContactScreen(), // ❌ removed const
                  ),
                ),
                child: const Text("Contact",
                    style: TextStyle(color: Colors.white)),
              ),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PrivacyScreen(), // ❌ removed const
                  ),
                ),
                child: const Text("Privacy",
                    style: TextStyle(color: Colors.white)),
              ),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TermsCondScreen(), // ❌ removed const
                  ),
                ),
                child: const Text("Terms",
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            "Codechathome - Learn from Software Development Trainers online anytime, anywhere in Uganda.",
            style: TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Row(
          children: [
            Image.asset(
              "assets/images/codechathome.png",
              height: 35,
              errorBuilder: (c, e, s) =>
                  const Icon(Icons.school, color: Colors.white),
            ),
            const SizedBox(width: 10),
            const Text("Create Need",
                style: TextStyle(color: Colors.white)),
          ],
        ),
        actions: [buildTopNavigation()],
      ),

      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/images/softtutor.png",
              fit: BoxFit.cover,
              errorBuilder: (c, e, s) =>
                  Container(color: Colors.grey),
            ),
          ),

          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.4),
            ),
          ),

          Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    const Text(
                      "User Details",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 15),

                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          TextField(
                            controller: firstName,
                            decoration: const InputDecoration(
                              labelText: "First Name",
                            ),
                          ),
                          const SizedBox(height: 15),

                          DropdownButtonFormField<String>(
                            value: selectedMentor,
                            items: mentors
                                .map((m) => DropdownMenuItem(
                                      value: m,
                                      child: Text(m),
                                    ))
                                .toList(),
                            onChanged: (val) =>
                                setState(() => selectedMentor = val),
                            decoration: const InputDecoration(
                              labelText: "Select Mentor",
                            ),
                          ),

                          const SizedBox(height: 15),

                          TextField(
                            controller: learningNeed,
                            maxLines: 2,
                            decoration: const InputDecoration(
                              labelText: "Learning Need",
                            ),
                          ),

                          const SizedBox(height: 15),

                          TextField(
                            controller: phone,
                            decoration: const InputDecoration(
                              labelText: "Phone",
                            ),
                          ),

                          const SizedBox(height: 25),

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed:
                                  isLoading ? null : create,
                              child: isLoading
                                  ? const CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    )
                                  : const Text("Submit"),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              buildFooter(),
            ],
          ),
        ],
      ),
    );
  }
}