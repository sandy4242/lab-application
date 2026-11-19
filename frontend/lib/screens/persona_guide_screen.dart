import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PersonaGuideScreen extends StatefulWidget {
  final List<Map<String, dynamic>>? personas;
  final Function(int index)? onSelectPersona;

  const PersonaGuideScreen({
    super.key,
    this.personas,
    this.onSelectPersona,
  });

  @override
  State<PersonaGuideScreen> createState() => _PersonaGuideScreenState();
}

class _PersonaGuideScreenState extends State<PersonaGuideScreen> {
  String _selectedFilter = 'ALL'; // 'ALL', 'CHAIN', 'STUDENT_ADMIN'

  // Standard persona catalog with professional academic metadata
  late final List<Map<String, dynamic>> _personasCatalog;

  @override
  void initState() {
    super.initState();
    _personasCatalog = widget.personas ?? [
      {
        'roleKey': 'student',
        'title': 'Student',
        'name': 'Rahul Sharma',
        'badge': 'Applicant • CSE 5th Sem',
        'email': 'student@relab.com',
        'password': 'password123',
        'icon': Icons.person_outline_rounded,
        'stageNumber': 0,
        'isApprovalChain': false,
        'description': 'Submits missed lab applications, uploads medical/OD certificates, views approval status, and picks collision-free timetable slots.',
        'responsibilities': [
          'Create digital re-lab applications with missed experiment details',
          'Upload official enclosures (Medical certificates, OD letters)',
          'Track live 4-stage clearance progress and faculty remarks',
          'Select collision-free timetable slots and attend allocated sessions',
        ],
      },
      {
        'roleKey': 'teacher_guardian',
        'title': 'Teacher Guardian (TG)',
        'name': 'Dr. Ananya Sen',
        'badge': 'Stage 1 Clearance • Advisor',
        'email': 'tg@relab.com',
        'password': 'password123',
        'icon': Icons.verified_user_outlined,
        'stageNumber': 1,
        'isApprovalChain': true,
        'description': 'Primary student advisor responsible for initial attendance validation, reason legitimacy check, and medical certificate inspection.',
        'responsibilities': [
          'First-level screening of student absence rationale',
          'Inspect and verify attached medical/OD documentation',
          'Forward cleared requests to course Lab Teacher with remarks',
        ],
      },
      {
        'roleKey': 'lab_teacher',
        'title': 'Course Lab Teacher',
        'name': 'Prof. Rajesh Kumar',
        'badge': 'Stage 2 Clearance • Faculty',
        'email': 'teacher@relab.com',
        'password': 'password123',
        'icon': Icons.science_outlined,
        'stageNumber': 2,
        'isApprovalChain': true,
        'description': 'Subject faculty in charge of regular course sessions. Validates syllabus alignment and confirms student eligibility for experiment repetition.',
        'responsibilities': [
          'Verify experiment repetition eligibility against course syllabus',
          'Check student lab records and prior performance',
          'Clear request for cross-section re-lab scheduling',
        ],
      },
      {
        'roleKey': 'relab_teacher',
        'title': 'Re-Lab In-Charge',
        'name': 'Prof. Vikram Mehta',
        'badge': 'Stage 3 Clearance • Lab In-Charge',
        'email': 'relabteacher@relab.com',
        'password': 'password123',
        'icon': Icons.repeat_rounded,
        'stageNumber': 3,
        'isApprovalChain': true,
        'description': 'Faculty running the prospective re-lab session. Verifies hardware bench capacity, apparatus availability, and session safety limits.',
        'responsibilities': [
          'Inspect target lab batch occupancy and bench availability',
          'Confirm apparatus, software, and consumable resource readiness',
          'Mark attendance and grade experiments once session concludes',
        ],
      },
      {
        'roleKey': 'hod',
        'title': 'Head of Department (HOD)',
        'name': 'Dr. Ramesh Gupta',
        'badge': 'Stage 4 Clearance • Executive',
        'email': 'hod@relab.com',
        'password': 'password123',
        'icon': Icons.account_balance_outlined,
        'stageNumber': 4,
        'isApprovalChain': true,
        'description': 'Departmental head providing final institutional sign-off. Once approved by HOD, request unlocks automated slot selection for the student.',
        'responsibilities': [
          'Review cumulative remarks from TG, Course Teacher, and Lab In-Charge',
          'Institutional sign-off granting final authorization',
          'Executive oversight over department-wide re-lab quotas',
        ],
      },
      {
        'roleKey': 'admin',
        'title': 'System Administrator',
        'name': 'IT Administration Desk',
        'badge': 'System Oversight',
        'email': 'admin@relab.com',
        'password': 'password123',
        'icon': Icons.admin_panel_settings_outlined,
        'stageNumber': 5,
        'isApprovalChain': false,
        'description': 'System-wide administrative overseer with master visibility across all 4 stages, user roles, audit trails, and timetable matrices.',
        'responsibilities': [
          'Real-time departmental audit trail and request tracking',
          'Configure master course schedules, labs, and faculty assignments',
          'Override emergency workflow blocks and troubleshoot system logs',
        ],
      },
    ];
  }

  List<Map<String, dynamic>> get _filteredPersonas {
    if (_selectedFilter == 'CHAIN') {
      return _personasCatalog.where((p) => p['isApprovalChain'] == true).toList();
    } else if (_selectedFilter == 'STUDENT_ADMIN') {
      return _personasCatalog.where((p) => p['isApprovalChain'] == false).toList();
    }
    return _personasCatalog;
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied: $text'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _handleSignIn(int index) {
    if (widget.onSelectPersona != null) {
      widget.onSelectPersona!(index);
    }
    Navigator.pop(context, index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Academic Role Guide',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
            fontSize: 17,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE2E8F0), height: 1),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820),
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            children: [
              // Hero Overview Card
              _buildHeroOverviewCard(),
              const SizedBox(height: 18),

              // 4-Stage Clearance Pipeline
              _buildWorkflowPipelineCard(),
              const SizedBox(height: 20),

              // Filter Chips
              _buildFilterChipsRow(),
              const SizedBox(height: 16),

              // Persona Cards
              ..._filteredPersonas.map((persona) {
                final catalogIndex = _personasCatalog.indexOf(persona);
                return _buildPersonaCard(persona, catalogIndex);
              }),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroOverviewCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A), // Institutional Deep Slate
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'ACADEMIC WORKFLOW',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              const Spacer(),
              Image.asset(
                'assets/logo.png',
                width: 22,
                height: 22,
                fit: BoxFit.contain,
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Re-Lab Clearance Architecture',
            style: TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'This application replaces paper forms with an auditable 4-stage faculty clearance chain. Select any role below to test its dashboard and review permissions.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 13,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkflowPipelineCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'The 4-Stage Approval Chain',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Each request passes through four consecutive verification gates before slot booking:',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
          const SizedBox(height: 16),

          _buildPipelineStep(
            number: '0',
            label: 'Student Filing',
            subtitle: 'Attaches medical/OD documentation & missed experiment details',
            isLast: false,
          ),
          _buildPipelineStep(
            number: '1',
            label: 'Teacher Guardian (TG)',
            subtitle: 'Reviews absence reason & verifies medical certificates',
            isLast: false,
          ),
          _buildPipelineStep(
            number: '2',
            label: 'Course Lab Teacher',
            subtitle: 'Validates course repetition eligibility against syllabus',
            isLast: false,
          ),
          _buildPipelineStep(
            number: '3',
            label: 'Re-Lab In-Charge',
            subtitle: 'Verifies target lab batch capacity & hardware bench readiness',
            isLast: false,
          ),
          _buildPipelineStep(
            number: '4',
            label: 'Head of Department (HOD)',
            subtitle: 'Final institutional sign-off unlocking timetable slot selection',
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildPipelineStep({
    required String number,
    required String label,
    required String subtitle,
    required bool isLast,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF0F172A), width: 1.5),
              ),
              alignment: Alignment.center,
              child: Text(
                number,
                style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
            if (!isLast)
              Container(
                width: 1.5,
                height: 26,
                color: const Color(0xFFE2E8F0),
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2, bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12.5,
                    color: Color(0xFF0F172A),
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 11.5),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChipsRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip('ALL', 'All Roles (${_personasCatalog.length})'),
          const SizedBox(width: 8),
          _buildFilterChip('CHAIN', 'Approval Chain (Stages 1-4)'),
          const SizedBox(width: 8),
          _buildFilterChip('STUDENT_ADMIN', 'Student & Administrator'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String key, String label) {
    final isSelected = _selectedFilter == key;
    return InkWell(
      onTap: () => setState(() => _selectedFilter = key),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0F172A) : Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected ? const Color(0xFF0F172A) : const Color(0xFFCBD5E1),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? Colors.white : const Color(0xFF334155),
          ),
        ),
      ),
    );
  }

  Widget _buildPersonaCard(Map<String, dynamic> persona, int catalogIndex) {
    final List<String> responsibilities = (persona['responsibilities'] as List<dynamic>?)?.cast<String>() ?? [];

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Avatar, Name & Badge
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: const Color(0xFFF1F5F9),
                  child: Icon(persona['icon'] as IconData, color: const Color(0xFF0F172A), size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        persona['name'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        persona['title'],
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF475569),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Text(
                          persona['badge'],
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF475569),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Description
            Text(
              persona['description'],
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade700,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),

            // Key Responsibilities
            if (responsibilities.isNotEmpty) ...[
              const Text(
                'Responsibilities:',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF334155),
                ),
              ),
              const SizedBox(height: 6),
              ...responsibilities.map((r) => Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 5, right: 6),
                          child: Icon(Icons.circle, size: 4, color: Color(0xFF64748B)),
                        ),
                        Expanded(
                          child: Text(
                            r,
                            style: TextStyle(
                              fontSize: 11.5,
                              color: Colors.grey.shade800,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
              const SizedBox(height: 12),
            ],

            // Credentials Panel
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Text('Email: ', style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B))),
                      Expanded(
                        child: SelectableText(
                          persona['email'],
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'monospace',
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () => _copyToClipboard(persona['email'], 'Email'),
                        child: const Padding(
                          padding: EdgeInsets.all(2),
                          child: Icon(Icons.copy_rounded, size: 14, color: Color(0xFF475569)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Text('Password: ', style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B))),
                      Expanded(
                        child: SelectableText(
                          persona['password'],
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'monospace',
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () => _copyToClipboard(persona['password'], 'Password'),
                        child: const Padding(
                          padding: EdgeInsets.all(2),
                          child: Icon(Icons.copy_rounded, size: 14, color: Color(0xFF475569)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Sign In Button
            SizedBox(
              width: double.infinity,
              height: 38,
              child: ElevatedButton(
                onPressed: () => _handleSignIn(catalogIndex),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F172A),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: Text(
                  'Sign In as ${persona['title']}',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
