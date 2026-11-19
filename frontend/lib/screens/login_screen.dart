import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import 'persona_guide_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _rememberMe = true;
  int _selectedPersonaIndex = 0; // Default to Student

  // Institutional Demo Accounts
  final List<Map<String, dynamic>> _personas = [
    {
      'roleKey': 'student',
      'title': 'Student',
      'name': 'Rahul Sharma',
      'initials': 'RS',
      'badge': 'CSE 5th Sem • 21BCE1001',
      'email': 'student@relab.com',
      'password': 'password123',
      'icon': Icons.person_outline_rounded,
      'color': const Color(0xFF1E293B),
      'description': 'Submit applications, upload medical certificates, and select open timetable slots.',
    },
    {
      'roleKey': 'teacher_guardian',
      'title': 'Teacher Guardian',
      'name': 'Dr. Ananya Sen',
      'initials': 'AS',
      'badge': 'Academic Advisor • Stage 1',
      'email': 'tg@relab.com',
      'password': 'password123',
      'icon': Icons.verified_user_outlined,
      'color': const Color(0xFF1E293B),
      'description': 'First-line verification of student medical notes and initial approval.',
    },
    {
      'roleKey': 'lab_teacher',
      'title': 'Lab Teacher',
      'name': 'Prof. Rajesh Kumar',
      'initials': 'RK',
      'badge': 'Course Faculty • Stage 2',
      'email': 'teacher@relab.com',
      'password': 'password123',
      'icon': Icons.science_outlined,
      'color': const Color(0xFF1E293B),
      'description': 'Subject course teacher review and repetition clearance.',
    },
    {
      'roleKey': 'relab_teacher',
      'title': 'Re-Lab Teacher',
      'name': 'Prof. Vikram Mehta',
      'initials': 'VM',
      'badge': 'Lab In-Charge • Stage 3',
      'email': 'relabteacher@relab.com',
      'password': 'password123',
      'icon': Icons.repeat_rounded,
      'color': const Color(0xFF1E293B),
      'description': 'Slot capacity clearance, student attendance, and session completion.',
    },
    {
      'roleKey': 'hod',
      'title': 'Head of Dept',
      'name': 'Dr. Ramesh Gupta',
      'initials': 'RG',
      'badge': 'HOD Clearance • Stage 4',
      'email': 'hod@relab.com',
      'password': 'password123',
      'icon': Icons.account_balance_outlined,
      'color': const Color(0xFF1E293B),
      'description': 'Final departmental executive clearance before slot booking.',
    },
    {
      'roleKey': 'admin',
      'title': 'Administrator',
      'name': 'System Administrator',
      'initials': 'SA',
      'badge': 'System Oversight',
      'email': 'admin@relab.com',
      'password': 'password123',
      'icon': Icons.admin_panel_settings_outlined,
      'color': const Color(0xFF1E293B),
      'description': 'Global system monitoring, requests inspection, and department management.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectPersona(0, autoSubmit: false);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _selectPersona(int index, {bool autoSubmit = false}) {
    setState(() {
      _selectedPersonaIndex = index;
      _emailController.text = _personas[index]['email'];
      _passwordController.text = _personas[index]['password'];
    });

    if (autoSubmit) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _submit();
      });
    }
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      final success = await auth.signIn(email, password);

      if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(auth.errorMessage ?? 'Authentication failed. Please verify credentials.'),
            backgroundColor: const Color(0xFF991B1B), // dark red
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    }
  }

  void _openPersonaGuide() async {
    final selectedIndex = await Navigator.push<int>(
      context,
      MaterialPageRoute(
        builder: (_) => PersonaGuideScreen(
          personas: _personas,
          onSelectPersona: (index) {
            _selectPersona(index, autoSubmit: true);
          },
        ),
      ),
    );

    if (selectedIndex != null && mounted) {
      _selectPersona(selectedIndex, autoSubmit: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final size = MediaQuery.of(context).size;
    final isWide = size.width >= 920;

    // Mobile layout: Clean, non-scrollable view fitting entirely on screen
    if (!isWide) {
      final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: const Color(0xFF0F172A),
          elevation: 0,
          titleSpacing: 16,
          title: Row(
            children: [
              Image.asset(
                'assets/logo.png',
                width: 24,
                height: 24,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 8),
              const Flexible(
                child: Text(
                  'SMIT Re-Lab Portal',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          actions: [
            TextButton.icon(
              onPressed: _openPersonaGuide,
              icon: const Icon(Icons.help_outline, color: Colors.white70, size: 15),
              label: const Text(
                'Role Guide',
                style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(width: 6),
          ],
        ),
        body: SingleChildScrollView(
          physics: isKeyboardOpen ? const ClampingScrollPhysics() : const NeverScrollableScrollPhysics(),
          child: _buildFormPane(authProvider, isMobile: true),
        ),
      );
    }

    // Wide / Desktop layout: Centered dual-pane
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9), // clean slate-100
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 960),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Left Institutional Hero Pane
                  Expanded(
                    flex: 5,
                    child: _buildLeftHeroPane(),
                  ),
                  // Right Form Pane
                  Expanded(
                    flex: 6,
                    child: _buildFormPane(authProvider, isMobile: false),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Left Institutional Hero Pane (shown on wide screen)
  Widget _buildLeftHeroPane() {
    return Container(
      padding: const EdgeInsets.all(40),
      color: const Color(0xFF0F172A), // Institutional Deep Slate
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Academic Badge with Logo
              Row(
                children: [
                  Image.asset(
                    'assets/logo.png',
                    width: 32,
                    height: 32,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.white.withOpacity(0.12)),
                    ),
                    child: const Text(
                      'COLLEGE ACADEMIC PORTAL',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // App Title & Tagline
              const Text(
                'Digital Re-Lab\nManagement',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  height: 1.25,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Automated timetable matching, conflict-free slot allocation, and multi-tier institutional clearance.',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.75),
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 36),

              // Feature Highlights List
              _buildFeatureRow(
                icon: Icons.calendar_today_outlined,
                title: 'Timetable Clash Prevention',
                subtitle: 'Automatically excludes conflicting lecture and practical hours',
              ),
              const SizedBox(height: 18),
              _buildFeatureRow(
                icon: Icons.checklist_rounded,
                title: '4-Stage Approval Chain',
                subtitle: 'TG, Course Faculty, Re-Lab In-Charge & Department Head',
              ),
              const SizedBox(height: 18),
              _buildFeatureRow(
                icon: Icons.description_outlined,
                title: 'Digitized Verification',
                subtitle: 'Documented medical and on-duty attachments with complete audit log',
              ),
            ],
          ),

          // Footer Status
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle_outline, color: Colors.white70, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Academic Hierarchy Active (All 6 Roles)',
                    style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 11.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureRow({required IconData icon, required String title, required String subtitle}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 11.5, height: 1.3),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPersonaChip(int index) {
    final p = _personas[index];
    final isSelected = _selectedPersonaIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => _selectPersona(index, autoSubmit: false),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFE6F4F1) : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? const Color(0xFF0F766E) : const Color(0xFFE2E8F0),
              width: 1.0,
            ),
          ),
          child: Text(
            p['title'] as String,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? const Color(0xFF0F766E) : const Color(0xFF475569),
              fontSize: 12.5,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  // Right / Mobile Form Pane
  Widget _buildFormPane(AuthProvider authProvider, {bool isMobile = false}) {
    final activePersona = _personas[_selectedPersonaIndex];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 20.0 : 36.0, vertical: isMobile ? 14.0 : 24.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Row in Form Pane
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Welcome Back',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Sign in to your academic dashboard',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                if (!isMobile)
                  IconButton(
                    tooltip: 'View Role Guide',
                    onPressed: _openPersonaGuide,
                    icon: const Icon(Icons.info_outline, color: Color(0xFF475569)),
                  ),
              ],
            ),
            SizedBox(height: isMobile ? 14 : 20),

            // Section 1: Demo Accounts Grid & Persona Bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header: Demo Accounts & Tap to autofill (both 13px, baseline aligned, no icon)
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Demo Accounts',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    Flexible(
                      child: Text(
                        'Tap to autofill',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF64748B),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Equal-width 2-column grid: 3 rows of 2
                Row(
                  children: [
                    _buildPersonaChip(0),
                    const SizedBox(width: 8),
                    _buildPersonaChip(1),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildPersonaChip(2),
                    const SizedBox(width: 8),
                    _buildPersonaChip(3),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildPersonaChip(4),
                    const SizedBox(width: 8),
                    _buildPersonaChip(5),
                  ],
                ),
                const SizedBox(height: 10),

                // Active Selected Persona Row Styled as a Card
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: const Color(0xFFE6F4F1),
                        child: Text(
                          (activePersona['initials'] as String?) ?? 'RS',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F766E),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              activePersona['name'] as String,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              activePersona['badge'] as String,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      InkWell(
                        onTap: () => _selectPersona(_selectedPersonaIndex, autoSubmit: true),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          height: 38,
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F766E),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'Sign In',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Divider with "or enter manually"
            Row(
              children: [
                Expanded(child: Divider(color: Colors.grey.shade300)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'OR CREDENTIALS',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                Expanded(child: Divider(color: Colors.grey.shade300)),
              ],
            ),
            const SizedBox(height: 16),

            // Email Address Input
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Institutional Email Address',
                labelStyle: const TextStyle(fontSize: 13, color: Color(0xFF475569)),
                hintText: 'e.g. student@relab.com',
                prefixIcon: const Icon(Icons.mail_outline_rounded, size: 18, color: Color(0xFF64748B)),
                suffixIcon: _emailController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 16),
                        onPressed: () => setState(() => _emailController.clear()),
                      )
                    : null,
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF0F172A), width: 1.5),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your institutional email';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),

            // Password Input
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'Password',
                labelStyle: const TextStyle(fontSize: 13, color: Color(0xFF475569)),
                prefixIcon: const Icon(Icons.lock_outline_rounded, size: 18, color: Color(0xFF64748B)),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    size: 18,
                    color: const Color(0xFF64748B),
                  ),
                  tooltip: _obscurePassword ? 'Show password' : 'Hide password',
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF0F172A), width: 1.5),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your account password';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),

            // Remember Me & Need Help Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: Checkbox(
                          value: _rememberMe,
                          activeColor: const Color(0xFF0F172A),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          onChanged: (val) => setState(() => _rememberMe = val ?? true),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Flexible(
                        child: Text(
                          'Remember credentials',
                          style: TextStyle(fontSize: 12, color: Color(0xFF475569)),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: _openPersonaGuide,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'Need Help?',
                    style: TextStyle(color: Color(0xFF0F172A), fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Submit Button
            ElevatedButton(
              onPressed: authProvider.isLoading ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F172A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: authProvider.isLoading
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Sign In to Portal',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
            ),
            const SizedBox(height: 18),

            // Footer / Student Registration
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  "New Student? ",
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                ),
                InkWell(
                  onTap: () => Navigator.pushNamed(context, '/register'),
                  borderRadius: BorderRadius.circular(4),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    child: Text(
                      'Register for Re-Lab Portal',
                      style: TextStyle(
                        color: Color(0xFF0F172A),
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
