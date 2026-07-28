// ============================================================
//  create_need.dart  –  Full two-step signup
//
//  UPDATED:
//    • mentor role  → shows skill picker loaded from Django
//                     Skills model. Mentor taps chips to add
//                     skills, taps again to remove them.
//                     On submit, skills list is saved to
//                     Profile model via completeSignup API.
//    • student role → username + mentor picker (2 defaults +
//                     "Search others..." by skill/name) +
//                     learning need textarea
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
//  Mentor search modal  (student flow — unchanged from original)
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
          _error   = _results.isEmpty
              ? 'No mentors found for "${_searchCtrl.text}".'
              : null;
        });
      } else {
        setState(() {
          _loading = false;
          _error   = body['error']?.toString() ?? 'Search failed.';
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() { _loading = false; _error = 'Network error. Please try again.'; });
      }
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
                                  final m        = _results[i];
                                  final username = m['username']  as String? ?? '';
                                  final fullName = m['full_name'] as String? ?? username;
                                  final skills   = m['skills']   as String? ?? '';
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

  // ── Mentor selection (student flow) ────────────────────────────────────────
  String? _selectedMentor;

  // ── Skills (mentor flow) ───────────────────────────────────────────────────
  // All available skills loaded from Django Skill model
  List<String> _availableSkills  = [];
  // Skills the mentor has tapped/selected
  List<String> _selectedSkills   = [];
  // Loading state for the skills fetch
  bool         _skillsLoading    = false;
  String?      _skillsError;

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
        // If resuming as mentor, also reload skills
        if (_isMentor) _loadAvailableSkills();
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
  // Skills loader  (NEW — mentor flow only)
  // Calls GET /skills/  which returns the full Skill model list from Django
  // ════════════════════════════════════════════════════════════════════════════

  Future<void> _loadAvailableSkills() async {
    setState(() { _skillsLoading = true; _skillsError = null; });
    try {
      final res  = await ApiService.getSkills();
      final body = jsonDecode(res.body) as Map<String, dynamic>;

      if (res.statusCode == 200) {
        final list = body['skills'] as List<dynamic>? ?? [];
        setState(() {
          _availableSkills = list.map((e) => e.toString()).toList();
          _skillsLoading   = false;
        });
      } else {
        setState(() {
          _skillsLoading = false;
          _skillsError   = 'Could not load skills. Please try again.';
        });
      }
    } catch (_) {
      setState(() {
        _skillsLoading = false;
        _skillsError   = 'Network error loading skills.';
      });
    }
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
  // Mentor search modal opener  (student flow)
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

        // If mentor role — load available skills immediately after step 2 opens
        if (_isMentor) _loadAvailableSkills();

      } else {
        final errors = data['errors'] as Map<String, dynamic>?;
        _showMsg(errors != null
            ? errors.values.first.toString()
            : data['error']?.toString() ?? 'Could not save draft.');
      }
    } catch (_) {
      await _saveLocalDraft();
      setState(() => _step = 2);
      if (_isMentor) _loadAvailableSkills();
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

    // Mentors must select at least one skill
    if (_isMentor && _selectedSkills.isEmpty) {
      _showMsg('Please select at least one skill you can teach.');
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
        mentor:       _isMentor ? '' : (_selectedMentor ?? ''),
        learningNeed: _isMentor ? '' : _learningNeed.text.trim(),
        // NEW: comma-joined skill names sent to backend for Profile.skills field
        skills:       _isMentor ? _selectedSkills.join(',') : '',
      );

      Map<String, dynamic> data = {};
      try { data = jsonDecode(res.body); } catch (_) {}

      if (res.statusCode == 201 || res.statusCode == 200) {
        await _clearLocalDraft();
        final role             = data['role']     ?? _selectedRole;
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
  Widget _buildMentorPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
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
            ActionChip(
              avatar: const Icon(Icons.search, size: 16),
              label: const Text('Search others…'),
              backgroundColor: Colors.grey.shade100,
              onPressed: _openMentorSearch,
            ),
          ],
        ),
        if (_selectedMentor != null)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                border: Border.all(color: Colors.green.shade200),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle,
                      size: 18, color: Colors.green),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      _selectedMentor!,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () => setState(() => _selectedMentor = null),
                    child: const Icon(Icons.close, size: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  // ── Skills picker widget (mentors only)  ────────────────────────────────────
  //
  //  Layout:
  //  ┌─────────────────────────────────────────────────────┐
  //  │  🎓 Your Teaching Skills                            │
  //  │  Tap skills you can teach. Tap again to remove.     │
  //  │                                                     │
  //  │  [Python ✓]  [PHP]  [HTML ✓]  [CSS]  [Java]  …     │
  //  │                                                     │
  //  │  Selected: Python, HTML                             │
  //  └─────────────────────────────────────────────────────┘
  Widget _buildSkillPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section divider
        Row(children: [
          Expanded(child: Divider(color: Colors.grey.shade300)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              'Your teaching skills',
              style: TextStyle(
                  fontSize: 12, color: Colors.grey.shade500),
            ),
          ),
          Expanded(child: Divider(color: Colors.grey.shade300)),
        ]),
        const SizedBox(height: 14),

        // Label row
        Row(
          children: const [
            Icon(Icons.school_outlined, size: 20, color: Colors.grey),
            SizedBox(width: 8),
            Flexible(
              child: Text(
                'Skills you can teach',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          'Tap a skill to add it. Tap again to remove it.',
          style: TextStyle(fontSize: 12, color: Colors.white70),
        ),
        const SizedBox(height: 12),

        // Loading / error / chips
        if (_skillsLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: CircularProgressIndicator(color: Colors.white),
            ),
          )
        else if (_skillsError != null)
          Column(
            children: [
              Text(
                _skillsError!,
                style: const TextStyle(color: Colors.redAccent, fontSize: 13),
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: _loadAvailableSkills,
                icon: const Icon(Icons.refresh, color: Colors.white),
                label: const Text('Retry',
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          )
        else if (_availableSkills.isEmpty)
          const Text(
            'No skills available. Contact admin.',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          )
        else
          // ── Chip grid: each chip toggles the skill on/off ──────────────────
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _availableSkills.map((skill) {
              final isSelected = _selectedSkills.contains(skill);
              return FilterChip(
                label: Text(
                  skill,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                selected: isSelected,
                selectedColor: Colors.blue.shade700,
                backgroundColor: Colors.grey.shade100,
                checkmarkColor: Colors.white,
                onSelected: (picked) {
                  setState(() {
                    if (picked) {
                      _selectedSkills.add(skill);
                    } else {
                      _selectedSkills.remove(skill);
                    }
                  });
                },
              );
            }).toList(),
          ),

        // ── Selected skills summary ──────────────────────────────────────────
        if (_selectedSkills.isNotEmpty) ...[
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.green.shade800.withOpacity(0.35),
              border: Border.all(color: Colors.green.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.check_circle, size: 16, color: Colors.greenAccent),
                    SizedBox(width: 6),
                    Text(
                      'Selected skills:',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  _selectedSkills.join(', '),
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
        ] else ...[
          const SizedBox(height: 10),
          const Text(
            '⚠ Please select at least one skill to proceed.',
            style: TextStyle(color: Colors.orangeAccent, fontSize: 12),
          ),
        ],
      ],
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // Step 1 — personal details
  // ════════════════════════════════════════════════════════════════════════════

  Widget _buildStep1() {
    return Card(
      key: const ValueKey('step1'),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white.withOpacity(0.13),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _form1Key,
          child: Column(
            children: [

              TextFormField(
                controller: _fullName,
                textCapitalization: TextCapitalization.words,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  labelStyle: TextStyle(color: Colors.white70),
                  prefixIcon: Icon(Icons.person_outline, color: Colors.white70),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Full name is required.' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(color: Colors.white70),
                  prefixIcon: Icon(Icons.email_outlined, color: Colors.white70),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Email is required.';
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(v.trim())) {
                    return 'Enter a valid email.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _phone,
                keyboardType: TextInputType.phone,
                onChanged: _onPhoneChanged,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  hintText: '07xxxxxxxx',
                  labelStyle: const TextStyle(color: Colors.white70),
                  prefixIcon: const Icon(Icons.phone_outlined, color: Colors.white70),
                  suffixIcon: _uniqueSuffixIcon(
                    checking: _phoneChecking,
                    error:    _phoneError,
                    value:    _phone.text,
                  ),
                  errorText: _phoneError,
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Phone is required.';
                  if (_phoneError != null) return _phoneError;
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _password,
                obscureText: _obscurePassword,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: const TextStyle(color: Colors.white70),
                  prefixIcon: const Icon(Icons.lock_outline, color: Colors.white70),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: Colors.white70,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Password is required.';
                  if (v.length < 6) return 'At least 6 characters.';
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Role dropdown
              DropdownButtonFormField<String>(
                value: _selectedRole,
                dropdownColor: Colors.white,
                style: const TextStyle(color: Colors.black87),
                decoration: const InputDecoration(
                  labelText: 'Role',
                  labelStyle: TextStyle(color: Colors.white70),
                  prefixIcon: Icon(Icons.badge_outlined, color: Colors.white70),
                ),
                items: _roles.map((r) => DropdownMenuItem(
                  value: r,
                  child: Text(
                    r[0].toUpperCase() + r.substring(1),
                    style: const TextStyle(color: Colors.black87),
                  ),
                )).toList(),
                onChanged: (v) => setState(() => _selectedRole = v),
                validator: (v) =>
                    v == null ? 'Please select a role.' : null,
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _goToStep2,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 14)),
                  child: _isLoading
                      ? const SizedBox(height: 20, width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Text('Continue →',
                          style: TextStyle(fontSize: 15)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // Step 2 — username + role-specific fields
  // ════════════════════════════════════════════════════════════════════════════

  Widget _buildStep2() {
    return Card(
      key: const ValueKey('step2'),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white.withOpacity(0.13),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _form2Key,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // Back button
              GestureDetector(
                onTap: () => setState(() => _step = 1),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.arrow_back_ios, size: 14, color: Colors.white70),
                    SizedBox(width: 4),
                    Text('Back',
                        style: TextStyle(color: Colors.white70, fontSize: 13)),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Username field (all roles)
              TextFormField(
                controller: _username,
                onChanged: _onUsernameChanged,
                autocorrect: false,
                enableSuggestions: false,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Username',
                  hintText: 'Choose a unique username',
                  labelStyle: const TextStyle(color: Colors.white70),
                  prefixIcon:
                      const Icon(Icons.alternate_email, color: Colors.white70),
                  suffixIcon: _uniqueSuffixIcon(
                    checking: _usernameChecking,
                    error:    _usernameError,
                    value:    _username.text,
                  ),
                  errorText: _usernameError,
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty)
                    return 'Username is required.';
                  if (v.trim().length < 3) return 'At least 3 characters.';
                  if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(v.trim())) {
                    return 'Letters, numbers and underscores only.';
                  }
                  if (_usernameError != null) return _usernameError;
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // ── MENTOR: show skill picker ──────────────────────────────────
              if (_isMentor) ...[
                _buildSkillPicker(),
                const SizedBox(height: 20),
              ],

              // ── STUDENT: show mentor picker + learning need ────────────────
              if (!_isMentor) ...[
                Row(children: [
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text('Your learning setup',
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade400)),
                  ),
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                ]),
                const SizedBox(height: 16),

                _buildMentorPicker(),
                const SizedBox(height: 20),

                TextFormField(
                  controller: _learningNeed,
                  maxLines: 3,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Learning Need',
                    hintText: 'Describe what you want to learn…',
                    alignLabelWithHint: true,
                    labelStyle: TextStyle(color: Colors.white70),
                    prefixIcon: Icon(Icons.lightbulb_outline,
                        color: Colors.white70),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Please describe your learning need.' : null,
                ),
                const SizedBox(height: 8),
              ],

              const SizedBox(height: 16),

              // Submit button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding:
                          const EdgeInsets.symmetric(vertical: 14)),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20, width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : Text(
                          _isMentor
                              ? 'Create Mentor Account'
                              : 'Submit & Get Started',
                          style: const TextStyle(fontSize: 15),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // Step indicator
  // ════════════════════════════════════════════════════════════════════════════

  Widget _buildStepper() {
    final step2Label = _isMentor ? 'Skills' : 'Learning';
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
  // Resume banner
  // ════════════════════════════════════════════════════════════════════════════

  Widget _buildResumeBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.blue.shade800,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.white, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Resume signup for $_resumeEmail?',
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
          TextButton(
            onPressed: _discardDraft,
            child: const Text('Discard',
                style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: _resumeDraft,
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.blue.shade800),
            child: const Text('Resume'),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // Top navigation
  // ════════════════════════════════════════════════════════════════════════════

  Widget _buildTopNavigation() {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, color: Colors.white),
      onSelected: (v) {
        switch (v) {
          case 'contact':
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const ContactScreen()));
            break;
          case 'privacy':
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const PrivacyScreen()));
            break;
          case 'terms':
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const TermsCondScreen()));
            break;
          case 'login':
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => const HomeLoginScreen()));
            break;
        }
      },
      itemBuilder: (_) => const [
        PopupMenuItem(value: 'login',   child: Text('Login')),
        PopupMenuItem(value: 'contact', child: Text('Contact')),
        PopupMenuItem(value: 'privacy', child: Text('Privacy Policy')),
        PopupMenuItem(value: 'terms',   child: Text('Terms & Conditions')),
      ],
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // Footer
  // ════════════════════════════════════════════════════════════════════════════

  Widget _buildFooter() {
    return Container(
      color: Colors.black54,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton(
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const PrivacyScreen())),
            child: const Text('Privacy',
                style: TextStyle(color: Colors.white70, fontSize: 12)),
          ),
          const Text('·', style: TextStyle(color: Colors.white54)),
          TextButton(
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const TermsCondScreen())),
            child: const Text('Terms',
                style: TextStyle(color: Colors.white70, fontSize: 12)),
          ),
          const Text('·', style: TextStyle(color: Colors.white54)),
          TextButton(
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const ContactScreen())),
            child: const Text('Contact',
                style: TextStyle(color: Colors.white70, fontSize: 12)),
          ),
        ],
      ),
    );
  }

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
              errorBuilder: (c, e, s) =>
                  Container(color: Colors.grey),
            ),
          ),
          Positioned.fill(
              child: Container(
                  color: Colors.black.withOpacity(0.45))),
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