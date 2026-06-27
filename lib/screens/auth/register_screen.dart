import 'dart:convert';
import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../services/auth_service.dart';

import '../student/student_dashboard.dart';
import '../mentor/mentor_dashboard.dart';
import '../dashboard/admin_dashboard.dart';

import '../auth/home_login_screen.dart';
import '../infopages/contact_screen.dart';
import '../infopages/privacy_screen.dart';
import '../infopages/termscond_screen.dart';

class RegisterScreen extends StatefulWidget {
  final String? username;

  const RegisterScreen({Key? key, this.username}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final usernameController = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final phone = TextEditingController();

  String role = "student";
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.username != null) {
      usernameController.text = widget.username!;
    }
  }

  @override
  void dispose() {
    usernameController.dispose();
    email.dispose();
    password.dispose();
    phone.dispose();
    super.dispose();
  }

  void showMsg(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  // ================= REGISTER =================
  Future<void> register(BuildContext context) async {
    if (usernameController.text.isEmpty ||
        password.text.isEmpty ||
        phone.text.isEmpty) {
      return showMsg("All required fields must be filled");
    }

    setState(() => isLoading = true);

    try {
      var res = await ApiService.post("register/", {
        "username": usernameController.text.trim(),
        "email": email.text.trim(),
        "password": password.text.trim(),
        "phone": phone.text.trim(),
        "role": role
      });

      var data = jsonDecode(res.body);

      if (data["token"] == null) {
        showMsg(data["error"] ?? "Registration failed");
        setState(() => isLoading = false);
        return;
      }

      await AuthService.saveUser(
        data["token"],
        data["role"],
        data["username"],
      );

      String username = data["username"];

      // ================= FIXED NAVIGATION =================

      if (data["role"] == "admin") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (_) => AdminDashboard(username: username)),
        );

      } else if (data["role"] == "mentor") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (_) => MentorDashboard(username: username)),
        );

      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (_) => StudentDashboard(username: username)),
        );
      }

    } catch (e) {
      showMsg("Network error");
    }

    setState(() => isLoading = false);
  }

  // ================= TOP NAV =================
  Widget buildTopNavigation() {
    return Row(
      children: [
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HomeLoginScreen()),
            );
          },
          child: const Text("Login",
              style: TextStyle(color: Colors.white)),
        ),
        TextButton(
          onPressed: () {},
          child: const Text("Register",
              style: TextStyle(color: Colors.white)),
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
            alignment: WrapAlignment.center,
            spacing: 20,
            children: [
              TextButton(
                child: const Text("Contact",
                    style: TextStyle(color: Colors.white)),
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => ContactScreen()));
                },
              ),
              TextButton(
                child: const Text("Privacy",
                    style: TextStyle(color: Colors.white)),
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => PrivacyScreen()));
                },
              ),
              TextButton(
                child: const Text("Terms",
                    style: TextStyle(color: Colors.white)),
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => TermsCondScreen()));
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            "CodeChathome - Learn from Software Development Trainers, mentor online anytime, anywhere.",
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
            const Text("Register",
                style: TextStyle(color: Colors.white)),
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
                  constraints: const BoxConstraints(maxWidth: 450),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.grey.shade300,
                          blurRadius: 10)
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text(
                        "Create Account",
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold),
                      ),

                      const SizedBox(height: 20),

                      TextField(
                        controller: usernameController,
                        readOnly: widget.username != null,
                        decoration: const InputDecoration(
                          labelText: "Username",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                      ),

                      const SizedBox(height: 15),

                      TextField(
                        controller: email,
                        decoration: const InputDecoration(
                          labelText: "Email",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.email),
                        ),
                      ),

                      const SizedBox(height: 15),

                      TextField(
                        controller: password,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: "Password",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.lock),
                        ),
                      ),

                      const SizedBox(height: 15),

                      TextField(
                        controller: phone,
                        decoration: const InputDecoration(
                          labelText: "Phone",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.phone),
                        ),
                      ),

                      const SizedBox(height: 15),

                      DropdownButtonFormField(
                        value: role,
                        decoration: const InputDecoration(
                          labelText: "Role",
                          border: OutlineInputBorder(),
                        ),
                        items: ["student", "mentor"]
                            .map((e) => DropdownMenuItem(
                                  value: e,
                                  child: Text(e),
                                ))
                            .toList(),
                        onChanged: (val) =>
                            setState(() => role = val.toString()),
                      ),

                      const SizedBox(height: 25),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isLoading
                              ? null
                              : () => register(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(
                                vertical: 15),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text("Register"),
                        ),
                      ),

                      const SizedBox(height: 10),

                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const HomeLoginScreen()),
                          );
                        },
                        child: const Text("Already have an account? Login"),
                      )
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