// lib/screens/auth/reset_password_screen.dart

import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';   // ← ADD THIS IMPORT
import 'login_screen.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  final String code;

  const ResetPasswordScreen({
    Key? key,
    required this.email,
    required this.code,
  }) : super(key: key);

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final newPasswordController     = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool isLoading      = false;
  bool obscureNew     = true;
  bool obscureConfirm = true;

  String? errorMessage;
  String? newPasswordError;
  String? confirmPasswordError;

  @override
  void dispose() {
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  // =====================================================
  // STEP 3 — Submit new password
  // =====================================================
  Future<void> submitNewPassword() async {
    final newPassword     = newPasswordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    setState(() {
      newPasswordError     = null;
      confirmPasswordError = null;
      errorMessage         = null;
    });

    bool hasError = false;

    if (newPassword.isEmpty) {
      setState(() => newPasswordError = 'New password is required.');
      hasError = true;
    } else if (newPassword.length < 8) {
      setState(() => newPasswordError =
          'Password must be at least 8 characters.');
      hasError = true;
    }

    if (confirmPassword.isEmpty) {
      setState(() => confirmPasswordError = 'Please confirm your password.');
      hasError = true;
    } else if (newPassword != confirmPassword) {
      setState(() => confirmPasswordError = 'Passwords do not match.');
      hasError = true;
    }

    if (hasError) return;

    setState(() => isLoading = true);

    final result = await ApiService.confirmPasswordReset(
      widget.email,
      widget.code,
      newPassword,
      confirmPassword,
    );

    setState(() => isLoading = false);

    if (result['success'] == true) {

      // ✅ FIX — Clear the old stored token from SharedPreferences
      // This prevents the 401 "Invalid token" error on the login screen
      // The user must log in fresh with their new password
      await AuthService.logout();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password reset successful! Please log in.'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );

      // Clear all routes and go to login
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );

    } else {
      final errors = result['errors'];
      if (errors != null) {
        setState(() {
          newPasswordError     = errors['new_password']?[0];
          confirmPasswordError = errors['confirm_password']?[0];
          errorMessage         = errors['code']?[0] ?? errors['email']?[0];
        });
      } else {
        setState(() {
          errorMessage =
              result['message'] ?? 'Something went wrong. Please try again.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Row(
          children: [
            Image.asset("assets/images/softtutor.png", height: 35),
            const SizedBox(width: 10),
            const Text("Set New Password",
                style: TextStyle(color: Colors.white)),
          ],
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: Colors.grey.shade300, blurRadius: 10)
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [

                const Icon(Icons.lock_open, size: 60, color: Colors.blue),
                const SizedBox(height: 16),

                const Text(
                  "Set New Password",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),

                const Text(
                  "Enter and confirm your new password below.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 24),

                // ── General error ────────────────────────
                if (errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      border: Border.all(color: Colors.red),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline,
                            color: Colors.red, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(errorMessage!,
                              style: const TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  ),

                // ── New password ─────────────────────────
                TextField(
                  controller: newPasswordController,
                  obscureText: obscureNew,
                  decoration: InputDecoration(
                    labelText: "New Password",
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock),
                    errorText: newPasswordError,
                    suffixIcon: IconButton(
                      icon: Icon(obscureNew
                          ? Icons.visibility
                          : Icons.visibility_off),
                      onPressed: () =>
                          setState(() => obscureNew = !obscureNew),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Confirm password ─────────────────────
                TextField(
                  controller: confirmPasswordController,
                  obscureText: obscureConfirm,
                  decoration: InputDecoration(
                    labelText: "Confirm Password",
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock_outline),
                    errorText: confirmPasswordError,
                    suffixIcon: IconButton(
                      icon: Icon(obscureConfirm
                          ? Icons.visibility
                          : Icons.visibility_off),
                      onPressed: () => setState(
                          () => obscureConfirm = !obscureConfirm),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // ── Submit button ─────────────────────────
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : submitNewPassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 20, width: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : const Text("Confirm",
                            style: TextStyle(
                                fontSize: 16, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}