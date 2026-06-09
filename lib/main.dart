import 'package:flutter/material.dart';

// ================= CORE SCREENS =================
import 'screens/need/create_need.dart';
import 'screens/need/need_list.dart';

// ================= AUTH =================
import 'screens/auth/home_login_screen.dart';
import 'screens/auth/register_screen.dart';

// ================= SERVICES =================
import 'services/auth_service.dart';

// ================= DASHBOARDS =================
import 'screens/student/student_dashboard.dart';
import 'screens/mentor/mentor_dashboard.dart';
import 'screens/dashboard/admin_dashboard.dart';

// ================= INFO PAGES =================
import 'screens/infopages/contact_screen.dart';
import 'screens/infopages/privacy_screen.dart';
import 'screens/infopages/termscond_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // =====================================================
      // FIRST PAGE
      // =====================================================
      home: const CreateNeed(),

      // =====================================================
      // STATIC ROUTES
      // =====================================================
      routes: {
        "/home-login": (_) => const HomeLoginScreen(),
        "/login": (_) => const HomeLoginScreen(),
        "/register": (_) => RegisterScreen(),

        "/contact": (_) => ContactScreen(),
        "/privacy": (_) => PrivacyScreen(),
        "/terms": (_) => TermsCondScreen(),

        "/needs": (_) => const NeedList(),
      },

      // =====================================================
      // SPECIAL LOGOUT ROUTE
      // =====================================================
      onGenerateRoute: (settings) {
        switch (settings.name) {

          // ================= LOGOUT ROUTE =================
          case "/logout":
            return MaterialPageRoute(
              builder: (_) => const LogoutScreen(),
            );

          case "/student":
            final args = settings.arguments as Map?;
            return MaterialPageRoute(
              builder: (_) => StudentDashboard(
                username: args?["username"] ?? "",
              ),
            );

          case "/mentor":
            final args = settings.arguments as Map?;
            return MaterialPageRoute(
              builder: (_) => MentorDashboard(
                username: args?["username"] ?? "",
              ),
            );

          case "/admin":
            final args = settings.arguments as Map?;
            return MaterialPageRoute(
              builder: (_) => AdminDashboard(
                username: args?["username"] ?? "",
              ),
            );

          default:
            return MaterialPageRoute(
              builder: (_) => Scaffold(
                body: Center(
                  child: Text("Route not found: ${settings.name}"),
                ),
              ),
            );
        }
      },
    );
  }
}

//
// =====================================================
// 🔥 LOGOUT SCREEN (HANDLES CLEAR + REDIRECT)
// =====================================================
//
class LogoutScreen extends StatefulWidget {
  const LogoutScreen({super.key});

  @override
  State<LogoutScreen> createState() => _LogoutScreenState();
}

class _LogoutScreenState extends State<LogoutScreen> {

  @override
  void initState() {
    super.initState();
    performLogout();
  }

  Future<void> performLogout() async {
    await AuthService.logout();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const HomeLoginScreen(),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}