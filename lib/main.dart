import 'package:flutter/material.dart';

// ================= CORE SCREENS =================
import 'screens/need/create_need.dart';
import 'screens/need/need_list.dart';

// ================= AUTH =================
import 'screens/auth/home_login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/auth/verify_code_screen.dart';
import 'screens/auth/reset_password_screen.dart';

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
      // No arguments needed for these screens
      // =====================================================
      routes: {
        "/home-login":      (_) => const HomeLoginScreen(),
        "/login":           (_) => const HomeLoginScreen(),
        "/register":        (_) => RegisterScreen(),
        "/forgot-password": (_) => const ForgotPasswordScreen(),

        "/contact": (_) => ContactScreen(),
        "/privacy":  (_) => PrivacyScreen(),
        "/terms":    (_) => TermsCondScreen(),

        "/needs": (_) => const NeedList(),
      },

      // =====================================================
      // DYNAMIC ROUTES
      // These need arguments passed via settings.arguments
      // =====================================================
      onGenerateRoute: (settings) {
        switch (settings.name) {

          // ================= LOGOUT =================
          // Usage: Navigator.pushNamed(context, "/logout")
          case "/logout":
            return MaterialPageRoute(
              builder: (_) => const LogoutScreen(),
            );

          // ================= STUDENT DASHBOARD =================
          // Usage: Navigator.pushNamed(context, "/student",
          //          arguments: { "username": "john" })
          case "/student":
            final args = settings.arguments as Map?;
            return MaterialPageRoute(
              builder: (_) => StudentDashboard(
                username: args?["username"] ?? "",
              ),
            );

          // ================= MENTOR DASHBOARD =================
          // Usage: Navigator.pushNamed(context, "/mentor",
          //          arguments: { "username": "john" })
          case "/mentor":
            final args = settings.arguments as Map?;
            return MaterialPageRoute(
              builder: (_) => MentorDashboard(
                username: args?["username"] ?? "",
              ),
            );

          // ================= ADMIN DASHBOARD =================
          // Usage: Navigator.pushNamed(context, "/admin",
          //          arguments: { "username": "john" })
          case "/admin":
            final args = settings.arguments as Map?;
            return MaterialPageRoute(
              builder: (_) => AdminDashboard(
                username: args?["username"] ?? "",
              ),
            );

          // ================= VERIFY CODE =================
          // Called after ForgotPasswordScreen sends code to email
          // Usage: Navigator.pushNamed(context, "/verify-code",
          //          arguments: { "email": "user@example.com" })
          case "/verify-code":
            final args = settings.arguments as Map?;
            return MaterialPageRoute(
              builder: (_) => VerifyCodeScreen(
                email: args?["email"] ?? "",
              ),
            );

          // ================= RESET PASSWORD =================
          // Called after VerifyCodeScreen verifies the 6-digit code
          // Usage: Navigator.pushNamed(context, "/reset-password",
          //          arguments: { "email": "user@example.com",
          //                       "code": "482910" })
          case "/reset-password":
            final args = settings.arguments as Map?;
            return MaterialPageRoute(
              builder: (_) => ResetPasswordScreen(
                email: args?["email"] ?? "",
                code:  args?["code"]  ?? "",
              ),
            );

          // ================= 404 NOT FOUND =================
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

// =====================================================
// LOGOUT SCREEN — clears session and redirects to login
// =====================================================
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