// ============================================================
//  create_need.dart  –  Full two-step signup
//
//  Step 2 is role-aware:
//    • mentor  → only username field shown; no mentor picker, no learning need
//    • student → username + mentor picker (2 defaults + "Search others...")
//                + learning need textarea
//
//  Mentor picker behaviour:
//    • Shows mentor_shaban and mentor_hans as quick-pick chips
//    • "Search others…" opens a modal search that calls GET /mentors/search/
//    • Selected mentor shown as a dismissible chip below the options
//
// pubspec.yaml dependencies required:
//   shared_preferences: ^2.2.3
// ============================================================

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/api_service.dart';
import '../auth/home_login_screen.dart';
import '../mentor/mentor_dashboard.dart';
import '../student/student_dashboard.dart';
import '../infopages/contact_screen.dart';
import '../infopages/privacy_screen.dart';
import '../infopages/termscond_screen.dart';

// ── Local storage keys ────────────────────────────────────────────────────────
const _kDraftFullName = 'draft_full_name';
const _kDraftEmail    = 'draft_email';
const _kDraftPhone    = 'draft_phone';
const _kDraftRole     = 'draft_role';
const _kDraftStep     = 'draft_step';

// ── Default mentors shown as quick-pick chips ─────────────────────────────────
const List<String> _kDefaultMentors = ['mentor_shaban', 'mentor_hans'];

// ─────────────────────────────────────────────────────────────────────────────
//  Mentor search modal
// ─────────────────────────────────────────────────────────────────────────────
class _MentorSearchModal extends StatefulWidget {
  final String? initialQuery;
  const _MentorSearchModal({this.initialQuery});

  @override
  State<_MentorSearchModal> createState() => _MentorSearchModalState();
}

class _MentorSearchModalState extends State<_MentorSearchModal> {
  final _searchCtrl = TextEditingController();
  Timer?  _debounce;
  bool    _loading  = false;
  String? _error;
  List<Map<String, dynamic>> _results = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      _searchCtrl.text = widget.initialQuery!;
      _runSearch(widget.initialQuery!);
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    if (value.trim().isEmpty) {
      setState(() { _results = []; _error = null; _loading = false; });
      return;
    }
    setState(() { _loading = true; _error = null; });
    _debounce = Timer(const Duration(milliseconds: 500), () => _runSearch(value));
  }

  Future<void> _runSearch(String query) async {
    try {
      final res  = await ApiService.searchMentors(query.trim());
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      if (!mounted) return;
      if (res.statusCode == 200) {
        final list = body['mentors'] as List<dynamic>? ?? [];
        setState(() {
          _results = list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
          _loading = false;
          _error   = _results.isEmpty ? 'No mentors found for "${_searchCtrl.text}".' : null;
        });
      } else {
        setState(() { _loading = false; _error = body['error']?.toString() ?? 'Search failed.'; });
      }
    } catch (_) {
      if (mounted) setState(() { _loading = false; _error = 'Network error. Please try again.'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollCtrl) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // ── Handle bar ─────────────────────────────────────────────────
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 6),
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Search Mentors',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Type a name, username, or skill to find a mentor.',
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                    const SizedBox(height: 12),
                    // ── Search field ──────────────────────────────────────────
                    TextField(
                      controller: _searchCtrl,
                      autofocus: true,
                      onChanged: _onChanged,
                      decoration: InputDecoration(
                        hintText: 'e.g. python, shaban, javascript…',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchCtrl.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchCtrl.clear();
                                  _onChanged('');
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 14),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Results ────────────────────────────────────────────────────
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _error != null
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Text(
                                _error!,
                                style: const TextStyle(color: Colors.grey),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )
                        : _results.isEmpty
                            ? const Center(
                                child: Text(
                                  'Type above to search for mentors.',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              )
                            : ListView.separated(
                                controller: scrollCtrl,
                                itemCount: _results.length,
                                separatorBuilder: (_, __) =>
                                    const Divider(height: 1),
                                itemBuilder: (_, i) {
                                  final m = _results[i];
                                  final username  = m['username']  as String? ?? '';
                                  final fullName  = m['full_name'] as String? ?? username;
                                  final skills    = m['skills']    as String? ?? '';
                                  return ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: Colors.blue.shade100,
                                      child: Text(
                                        fullName.isNotEmpty
                                            ? fullName[0].toUpperCase()
                                            : '?',
                                        style: const TextStyle(
                                            color: Colors.blue,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    title: Text(
                                      fullName,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('@$username',
                                            style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.blue)),
                                        if (skills.isNotEmpty)
                                          Text(skills,
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey)),
                                      ],
                                    ),
                                    trailing: ElevatedButton(
                                      onPressed: () =>
                                          Navigator.pop(context, username),
                                      style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 14, vertical: 8),
                                          textStyle:
                                              const TextStyle(fontSize: 13)),
                                      child: const Text('Select'),
                                    ),
                                  );
                                },
                              ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Main widget
// ─────────────────────────────────────────────────────────────────────────────
class CreateNeed extends StatefulWidget {
  const CreateNeed({Key? key}) : super(key: key);

  @override
  State<CreateNeed> createState() => _CreateNeedState();
}

class _CreateNeedState extends State<CreateNeed> {

  // ── Step 1 controllers ─────────────────────────────────────────────────────
  final _fullName = TextEditingController();
  final _phone    = TextEditingController();
  final _email    = TextEditingController();
  final _password = TextEditingController();

  // ── Step 2 controllers ─────────────────────────────────────────────────────
  final _username     = TextEditingController();
  final _learningNeed = TextEditingController();

  // ── Form keys ──────────────────────────────────────────────────────────────
  final _form1Key = GlobalKey<FormState>();
  final _form2Key = GlobalKey<FormState>();

  // ── UI / flow state ────────────────────────────────────────────────────────
  int     _step            = 1;
  bool    _isLoading       = false;
  bool    _obscurePassword = true;
  bool    _initialising    = true;

  // ── Role ───────────────────────────────────────────────────────────────────
  String? _selectedRole;
  bool get _isMentor => _selectedRole == 'mentor';

  // ── Mentor selection ───────────────────────────────────────────────────────
  // null            = nothing selected yet
  // a username str  = selected (could be default or from search)
  String? _selectedMentor;

  // ── Live uniqueness-check state ────────────────────────────────────────────
  bool    _phoneChecking    = false;
  String? _phoneError;
  Timer?  _phoneDebounce;

  bool    _usernameChecking = false;
  String? _usernameError;
  Timer?  _usernameDebounce;

  // ── Resume-banner state ────────────────────────────────────────────────────
  bool    _showResumeBanner = false;
  String  _resumeEmail      = '';

  final List<String> _roles = ['student', 'mentor'];

  // ════════════════════════════════════════════════════════════════════════════
  // Lifecycle
  // ════════════════════════════════════════════════════════════════════════════

  @override
  void initState() {
    super.initState();
    _checkForSavedDraft();
  }

  @override
  void dispose() {
    _fullName.dispose();
    _phone.dispose();
    _email.dispose();
    _password.dispose();
    _username.dispose();
    _learningNeed.dispose();
    _phoneDebounce?.cancel();
    _usernameDebounce?.cancel();
    super.dispose();
  }

  // ════════════════════════════════════════════════════════════════════════════
  // Draft persistence
  // ════════════════════════════════════════════════════════════════════════════

  Future<void> _checkForSavedDraft() async {
    final prefs      = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString(_kDraftEmail) ?? '';
    if (savedEmail.isNotEmpty) {
      setState(() {
        _showResumeBanner = true;
        _resumeEmail      = savedEmail;
        _initialising     = false;
      });
    } else {
      setState(() => _initialising = false);
    }
  }

  Future<void> _saveLocalDraft() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kDraftFullName, _fullName.text.trim());
    await prefs.setString(_kDraftEmail,    _email.text.trim().toLowerCase());
    await prefs.setString(_kDraftPhone,    _phone.text.trim());
    await prefs.setString(_kDraftRole,     _selectedRole ?? '');
    await prefs.setString(_kDraftStep,     '2');
  }

  Future<void> _clearLocalDraft() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kDraftFullName);
    await prefs.remove(_kDraftEmail);
    await prefs.remove(_kDraftPhone);
    await prefs.remove(_kDraftRole);
    await prefs.remove(_kDraftStep);
  }

  // ════════════════════════════════════════════════════════════════════════════
  // Resume flow
  // ════════════════════════════════════════════════════════════════════════════

  Future<void> _resumeDraft() async {
    setState(() { _isLoading = true; _showResumeBanner = false; });
    try {
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString(_kDraftEmail) ?? '';
      final res   = await ApiService.resumeSignup(email);
      final data  = jsonDecode(res.body) as Map<String, dynamic>;

      if (res.statusCode == 200) {
        _fullName.text = data['full_name']  ?? prefs.getString(_kDraftFullName) ?? '';
        _email.text    = data['email']       ?? email;
        _phone.text    = data['phone_raw']   ?? prefs.getString(_kDraftPhone)   ?? '';
        setState(() {
          _selectedRole = data['role'] ?? prefs.getString(_kDraftRole);
          _step         = 2;
        });
        _showMsg('Welcome back! Pick up where you left off.');
      } else {
        _fullName.text = prefs.getString(_kDraftFullName) ?? '';
        _email.text    = prefs.getString(_kDraftEmail)    ?? '';
        _phone.text    = prefs.getString(_kDraftPhone)    ?? '';
        setState(() {
          _selectedRole = prefs.getString(_kDraftRole);
          _step         = 1;
        });
        _showMsg('Could not load server draft — fields pre-filled locally.');
      }
    } catch (_) {
      final prefs = await SharedPreferences.getInstance();
      _fullName.text = prefs.getString(_kDraftFullName) ?? '';
      _email.text    = prefs.getString(_kDraftEmail)    ?? '';
      _phone.text    = prefs.getString(_kDraftPhone)    ?? '';
      setState(() {
        _selectedRole = prefs.getString(_kDraftRole);
        _step         = 1;
      });
      _showMsg('Network error while resuming. Fields pre-filled locally.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _discardDraft() async {
    await _clearLocalDraft();
    setState(() { _showResumeBanner = false; _step = 1; });
  }

  // ════════════════════════════════════════════════════════════════════════════
  // Helpers
  // ════════════════════════════════════════════════════════════════════════════

  void _showMsg(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  String _normalisePhone(String raw) {
    String p = raw.trim();
    if (p.startsWith('+256')) p = p.substring(4);
    if (p.startsWith('256'))  p = p.substring(3);
    if (p.startsWith('0'))    p = p.substring(1);
    return '256$p';
  }

  // ════════════════════════════════════════════════════════════════════════════
  // Live uniqueness checks
  // ════════════════════════════════════════════════════════════════════════════

  void _onPhoneChanged(String value) {
    _phoneDebounce?.cancel();
    if (value.trim().isEmpty) {
      setState(() { _phoneError = null; _phoneChecking = false; });
      return;
    }
    setState(() { _phoneChecking = true; _phoneError = null; });
    _phoneDebounce = Timer(const Duration(milliseconds: 600), () async {
      try {
        final res  = await ApiService.checkPhone(_normalisePhone(value));
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        if (!mounted) return;
        setState(() {
          _phoneChecking = false;
          _phoneError    = (data['exists'] == true)
              ? 'This phone number is already registered.'
              : null;
        });
      } catch (_) {
        if (mounted) setState(() => _phoneChecking = false);
      }
    });
  }

  void _onUsernameChanged(String value) {
    _usernameDebounce?.cancel();
    if (value.trim().isEmpty) {
      setState(() { _usernameError = null; _usernameChecking = false; });
      return;
    }
    setState(() { _usernameChecking = true; _usernameError = null; });
    _usernameDebounce = Timer(const Duration(milliseconds: 600), () async {
      try {
        final res  = await ApiService.checkUsername(value.trim());
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        if (!mounted) return;
        setState(() {
          _usernameChecking = false;
          _usernameError    = (data['exists'] == true)
              ? 'Username already taken. Choose another.'
              : null;
        });
      } catch (_) {
        if (mounted) setState(() => _usernameChecking = false);
      }
    });
  }

  // ════════════════════════════════════════════════════════════════════════════
  // Mentor search modal
  // ════════════════════════════════════════════════════════════════════════════

  Future<void> _openMentorSearch() async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _MentorSearchModal(),
    );
    if (picked != null && picked.isNotEmpty) {
      setState(() => _selectedMentor = picked);
    }
  }

  // ════════════════════════════════════════════════════════════════════════════
  // Step 1 → Step 2
  // ════════════════════════════════════════════════════════════════════════════

  Future<void> _goToStep2() async {
    if (!_form1Key.currentState!.validate()) return;
    if (_phoneError != null) { _showMsg(_phoneError!); return; }
    if (_phoneChecking) { _showMsg('Still verifying phone — please wait.'); return; }

    setState(() => _isLoading = true);
    try {
      final res = await ApiService.signupDraft(
        fullName: _fullName.text.trim(),
        email:    _email.text.trim(),
        phone:    _normalisePhone(_phone.text),
        password: _password.text,
        role:     _selectedRole ?? '',
      );
      final data = jsonDecode(res.body) as Map<String, dynamic>;

      if (res.statusCode == 200 || res.statusCode == 209) {
        await _saveLocalDraft();
        setState(() => _step = 2);
      } else {
        final errors = data['errors'] as Map<String, dynamic>?;
        _showMsg(errors != null
            ? errors.values.first.toString()
            : data['error']?.toString() ?? 'Could not save draft.');
      }
    } catch (_) {
      await _saveLocalDraft();
      setState(() => _step = 2);
      _showMsg('Offline — data saved locally. Submit when back online.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ════════════════════════════════════════════════════════════════════════════
  // Final submit
  // ════════════════════════════════════════════════════════════════════════════

  Future<void> _submit() async {
    if (!_form2Key.currentState!.validate()) return;
    if (_usernameError != null) { _showMsg(_usernameError!); return; }
    if (_usernameChecking) { _showMsg('Still verifying username — please wait.'); return; }

    // Students must pick a mentor
    if (!_isMentor && _selectedMentor == null) {
      _showMsg('Please select a mentor.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final res = await ApiService.completeSignup(
        fullName:     _fullName.text.trim(),
        email:        _email.text.trim(),
        phone:        _normalisePhone(_phone.text),
        password:     _password.text,
        role:         _selectedRole ?? '',
        username:     _username.text.trim(),
        // Sent as empty string for mentors — backend ignores it when role=mentor
        mentor:       _isMentor ? '' : (_selectedMentor ?? ''),
        learningNeed: _isMentor ? '' : _learningNeed.text.trim(),
      );

      Map<String, dynamic> data = {};
      try { data = jsonDecode(res.body); } catch (_) {}

      if (res.statusCode == 201 || res.statusCode == 200) {
        await _clearLocalDraft();
        final role = data['role'] ?? _selectedRole;
        // Prefer the username the server returns/confirms; fall back to
        // what the user typed in the form.
        final resolvedUsername =
            (data['username'] as String?) ?? _username.text.trim();
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => role == 'mentor'
                ? MentorDashboard(username: resolvedUsername)
                : StudentDashboard(username: resolvedUsername),
          ),
        );
      } else {
        final errors = data['errors'] as Map<String, dynamic>?;
        _showMsg(errors != null
            ? errors.values.first.toString()
            : data['error']?.toString() ?? 'Something went wrong. Please try again.');
      }
    } catch (_) {
      _showMsg('Network error. Your data is saved — please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ════════════════════════════════════════════════════════════════════════════
  // Widget helpers
  // ════════════════════════════════════════════════════════════════════════════

  Widget? _uniqueSuffixIcon({
    required bool checking,
    required String? error,
    required String value,
  }) {
    if (value.isEmpty) return null;
    if (checking) {
      return const Padding(
        padding: EdgeInsets.all(12),
        child: SizedBox(
            width: 18, height: 18,
            child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }
    return error != null
        ? const Icon(Icons.cancel, color: Colors.red)
        : const Icon(Icons.check_circle, color: Colors.green);
  }

  // ── Mentor picker widget (students only) ────────────────────────────────────
  //
  //  Layout:
  //  ┌──────────────────────────────────────────────────┐
  //  │  Select Mentor                                   │
  //  │  [mentor_shaban]  [mentor_hans]  [Search others…]│
  //  │  ─────────────────────────────────────────────── │
  //  │  ✓ mentor_shaban    ×                            │  ← only when selected
  //  └──────────────────────────────────────────────────┘
  Widget _buildMentorPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Row(
          children: [
            const Icon(Icons.school, size: 20, color: Colors.grey),
            const SizedBox(width: 8),
            Text(
              'Select Mentor',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Quick-pick chips + Search button
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            // Default mentor chips
            ..._kDefaultMentors.map((name) {
              final selected = _selectedMentor == name;
              return ChoiceChip(
                label: Text(name),
                selected: selected,
                selectedColor: Colors.blue.shade100,
                onSelected: (_) => setState(() => _selectedMentor = name),
                avatar: selected
                    ? const Icon(Icons.check_circle,
                        size: 16, color: Colors.blue)
                    : null,
              );
            }),

            // "Search others…" chip
            ActionChip(
              avatar: const Icon(Icons.search, size: 16),
              label: const Text('Search others…'),
              backgroundColor: Colors.grey.shade100,
              onPressed: _openMentorSearch,
            ),
          ],
        ),

        // Selected mentor confirmation chip (shown when a non-default is picked
        // from search, but also for defaults to give consistent feedback)
        if (_selectedMentor != null)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                border: Border.all(color: Colors.green.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle,
                      color: Colors.green, size: 16),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      'Mentor: $_selectedMentor',
                      style: TextStyle(
                          color: Colors.green.shade800,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () => setState(() => _selectedMentor = null),
                    child: Icon(Icons.close,
                        size: 16, color: Colors.green.shade700),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // Resume banner
  // ════════════════════════════════════════════════════════════════════════════

  Widget _buildResumeBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        border: Border.all(color: Colors.amber.shade700),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.amber.shade800, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'You have an unfinished signup',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.amber.shade900),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(_resumeEmail,
              style: TextStyle(color: Colors.amber.shade800, fontSize: 13)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.play_arrow, size: 18),
                  label: const Text('Continue'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber.shade700),
                  onPressed: _isLoading ? null : _resumeDraft,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text('Start over'),
                  style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red.shade700,
                      side: BorderSide(color: Colors.red.shade300)),
                  onPressed: _isLoading ? null : _discardDraft,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // Nav / Footer
  // ════════════════════════════════════════════════════════════════════════════

  Widget _buildTopNavigation() => TextButton(
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const HomeLoginScreen())),
        child: const Text('Login', style: TextStyle(color: Colors.white)),
      );

  Widget _buildFooter() {
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
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => ContactScreen())),
                child: const Text('Contact',
                    style: TextStyle(color: Colors.white)),
              ),
              TextButton(
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => PrivacyScreen())),
                child: const Text('Privacy',
                    style: TextStyle(color: Colors.white)),
              ),
              TextButton(
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => TermsCondScreen())),
                child:
                    const Text('Terms', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Codechathome – Learn from Software Development Trainers online anytime, anywhere in Uganda.',
            style: TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // Step 1 form
  // ════════════════════════════════════════════════════════════════════════════

  Widget _buildStep1() {
    return Form(
      key: _form1Key,
      child: Container(
        key: const ValueKey('step1'),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Step 1 of 2 – Your details',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.blue)),
            const SizedBox(height: 16),

            // Full Name
            TextFormField(
              controller: _fullName,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person)),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Full name is required.' : null,
            ),
            const SizedBox(height: 14),

            // Phone
            TextFormField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              onChanged: _onPhoneChanged,
              decoration: InputDecoration(
                labelText: 'Phone',
                hintText: 'e.g. 0701234567',
                prefixIcon: const Icon(Icons.phone),
                suffixIcon: _uniqueSuffixIcon(
                  checking: _phoneChecking,
                  error:    _phoneError,
                  value:    _phone.text,
                ),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Phone is required.';
                if (_phoneError != null) return _phoneError;
                return null;
              },
            ),
            const SizedBox(height: 14),

            // Email
            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email)),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Email is required.';
                if (!RegExp(r'^[\w.\-]+@[\w.\-]+\.\w+$').hasMatch(v.trim())) {
                  return 'Enter a valid email address.';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),

            // Password
            TextFormField(
              controller: _password,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword
                      ? Icons.visibility_off : Icons.visibility),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Password is required.';
                if (v.length < 6) return 'Minimum 6 characters.';
                return null;
              },
            ),
            const SizedBox(height: 14),

            // Role
            DropdownButtonFormField<String>(
              value: _selectedRole,
              items: _roles.map((r) => DropdownMenuItem(
                    value: r,
                    child: Text(r[0].toUpperCase() + r.substring(1)),
                  )).toList(),
              onChanged: (val) => setState(() {
                _selectedRole   = val;
                // Reset mentor selection when role changes
                _selectedMentor = null;
              }),
              decoration: const InputDecoration(
                  labelText: 'Role',
                  prefixIcon: Icon(Icons.badge)),
              validator: (v) => v == null ? 'Please select a role.' : null,
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _goToStep2,
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14)),
                child: _isLoading
                    ? const SizedBox(height: 20, width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Text('Next →'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // Step 2 form  –  role-aware
  // ════════════════════════════════════════════════════════════════════════════

  Widget _buildStep2() {
    final stepLabel = _isMentor
        ? 'Step 2 of 2 – Choose your username'
        : 'Step 2 of 2 – Learning preferences';

    return Form(
      key: _form2Key,
      child: Container(
        key: ValueKey('step2_$_selectedRole'), // rebuilds when role changes
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header with back arrow ──────────────────────────────────────
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => setState(() => _step = 1),
                  tooltip: 'Back to step 1',
                ),
                Expanded(
                  child: Text(stepLabel,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.blue)),
                ),
              ],
            ),

            // ── Role badge (read-only reminder) ────────────────────────────
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _isMentor
                    ? Colors.purple.shade50
                    : Colors.blue.shade50,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _isMentor
                      ? Colors.purple.shade200
                      : Colors.blue.shade200,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _isMentor ? Icons.school : Icons.person,
                    size: 14,
                    color: _isMentor ? Colors.purple : Colors.blue,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Signing up as ${_isMentor ? "Mentor" : "Student"}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _isMentor ? Colors.purple : Colors.blue,
                    ),
                  ),
                ],
              ),
            ),

            // ── Username (shown for ALL roles) ──────────────────────────────
            TextFormField(
              controller: _username,
              onChanged: _onUsernameChanged,
              autocorrect: false,
              enableSuggestions: false,
              decoration: InputDecoration(
                labelText: 'Username',
                hintText: 'Choose a unique username',
                prefixIcon: const Icon(Icons.alternate_email),
                suffixIcon: _uniqueSuffixIcon(
                  checking: _usernameChecking,
                  error:    _usernameError,
                  value:    _username.text,
                ),
                errorText: _usernameError,
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Username is required.';
                if (v.trim().length < 3) return 'At least 3 characters.';
                if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(v.trim())) {
                  return 'Letters, numbers and underscores only.';
                }
                if (_usernameError != null) return _usernameError;
                return null;
              },
            ),
            const SizedBox(height: 20),

            // ── Student-only fields ─────────────────────────────────────────
            if (!_isMentor) ...[

              // Divider with label
              Row(children: [
                Expanded(child: Divider(color: Colors.grey.shade300)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text('Your learning setup',
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500)),
                ),
                Expanded(child: Divider(color: Colors.grey.shade300)),
              ]),
              const SizedBox(height: 16),

              // Mentor picker
              _buildMentorPicker(),
              const SizedBox(height: 20),

              // Learning need
              TextFormField(
                controller: _learningNeed,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Learning Need',
                  hintText: 'Describe what you want to learn…',
                  alignLabelWithHint: true,
                  prefixIcon: Icon(Icons.lightbulb_outline),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Please describe your learning need.' : null,
              ),
              const SizedBox(height: 8),
            ],

            const SizedBox(height: 16),

            // ── Submit ──────────────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 14)),
                child: _isLoading
                    ? const SizedBox(height: 20, width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : Text(_isMentor
                        ? 'Create Mentor Account'
                        : 'Submit & Get Started'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // Step indicator
  // ════════════════════════════════════════════════════════════════════════════

  Widget _buildStepper() {
    final step2Label = _isMentor ? 'Username' : 'Learning';
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _stepDot(1, 'Details'),
        _stepLine(),
        _stepDot(2, step2Label),
      ],
    );
  }

  Widget _stepDot(int n, String label) {
    final active = _step >= n;
    return Column(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: active ? Colors.blue : Colors.white38,
          child: Text('$n',
              style: TextStyle(
                  color: active ? Colors.white : Colors.white70,
                  fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 4),
        Text(label,
            style: const TextStyle(color: Colors.white, fontSize: 12)),
      ],
    );
  }

  Widget _stepLine() => Container(
        width: 60, height: 2,
        margin: const EdgeInsets.only(bottom: 18),
        color: _step == 2 ? Colors.blue : Colors.white38,
      );

  // ════════════════════════════════════════════════════════════════════════════
  // Root build
  // ════════════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    if (_initialising) {
      return const Scaffold(
        backgroundColor: Colors.blue,
        body: Center(
            child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Row(
          children: [
            Image.asset(
              'assets/images/codechathome.png',
              height: 35,
              errorBuilder: (c, e, s) =>
                  const Icon(Icons.school, color: Colors.white),
            ),
            const SizedBox(width: 10),
            const Text('Sign Up',
                style: TextStyle(color: Colors.white)),
          ],
        ),
        actions: [_buildTopNavigation()],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/softtutor.png',
              fit: BoxFit.cover,
              errorBuilder: (c, e, s) => Container(color: Colors.grey),
            ),
          ),
          Positioned.fill(
              child:
                  Container(color: Colors.black.withOpacity(0.45))),
          Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    const SizedBox(height: 10),
                    if (_showResumeBanner) _buildResumeBanner(),
                    _buildStepper(),
                    const SizedBox(height: 20),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 350),
                      transitionBuilder: (child, anim) =>
                          FadeTransition(opacity: anim, child: child),
                      child: _step == 1
                          ? _buildStep1()
                          : _buildStep2(),
                    ),
                  ],
                ),
              ),
              _buildFooter(),
            ],
          ),
        ],
      ),
    );
  }
}