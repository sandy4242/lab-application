import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/mock_data_service.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../widgets/notifications_dialog.dart';
import 'request_detail_screen.dart';
import 'routine_timetable_screen.dart';

extension _FirstWhereOrNullExtension<E> on Iterable<E> {
  E? firstWhereOrNull(bool Function(E element) test) {
    for (final element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}

class StaffDashboard extends StatefulWidget {
  const StaffDashboard({super.key});

  @override
  State<StaffDashboard> createState() => _StaffDashboardState();
}

class _StaffDashboardState extends State<StaffDashboard> {
  final MockDataService _dataService = MockDataService();
  List<dynamic> _requests = [];
  bool _isLoading = true;
  String? _error;
  int _selectedTab = 0;
  int _historyFilter = 0; // 0: All, 1: Approved, 2: Rejected

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.userId ?? 'user-tg-1';
      final role = authProvider.role ?? 'teacher_guardian';
      final requests = _dataService.getRequestsForUser(userId, role);
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

  void _showApprovalDialog(String requestId, bool isApproval) {
    final remarksController = TextEditingController();
    final actionText = isApproval ? 'Approve' : 'Reject';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radius)),
        title: Text('$actionText Application', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              isApproval
                  ? 'Confirm endorsement to advance to the next clearance stage:'
                  : 'Enter rejection reason (Required):',
              style: const TextStyle(fontSize: 13, color: Color(0xFF475569)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: remarksController,
              decoration: InputDecoration(
                labelText: isApproval ? 'Remarks (Optional)' : 'Reason *',
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final remarks = remarksController.text.trim();
              if (!isApproval && remarks.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Rejection requires a reason.'), backgroundColor: Color(0xFF991B1B)),
                );
                return;
              }

              Navigator.pop(ctx);
              _processApproval(requestId, isApproval ? 'APPROVED' : 'REJECTED', remarks);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isApproval ? AppTheme.primaryTeal : AppTheme.statusRejected,
              foregroundColor: Colors.white,
            ),
            child: Text(isApproval ? 'Confirm Approval' : 'Reject'),
          ),
        ],
      ),
    );
  }

  void _processApproval(String requestId, String status, String remarks) async {
    setState(() => _isLoading = true);

    try {
      final role = Provider.of<AuthProvider>(context, listen: false).role ?? 'teacher_guardian';
      _dataService.approveRequest(
        requestId: requestId,
        approverRole: role,
        status: status,
        remarks: remarks,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Application marked as $status.'),
          backgroundColor: status == 'APPROVED' ? const Color(0xFF0F172A) : const Color(0xFF991B1B),
          behavior: SnackBarBehavior.floating,
        ),
      );
      _loadRequests();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Operation failed: $e'), backgroundColor: const Color(0xFF991B1B)),
      );
      setState(() => _isLoading = false);
    }
  }

  String _formatRole(String role) {
    switch (role) {
      case 'teacher_guardian':
        return 'Teacher Guardian';
      case 'lab_teacher':
        return 'Lab Teacher';
      case 'relab_teacher':
        return 'Re-Lab In-Charge';
      case 'hod':
        return 'Head of Department';
      case 'admin':
        return 'System Administrator';
      default:
        return role;
    }
  }

  int _getRoleStageNumber(String role) {
    switch (role) {
      case 'teacher_guardian':
        return 1;
      case 'lab_teacher':
        return 2;
      case 'relab_teacher':
        return 3;
      case 'hod':
        return 4;
      default:
        return 1;
    }
  }

  bool _isApprovedForRole(dynamic req, String role) {
    if (req['status'] == 'REJECTED') {
      final approvals = (req['approvals'] as List<dynamic>?) ?? [];
      final stageNum = _getRoleStageNumber(role);
      return approvals.any((a) => (a['approver_role'] == role || a['stage'] == stageNum) && a['status'] == 'APPROVED');
    }
    final status = req['status']?.toString() ?? '';
    if (status == 'APPROVED' || status == 'SLOT_SELECTED' || status == 'SCHEDULED' || status == 'COMPLETED') {
      return true;
    }
    final approvals = (req['approvals'] as List<dynamic>?) ?? [];
    final stageNum = _getRoleStageNumber(role);
    final hasApproval = approvals.any((a) => (a['approver_role'] == role || a['stage'] == stageNum) && a['status'] == 'APPROVED');
    if (hasApproval) return true;

    final stages = ['TG_PENDING', 'LAB_TEACHER_PENDING', 'RELAB_TEACHER_PENDING', 'HOD_PENDING', 'APPROVED'];
    final currentIdx = stages.indexOf(status);
    final roleStageIdx = stageNum - 1;
    return currentIdx > roleStageIdx;
  }

  bool _isRejectedForRole(dynamic req, String role) {
    final status = req['status']?.toString() ?? '';
    if (status == 'REJECTED') return true;
    final approvals = (req['approvals'] as List<dynamic>?) ?? [];
    return approvals.any((a) => a['status'] == 'REJECTED');
  }

  Color _getStatusDotColor(String status) {
    switch (status.toUpperCase()) {
      case 'APPROVED':
      case 'SLOT_SELECTED':
      case 'SCHEDULED':
        return AppTheme.primaryTeal;
      case 'COMPLETED':
        return AppTheme.statusCompleted;
      case 'REJECTED':
        return AppTheme.statusRejected;
      default:
        return AppTheme.statusPending;
    }
  }

  List<dynamic> get _pendingQueue {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final role = auth.role ?? 'teacher_guardian';

    if (role == 'admin') return _requests.where((r) => r['status'] != 'APPROVED' && r['status'] != 'REJECTED' && r['status'] != 'DRAFT').toList();

    String targetStatus = 'TG_PENDING';
    if (role == 'teacher_guardian') targetStatus = 'TG_PENDING';
    if (role == 'lab_teacher') targetStatus = 'LAB_TEACHER_PENDING';
    if (role == 'relab_teacher') targetStatus = 'RELAB_TEACHER_PENDING';
    if (role == 'hod') targetStatus = 'HOD_PENDING';

    return _requests.where((r) => r['status'] == targetStatus).toList();
  }

  List<dynamic> get _historyQueue {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final role = auth.role ?? 'teacher_guardian';

    if (role == 'admin') return _requests.where((r) => r['status'] == 'APPROVED' || r['status'] == 'REJECTED').toList();

    String targetStatus = 'TG_PENDING';
    if (role == 'teacher_guardian') targetStatus = 'TG_PENDING';
    if (role == 'lab_teacher') targetStatus = 'LAB_TEACHER_PENDING';
    if (role == 'relab_teacher') targetStatus = 'RELAB_TEACHER_PENDING';
    if (role == 'hod') targetStatus = 'HOD_PENDING';

    return _requests.where((r) => r['status'] != targetStatus && r['status'] != 'DRAFT').toList();
  }

  List<dynamic> get _filteredHistoryQueue {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final role = auth.role ?? 'teacher_guardian';
    final all = _historyQueue;

    if (_historyFilter == 1) {
      return all.where((r) => _isApprovedForRole(r, role)).toList();
    } else if (_historyFilter == 2) {
      return all.where((r) => _isRejectedForRole(r, role)).toList();
    }
    return all;
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final role = auth.role ?? 'teacher_guardian';
    final roleName = _formatRole(role);
    final pendingCount = _pendingQueue.length;
    final historyCount = _historyQueue.length;
    final approvedCount = _historyQueue.where((r) => _isApprovedForRole(r, role)).length;
    final rejectedCount = _historyQueue.where((r) => _isRejectedForRole(r, role)).length;

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
            Flexible(
              child: Text(
                roleName,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(44),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: AppTheme.hairlineBorder, width: 1)),
            ),
            child: Row(
              children: [
                _buildTabItem(
                  title: pendingCount > 0 ? 'Pending Verification ($pendingCount)' : 'Pending Verification',
                  isSelected: _selectedTab == 0,
                  onTap: () => setState(() => _selectedTab = 0),
                ),
                _buildTabItem(
                  title: historyCount > 0 ? 'Processed History ($historyCount)' : 'Processed History',
                  isSelected: _selectedTab == 1,
                  onTap: () => setState(() => _selectedTab = 1),
                ),
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded, size: 20),
            tooltip: 'Notifications',
            onPressed: () => NotificationsDialog.show(context),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 20),
            tooltip: 'Refresh Queue',
            onPressed: () async {
              await _loadRequests();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Verification queue updated.'),
                    duration: Duration(seconds: 1),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, size: 20),
            tooltip: 'Options',
            onSelected: (val) {
              if (val == 'timetable') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RoutineTimetableScreen()),
                );
              }
              if (val == 'reset') {
                _dataService.resetSampleData();
                _loadRequests();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Reset to initial sample data.'),
                    duration: Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'timetable',
                child: Row(
                  children: [
                    Icon(Icons.calendar_month_outlined, size: 16, color: Color(0xFF0F766E)),
                    SizedBox(width: 8),
                    Text('Department Timetables (3rd Sem)', style: TextStyle(fontSize: 12.5)),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'reset',
                child: Row(
                  children: [
                    Icon(Icons.restart_alt_rounded, size: 16, color: Color(0xFF64748B)),
                    SizedBox(width: 8),
                    Text('Reset to Initial Sample Data', style: TextStyle(fontSize: 12.5)),
                  ],
                ),
              ),
            ],
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
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Error loading requests: $_error', style: const TextStyle(color: Color(0xFFDC2626))),
                      const SizedBox(height: 8),
                      OutlinedButton(onPressed: _loadRequests, child: const Text('Try Again')),
                    ],
                  ),
                )
              : (_selectedTab == 0
                  ? _buildRequestsList(_pendingQueue, isPending: true)
                  : Column(
                      children: [
                        // Sub-filter segment for Processed History (All, Approved, Rejected)
                        Container(
                          color: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Row(
                            children: [
                              _buildFilterPill('All ($historyCount)', 0),
                              const SizedBox(width: 8),
                              _buildFilterPill('Approved ($approvedCount)', 1),
                              const SizedBox(width: 8),
                              _buildFilterPill('Rejected ($rejectedCount)', 2),
                            ],
                          ),
                        ),
                        const Divider(height: 1, thickness: 1, color: AppTheme.hairlineBorder),
                        Expanded(
                          child: _buildRequestsList(_filteredHistoryQueue, isPending: false),
                        ),
                      ],
                    )),
    );
  }

  Widget _buildFilterPill(String label, int filterIndex) {
    final isSelected = _historyFilter == filterIndex;
    return InkWell(
      onTap: () => setState(() => _historyFilter = filterIndex),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? const Color(0xFF0F172A) : AppTheme.hairlineBorder),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }

  Widget _buildTabItem({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? AppTheme.primaryTeal : Colors.transparent,
                width: 2.5,
              ),
            ),
          ),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              color: isSelected ? AppTheme.primaryTeal : const Color(0xFF64748B),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRequestsList(List<dynamic> requests, {required bool isPending}) {
    if (requests.isEmpty) {
      return RefreshIndicator(
        color: AppTheme.primaryTeal,
        onRefresh: _loadRequests,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: 320,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.assignment_turned_in_outlined, size: 36, color: Color(0xFF94A3B8)),
                      const SizedBox(height: 10),
                      Text(
                        isPending ? 'No applications currently pending your review.' : 'No processed applications found for this filter.',
                        style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppTheme.primaryTeal,
      onRefresh: _loadRequests,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppTheme.radius),
              border: Border.all(color: AppTheme.hairlineBorder),
            ),
            child: Column(
              children: [
                for (int index = 0; index < requests.length; index++) ...[
                  if (index > 0)
                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: AppTheme.hairlineBorder,
                    ),
                  _buildRequestRow(requests[index], isPending),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestRow(dynamic req, bool isPending) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final role = auth.role ?? 'teacher_guardian';

    final student = req['student'] as Map<String, dynamic>?;
    final studentName = student?['name']?.toString() ?? 'Student';
    final regNum = student?['registration_number']?.toString() ?? '21BCE1001';
    final subjectLab = req['subject_lab'] as Map<String, dynamic>?;
    final subjectName = subjectLab?['subject_name']?.toString() ?? 'Lab Session';
    final subjectCode = subjectLab?['subject_code']?.toString() ?? '';
    final missedDateRaw = req['missed_date']?.toString();
    final status = req['status']?.toString() ?? 'TG_PENDING';
    final reason = req['reason']?.toString() ?? '';
    final attachments = (req['attachments'] as List<dynamic>?) ?? [];
    final approvals = (req['approvals'] as List<dynamic>?) ?? [];

    String missedDate = missedDateRaw ?? 'Recent';
    if (missedDateRaw != null) {
      try {
        missedDate = DateFormat.MMMd().format(DateTime.parse(missedDateRaw));
      } catch (_) {}
    }

    final isApproved = !isPending && _isApprovedForRole(req, role);
    final isRejected = !isPending && _isRejectedForRole(req, role);

    // Dynamic dot color prioritizing verified state
    Color dotColor = _getStatusDotColor(status);
    if (!isPending) {
      if (isRejected) {
        dotColor = AppTheme.statusRejected;
      } else if (isApproved) {
        dotColor = AppTheme.primaryTeal;
      }
    }

    // Active subtitle explanation
    String statusSubtitle = 'Missed $missedDate • "$reason"';
    if (!isPending) {
      if (isRejected) {
        final rej = approvals.firstWhereOrNull((a) => a['status'] == 'REJECTED');
        final rejRemarks = rej?['remarks']?.toString() ?? '';
        statusSubtitle = rejRemarks.isNotEmpty ? 'Rejected • "$rejRemarks"' : 'Application verification rejected.';
      } else if (isApproved) {
        if (status == 'APPROVED' || status == 'SLOT_SELECTED' || status == 'SCHEDULED') {
          statusSubtitle = 'All 4 clearance stages completed • Ready for Re-Lab';
        } else {
          final nextHolder = status == 'LAB_TEACHER_PENDING'
              ? 'Course Lab Teacher'
              : status == 'RELAB_TEACHER_PENDING'
                  ? 'Re-Lab In-Charge'
                  : 'Head of Department';
          statusSubtitle = 'Endorsed by you • Currently awaiting $nextHolder clearance';
        }
      }
    }

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
            // Status Dot
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

            // Student & Lab Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                      style: const TextStyle(fontSize: 13.5, color: Color(0xFF0F172A)),
                      children: [
                        TextSpan(
                          text: studentName,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const TextSpan(text: ' '),
                        TextSpan(
                          text: '($regNum)',
                          style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subjectCode.isNotEmpty ? '$subjectName ($subjectCode)' : subjectName,
                    style: const TextStyle(fontSize: 12, color: Color(0xFF334155)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    statusSubtitle,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: isRejected
                          ? const Color(0xFFB91C1C)
                          : isApproved
                              ? const Color(0xFF0F766E)
                              : const Color(0xFF64748B),
                      fontWeight: (isRejected || isApproved) ? FontWeight.w500 : FontWeight.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (attachments.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.attach_file, size: 12, color: Color(0xFF94A3B8)),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            attachments.first['file_name']?.toString() ?? 'Document attached',
                            style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Quick Action / Status & Chevron
            if (isPending)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: () => _showApprovalDialog(req['id'], false),
                    borderRadius: BorderRadius.circular(4),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFFCA5A5)),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Reject',
                        style: TextStyle(fontSize: 11, color: AppTheme.statusRejected, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  InkWell(
                    onTap: () => _showApprovalDialog(req['id'], true),
                    borderRadius: BorderRadius.circular(4),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryTeal,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Approve',
                        style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              )
            else
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isRejected)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: const Color(0xFFFCA5A5)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.close_rounded, size: 11, color: AppTheme.statusRejected),
                          SizedBox(width: 3),
                          Text('Rejected', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.statusRejected)),
                        ],
                      ),
                    )
                  else if (isApproved)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDFA),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: const Color(0xFF99F6E4)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check_rounded, size: 11, color: AppTheme.primaryTeal),
                          const SizedBox(width: 3),
                          Text(
                            status == 'APPROVED' ? 'Approved' : 'Endorsed',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.primaryTeal),
                          ),
                        ],
                      ),
                    )
                  else
                    Text(
                      status.replaceAll('_', ' '),
                      style: TextStyle(fontSize: 11, color: dotColor, fontWeight: FontWeight.w500),
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
