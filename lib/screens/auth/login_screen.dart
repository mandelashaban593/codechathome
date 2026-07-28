import 'dart:convert';
import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../services/auth_service.dart';

import '../student/student_dashboard.dart';
import '../mentor/mentor_dashboard.dart';
import '../admin/admin_dashboard.dart';

import '../auth/register_screen.dart';
import '../infopages/contact_screen.dart';
import '../infopages/privacy_screen.dart';
import '../infopages/termscond_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  final String? username;

  const LoginScreen({Key? key, this.username}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final user = TextEditingController();
  final pass = TextEditingController();

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.username != null) {
      user.text = widget.username!;
    }
  }

  @override
  void dispose() {
    user.dispose();
    pass.dispose();
    super.dispose();
  }

  void showMsg(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  // ================= LOGIN =================
  Future<void> login(BuildContext context) async {
    if (user.text.trim().isEmpty || pass.text.trim().isEmpty) {
      return showMsg("Username and password required");
    }

    setState(() => isLoading = true);

    try {
      // ✅ FIX: auth: false — login is a public endpoint, no token needed
      var res = await ApiService.post(
        "login/",
        {
          "username": user.text.trim(),
          "password": pass.text.trim(),
        },
        auth: false,
      );

      var data = jsonDecode(res.body);

      if (res.statusCode != 200 || data["token"] == null) {
        showMsg(data["error"] ?? "Login failed");
        setState(() => isLoading = false);
        return;
      }

      await AuthService.saveUser(
        data["token"],
        data["role"],
        data["username"],
      );

      String username = data["username"];

      // ================= NAVIGATION BY ROLE =================
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
          onPressed: () {},
          child: const Text("Login",
              style: TextStyle(color: Colors.white)),
        ),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const RegisterScreen()),
            );
          },
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
            "chatcodehome - Learn from Software Development Trainers online anytime, anywhere.",
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
            const Text("Login", style: TextStyle(color: Colors.white)),
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
                          blurRadius: 10)
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text(
                        "Welcome Back",
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),

                      const SizedBox(height: 20),

                      TextField(
                        controller: user,
                        readOnly: widget.username != null,
                        decoration: const InputDecoration(
                          labelText: "Username",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                      ),

                      const SizedBox(height: 15),

                      TextField(
                        controller: pass,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: "Password",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.lock),
                        ),
                      ),

                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed:
                              isLoading ? null : () => login(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding:
                                const EdgeInsets.symmetric(vertical: 15),
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
                              : const Text("Login"),
                        ),
                      ),

                      const SizedBox(height: 10),

                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const RegisterScreen()),
                          );
                        },
                        child: const Text("Create account"),
                      ),

                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    const ForgotPasswordScreen()),
                          );
                        },
                        child: const Text(
                          "Forgot Password?",
                          style: TextStyle(color: Colors.blue),
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
