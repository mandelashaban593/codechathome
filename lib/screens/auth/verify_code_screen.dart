import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/api_service.dart';
import 'reset_password_screen.dart';

class VerifyCodeScreen extends StatefulWidget {
  final String email;

  const VerifyCodeScreen({Key? key, required this.email}) : super(key: key);

  @override
  State<VerifyCodeScreen> createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends State<VerifyCodeScreen> {

  // 6 separate controllers — one per digit box
  final List<TextEditingController> controllers =
      List.generate(6, (_) => TextEditingController());

  // 6 focus nodes — to auto-jump between boxes
  final List<FocusNode> focusNodes =
      List.generate(6, (_) => FocusNode());

  bool isVerifying = false;
  bool isResending = false;
  String? errorMessage;
  String? successMessage;

  @override
  void dispose() {
    for (var c in controllers) c.dispose();
    for (var f in focusNodes) f.dispose();
    super.dispose();
  }

  // =====================================================
  // Get the full 6-digit code from all boxes
  // =====================================================
  String get fullCode =>
      controllers.map((c) => c.text).join();

  // =====================================================
  // STEP 2 — Verify the code
  // =====================================================
  Future<void> verifyCode() async {
    final code = fullCode;

    if (code.length < 6) {
      setState(() => errorMessage = 'Please enter the complete 6-digit code.');
      return;
    }

    setState(() {
      isVerifying  = true;
      errorMessage = null;
      successMessage = null;
    });

    final result = await ApiService.verifyResetCode(widget.email, code);

    setState(() => isVerifying = false);

    if (result['success'] == true) {
      // Navigate to reset password screen
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResetPasswordScreen(
            email: widget.email,
            code:  code,
          ),
        ),
      );
    } else {
      // Show error on screen
      final errors = result['errors'];
      setState(() {
        errorMessage = errors?['code']?[0] ??
            errors?['email']?[0] ??
            result['message'] ??
            'Invalid code. Please try again.';
      });
    }
  }

  // =====================================================
  // RESEND CODE
  // =====================================================
  Future<void> resendCode() async {
    setState(() {
      isResending    = true;
      errorMessage   = null;
      successMessage = null;
      // Clear all boxes
      for (var c in controllers) c.clear();
      // Focus first box
      focusNodes[0].requestFocus();
    });

    final result = await ApiService.resendResetCode(widget.email);

    setState(() => isResending = false);

    if (result['success'] == true) {
      setState(() {
        successMessage =
            'A new code has been sent to ${widget.email}';
      });
    } else {
      setState(() {
        errorMessage = result['message'] ?? 'Failed to resend code.';
      });
    }
  }

  // =====================================================
  // Single digit input box
  // =====================================================
  Widget buildDigitBox(int index) {
    return SizedBox(
      width: 45,
      height: 55,
      child: TextField(
        controller: controllers[index],
        focusNode: focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          counterText: '',   // hide the character counter
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.blue, width: 2),
          ),
        ),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,  // numbers only
        ],
        onChanged: (value) {
          if (value.isNotEmpty && index < 5) {
            // Auto-jump to next box
            focusNodes[index + 1].requestFocus();
          }
          if (value.isEmpty && index > 0) {
            // Auto-jump back when deleting
            focusNodes[index - 1].requestFocus();
          }
          setState(() {});  // redraw to update button state
        },
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
            Image.asset("assets/images/softtutor.png", height: 35),
            const SizedBox(width: 10),
            const Text("Enter Verification Code",
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

                // ── Icon ──────────────────────────────────
                const Icon(Icons.mark_email_read,
                    size: 60, color: Colors.blue),
                const SizedBox(height: 16),

                // ── Title ─────────────────────────────────
                const Text(
                  "Check Your Email",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),

                // ── Subtitle with email ───────────────────
                Text(
                  "We sent a 6-digit code to\n${widget.email}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 24),

                // ── Success message ───────────────────────
                if (successMessage != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      border: Border.all(color: Colors.green),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle,
                            color: Colors.green, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(successMessage!,
                              style:
                                  const TextStyle(color: Colors.green)),
                        ),
                      ],
                    ),
                  ),

                // ── Error message ─────────────────────────
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
                              style:
                                  const TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  ),

                // ── 6 digit boxes ─────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(6, (i) => buildDigitBox(i)),
                ),
                const SizedBox(height: 28),

                // ── Verify button ─────────────────────────
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isVerifying ? null : verifyCode,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: isVerifying
                        ? const SizedBox(
                            height: 20, width: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : const Text("Verify Code",
                            style: TextStyle(
                                fontSize: 16, color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Resend code button ────────────────────
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: isResending ? null : resendCode,
                    icon: isResending
                        ? const SizedBox(
                            height: 16, width: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2))
                        : const Icon(Icons.refresh),
                    label: Text(
                        isResending ? "Sending..." : "Resend Code"),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Colors.blue),
                      foregroundColor: Colors.blue,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // ── Back to login ─────────────────────────
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Back"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}