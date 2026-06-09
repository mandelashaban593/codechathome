import 'dart:convert';
import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../services/auth_service.dart';

import '../student/student_dashboard.dart';
import '../mentor/mentor_dashboard.dart';
import '../dashboard/admin_dashboard.dart';

import '../auth/register_screen.dart';
import '../infopages/contact_screen.dart';
import '../infopages/privacy_screen.dart';
import '../infopages/termscond_screen.dart';

class HomeLoginScreen extends StatefulWidget {
  const HomeLoginScreen({Key? key}) : super(key: key);

  @override
  _HomeLoginScreenState createState() =>
      _HomeLoginScreenState();
}

class _HomeLoginScreenState extends State<HomeLoginScreen> {

  final user = TextEditingController();
  final pass = TextEditingController();

  bool isLoading = false;

  void showMsg(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  void dispose() {
    user.dispose();
    pass.dispose();
    super.dispose();
  }

  // ================= LOGIN =================
  Future<void> login(BuildContext context) async {

    if (user.text.trim().isEmpty ||
        pass.text.trim().isEmpty) {
      return showMsg("Username and password required");
    }

    setState(() => isLoading = true);

    try {

      final res = await ApiService.post(
        "login/",
        {
          "username": user.text.trim(),
          "password": pass.text.trim(),
        },
        auth: false,
      );

      final data = jsonDecode(res.body);

      if (res.statusCode != 200 || data["token"] == null) {
        showMsg(data["error"] ?? "Login failed");
        setState(() => isLoading = false);
        return;
      }

      // ================= SAVE USER =================
      await AuthService.saveUser(
        data["token"],
        data["role"],
        data["username"],
      );

      // ================= DEBUG LOGS =================
      print("\n================ LOGIN SUCCESS ================");
      print("TOKEN: ${data["token"]}");
      print("ROLE: ${data["role"]}");
      print("USERNAME: ${data["username"]}");
      print("==============================================\n");

      String username = data["username"];

      // ================= NAVIGATION =================
      if (data["role"] == "admin") {

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) =>
                AdminDashboard(username: username),
          ),
        );

      } else if (data["role"] == "mentor") {

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) =>
                MentorDashboard(username: username),
          ),
        );

      } else {

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) =>
                StudentDashboard(username: username),
          ),
        );
      }

    } catch (e) {
      print("LOGIN ERROR: $e");
      showMsg("Network error");
    }

    setState(() => isLoading = false);
  }

  // ================= NAV =================
  Widget buildTopNavigation() {
    return Row(
      children: [
        TextButton(
          onPressed: () {},
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
                builder: (_) =>
                    const RegisterScreen(),
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

  // ================= FOOTER =================
  Widget buildFooter() {
    return Container(
      width: double.infinity,
      color: Colors.blue,
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [

          Wrap(
            spacing: 20,
            children: [

              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ContactScreen(),
                    ),
                  );
                },
                child: const Text(
                  "Contact",
                  style: TextStyle(color: Colors.white),
                ),
              ),

              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PrivacyScreen(),
                    ),
                  );
                },
                child: const Text(
                  "Privacy",
                  style: TextStyle(color: Colors.white),
                ),
              ),

              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TermsCondScreen(),
                    ),
                  );
                },
                child: const Text(
                  "Terms",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          const Text(
            "CodeChathome - Learn anytime, anywhere",
            style: TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Row(
          children: [
            Image.asset("assets/images/softtutor.png", height: 35),
            const SizedBox(width: 10),
            const Text("Home Login"),
          ],
        ),
        actions: [buildTopNavigation()],
      ),

      body: Column(
        children: [

          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),

                child: Container(
                  constraints: const BoxConstraints(maxWidth: 400),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade300,
                        blurRadius: 10,
                      )
                    ],
                  ),

                  child: Column(
                    children: [

                      const Text(
                        "Welcome Back",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 20),

                      TextField(
                        controller: user,
                        decoration: const InputDecoration(
                          labelText: "Username",
                        ),
                      ),

                      const SizedBox(height: 15),

                      TextField(
                        controller: pass,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: "Password",
                        ),
                      ),

                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isLoading
                              ? null
                              : () => login(context),
                          child: isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text("Login"),
                        ),
                      ),

                    ],
                  ),
                ),
              ),
            ),
          ),

          buildFooter(),
        ],
      ),
    );
  }
}