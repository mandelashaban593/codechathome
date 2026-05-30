import 'package:flutter/material.dart';

// ================= CORE SCREENS =================
import 'screens/need/create_need.dart';

// ================= AUTH =================
import 'screens/auth/home_login_screen.dart';
import 'screens/auth/register_screen.dart';

// ================= DASHBOARDS =================
import 'screens/dashboard/student_dashboard.dart';
import 'screens/dashboard/mentor_dashboard.dart';
import 'screens/dashboard/admin_dashboard.dart';

// ================= INFO PAGES =================
import 'screens/infopages/contact_screen.dart';
import 'screens/infopages/privacy_screen.dart';
import 'screens/infopages/termscond_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // ================= DEFAULT SCREEN =================
      home: CreateNeed(),

      // ================= STATIC ROUTES =================
      routes: {
        "/home-login": (_) => const HomeLoginScreen(),
        "/login": (_) => const HomeLoginScreen(),
        "/register": (_) => RegisterScreen(),

        // 🔥 NEW INFO ROUTES (FOOTER NAVIGATION)
        "/contact": (_) => ContactScreen(),
        "/privacy": (_) => PrivacyScreen(),
        "/terms": (_) => TermsCondScreen(),
      },

      // ================= DYNAMIC ROUTES =================
      onGenerateRoute: (settings) {
        switch (settings.name) {

          // ================= student =================
          case "/student":
            final args = settings.arguments as Map?;
            return MaterialPageRoute(
              builder: (_) => StudentDashboard(
                username: args?["username"] ?? "",
              ),
            );

          // ================= mentor =================
          case "/mentor":
            final args = settings.arguments as Map?;
            return MaterialPageRoute(
              builder: (_) => MentorDashboard(
                username: args?["username"] ?? "",
              ),
            );

          // ================= ADMIN =================
          case "/admin":
            final args = settings.arguments as Map?;
            return MaterialPageRoute(
              builder: (_) => AdminDashboard(
                username: args?["username"] ?? "",
              ),
            );

          // ================= FALLBACK =================
          default:
            return MaterialPageRoute(
              builder: (_) => Scaffold(
                body: Center(
                  child: Text(
                    "Route not found: ${settings.name}",
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            );
        }
      },
    );
  }
}