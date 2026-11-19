import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../services/mock_data_service.dart';
import '../theme/app_theme.dart';
import '../widgets/notifications_dialog.dart';
import 'create_request_screen.dart';
import 'routine_timetable_screen.dart';
import 'request_detail_screen.dart';
import 'select_slot_screen.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  final MockDataService _dataService = MockDataService();
  List<Map<String, dynamic>> _requests = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests({bool showLoading = false}) async {
    if (showLoading || _requests.isEmpty) {
      if (mounted) {
        setState(() {
          _isLoading = true;
          _error = null;
        });
      }
    }

    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final userId = auth.userId ?? 'user-student-1';
      final requests = _dataService.getRequestsForUser(userId, 'student');
      if (mounted) {
        setState(() {
          _requests = requests;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Color _getStatusDotColor(String status) {
    switch (status.toUpperCase()) {
      case 'DRAFT':
        return const Color(0xFF94A3B8);
      case 'SUBMITTED':
      case 'TG_PENDING':
      case 'LAB_TEACHER_PENDING':
      case 'RELAB_TEACHER_PENDING':
      case 'HOD_PENDING':
        return AppTheme.statusPending; // #D97706
      case 'APPROVED':
      case 'SLOT_SELECTED':
      case 'SCHEDULED':
        return AppTheme.primaryTeal; // #0F766E
      case 'COMPLETED':
        return AppTheme.statusCompleted; // #16A34A
      case 'REJECTED':
      case 'CANCELLED':
        return AppTheme.statusRejected; // #DC2626
      default:
        return const Color(0xFF64748B);
    }
  }

  String _formatStatusLabel(String status) {
    switch (status.toUpperCase()) {
      case 'TG_PENDING':
        return 'Pending TG';
      case 'LAB_TEACHER_PENDING':
        return 'Pending Lab Teacher';
      case 'RELAB_TEACHER_PENDING':
        return 'Pending Re-Lab In-Charge';
      case 'HOD_PENDING':
        return 'Pending HOD';
      case 'APPROVED':
        return 'Approved';
      case 'SLOT_SELECTED':
      case 'SCHEDULED':
        return 'Scheduled';
      case 'COMPLETED':
        return 'Completed';
      case 'REJECTED':
        return 'Rejected';
      default:
        return status.replaceAll('_', ' ');
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final profile = auth.userProfile;
    final studentData = profile?['students'] as Map<String, dynamic>?;
    final sectionInfo = studentData?['sections'] as Map<String, dynamic>?;
    final deptInfo = sectionInfo?['departments'] as Map<String, dynamic>?;

    final deptName = deptInfo?['code']?.toString() ?? 'CSE';
    final sem = sectionInfo?['semester']?.toString() ?? '3';
    final sec = sectionInfo?['name']?.toString() ?? 'B';
    final regNum = studentData?['registration_number']?.toString() ?? '21BCE1001';
    final studentName = auth.name ?? profile?['name']?.toString() ?? 'Rahul Sharma';
    final firstLetter = studentName.trim().isNotEmpty
        ? studentName.trim().substring(0, 1).toUpperCase()
        : 'R';

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/logo.png',
              width: 22,
              height: 22,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 8),
            const Flexible(
              child: Text(
                'Student Portal',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today_outlined, size: 19),
            tooltip: 'Routine Timetable',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RoutineTimetableScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded, size: 20),
            tooltip: 'Notifications',
            onPressed: () => NotificationsDialog.show(context),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 20),
            tooltip: 'Refresh',
            onPressed: _loadRequests,
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, size: 20),
            tooltip: 'Sign Out',
            onPressed: () async {
              await auth.signOut();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryTeal),
              ),
            )
          : RefreshIndicator(
              color: AppTheme.primaryTeal,
              onRefresh: _loadRequests,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                  // 1. Left-aligned Student Identity Row (Google Classroom style)
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppTheme.radius),
                      border: Border.all(color: AppTheme.hairlineBorder),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: const Color(0xFFF1F5F9),
                          child: Text(
                            firstLetter,
                            style: const TextStyle(
                              color: Color(0xFF0F172A),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                studentName,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(height: 1),
                              Text(
                                '$regNum • $deptName Sem $sem (Sec $sec)',
                                style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 2. Class Routine & Timetable Quick Access (Linear compact row)
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const RoutineTimetableScreen()),
                      );
                    },
                    borderRadius: BorderRadius.circular(AppTheme.radius),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppTheme.radius),
                        border: Border.all(color: AppTheme.hairlineBorder),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.calendar_today_outlined, size: 16, color: Color(0xFF475569)),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Weekly Timetable & Routine Matrix',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ),
                          Icon(Icons.chevron_right, size: 18, color: Color(0xFF94A3B8)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 3. Section Heading: Re-Lab Applications (Linear style)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Applications',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '${_requests.length}',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // 4. State Handling: Error, Empty or Dense List Container
                  if (_error != null) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppTheme.radius),
                        border: Border.all(color: const Color(0xFFFCA5A5)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Failed to load applications: $_error', style: const TextStyle(color: Color(0xFFDC2626), fontSize: 12.5)),
                          const SizedBox(height: 8),
                          OutlinedButton(
                            onPressed: _loadRequests,
                            child: const Text('Try Again', style: TextStyle(fontSize: 12)),
                          ),
                        ],
                      ),
                    ),
                  ] else if (_requests.isEmpty) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 36),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppTheme.radius),
                        border: Border.all(color: AppTheme.hairlineBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'No active re-lab applications',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'If you missed a laboratory practical, file a digital application to begin the 4-stage verification workflow.',
                            style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B), height: 1.4),
                          ),
                          const SizedBox(height: 14),
                          ElevatedButton.icon(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const CreateRequestScreen()),
                            ).then((_) => _loadRequests()),
                            icon: const Icon(Icons.add, size: 16),
                            label: const Text('New Application'),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    // Dense Linear-style List Container with hairline dividers
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppTheme.radius),
                        border: Border.all(color: AppTheme.hairlineBorder),
                      ),
                      child: Column(
                        children: [
                          for (int index = 0; index < _requests.length; index++) ...[
                            if (index > 0)
                              const Divider(
                                height: 1,
                                thickness: 1,
                                color: AppTheme.hairlineBorder,
                              ),
                            _buildRequestRow(_requests[index]),
                          ],
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
      // Clear Focal Element: "+ New Request" button
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CreateRequestScreen()),
        ).then((_) => _loadRequests()),
        backgroundColor: AppTheme.primaryTeal,
        foregroundColor: Colors.white,
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radius)),
        icon: const Icon(Icons.add, size: 18),
        label: const Text(
          'New Request',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildRequestRow(Map<String, dynamic> req) {
    final subjectLab = req['subject_lab'] as Map<String, dynamic>?;
    final subject = subjectLab?['subject_name']?.toString() ?? 'Laboratory Session';
    final code = subjectLab?['subject_code']?.toString() ?? '';
    final missedDateRaw = req['missed_date']?.toString();
    final experimentName = req['experiment_name']?.toString();
    final status = req['status']?.toString() ?? 'DRAFT';
    final attachments = (req['attachments'] as List<dynamic>?) ?? [];

    String missedDate = missedDateRaw ?? 'Scheduled Date';
    if (missedDateRaw != null && missedDateRaw.isNotEmpty) {
      try {
        missedDate = DateFormat.MMMd().format(DateTime.parse(missedDateRaw));
      } catch (_) {
        missedDate = missedDateRaw;
      }
    }

    final dotColor = _getStatusDotColor(status);
    final statusLabel = _formatStatusLabel(status);
    final isApproved = status == 'APPROVED';

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RequestDetailScreen(requestId: req['id']?.toString() ?? ''),
          ),
        ).then((_) => _loadRequests());
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Status Dot (Small 7px dot, no loud pill)
            Padding(
              padding: const EdgeInsets.only(top: 5, right: 10),
              child: Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
              ),
            ),

            // Middle Information
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    code.isNotEmpty ? '$subject ($code)' : subject,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    experimentName != null && experimentName.isNotEmpty
                        ? 'Missed $missedDate • $experimentName'
                        : 'Missed on $missedDate',
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: Color(0xFF64748B),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (attachments.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.attach_file, size: 12, color: Color(0xFF94A3B8)),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            attachments.first['file_name']?.toString() ?? 'Document attached',
                            style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Right: Subtle Status Text or Action Button
            if (isApproved)
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SelectSlotScreen(
                        requestId: req['id']?.toString() ?? '',
                        subjectName: subject,
                      ),
                    ),
                  ).then((_) => _loadRequests());
                },
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryTeal,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Select Slot',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              )
            else
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    statusLabel,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: dotColor,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.chevron_right, size: 16, color: Color(0xFFCBD5E1)),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
