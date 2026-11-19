import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../services/mock_data_service.dart';
import '../theme/app_theme.dart';
import '../widgets/approval_timeline_stepper.dart';
import '../widgets/file_viewer_modal.dart';
import 'select_slot_screen.dart';

extension _FirstWhereOrNullExtension<E> on Iterable<E> {
  E? firstWhereOrNull(bool Function(E element) test) {
    for (final element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}

class RequestDetailScreen extends StatefulWidget {
  final String requestId;

  const RequestDetailScreen({super.key, required this.requestId});

  @override
  State<RequestDetailScreen> createState() => _RequestDetailScreenState();
}

class _RequestDetailScreenState extends State<RequestDetailScreen> {
  final MockDataService _dataService = MockDataService();
  Map<String, dynamic>? _request;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRequest();
  }

  void _loadRequest() {
    setState(() => _isLoading = true);
    final req = _dataService.getRequestById(widget.requestId);
    setState(() {
      _request = req;
      _isLoading = false;
    });
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

  String _formatStatusLabel(String status) {
    switch (status.toUpperCase()) {
      case 'TG_PENDING':
        return 'Pending Teacher Guardian';
      case 'LAB_TEACHER_PENDING':
        return 'Pending Lab Teacher';
      case 'RELAB_TEACHER_PENDING':
        return 'Pending Re-Lab In-Charge';
      case 'HOD_PENDING':
        return 'Pending HOD Clearance';
      case 'APPROVED':
        return 'Approved (Ready to Book)';
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

  List<ApprovalStepData> _buildStepperData() {
    if (_request == null) return [];

    final status = _request!['status'] ?? 'TG_PENDING';
    final approvals = _request!['approvals'] as List<dynamic>? ?? [];

    String getStageStatus(int stage, String pendingStageKey) {
      final approval = approvals.firstWhereOrNull(
        (a) => a['stage'] == stage,
      );
      if (approval != null) {
        return approval['status'] ?? 'APPROVED';
      }

      if (status == 'APPROVED' || status == 'SLOT_SELECTED' || status == 'SCHEDULED' || status == 'COMPLETED') {
        return 'APPROVED';
      }

      // If an earlier stage was rejected, subsequent stages were never reached ('QUEUED')
      final rejectedApproval = approvals.firstWhereOrNull(
        (a) => a['status'] == 'REJECTED',
      );
      if (rejectedApproval != null) {
        final rejectedStage = (rejectedApproval['stage'] as int?) ?? 1;
        if (stage > rejectedStage) {
          return 'QUEUED';
        }
      }

      if (status == pendingStageKey) {
        return 'PENDING';
      }

      final stages = ['TG_PENDING', 'LAB_TEACHER_PENDING', 'RELAB_TEACHER_PENDING', 'HOD_PENDING'];
      final currentIndex = stages.indexOf(status);
      final stageIndex = stage - 1;

      if (currentIndex != -1 && stageIndex < currentIndex) {
        return 'APPROVED';
      }

      return 'QUEUED';
    }

    String? getStageRemarks(int stage) {
      final approval = approvals.firstWhereOrNull(
        (a) => a['stage'] == stage,
      );
      if (approval != null && approval['remarks'] != null && approval['remarks'].toString().isNotEmpty) {
        return approval['remarks'].toString();
      }
      return null;
    }

    String? getStageTimestamp(int stage) {
      final approval = approvals.firstWhereOrNull(
        (a) => a['stage'] == stage,
      );
      if (approval != null && approval['created_at'] != null) {
        try {
          return DateFormat.MMMd().add_jm().format(DateTime.parse(approval['created_at'].toString()));
        } catch (_) {
          return approval['created_at'].toString();
        }
      }
      return null;
    }

    return [
      ApprovalStepData(
        stage: 1,
        stageTitle: 'Stage 1: Teacher Guardian (TG) Review',
        roleName: 'Academic Advisor',
        approverName: 'Dr. Ananya Sen',
        status: getStageStatus(1, 'TG_PENDING'),
        remarks: getStageRemarks(1) ??
            (getStageStatus(1, 'TG_PENDING') == 'APPROVED'
                ? 'Document verification completed and endorsed.'
                : null),
        timestamp: getStageTimestamp(1) ?? (getStageStatus(1, 'TG_PENDING') == 'APPROVED' ? 'Oct 15, 11:30 AM' : null),
      ),
      ApprovalStepData(
        stage: 2,
        stageTitle: 'Stage 2: Course Lab Teacher Clearance',
        roleName: 'Subject Faculty',
        approverName: 'Prof. Rajesh Kumar',
        status: getStageStatus(2, 'LAB_TEACHER_PENDING'),
        remarks: getStageRemarks(2) ??
            (getStageStatus(2, 'LAB_TEACHER_PENDING') == 'APPROVED'
                ? 'Syllabus alignment confirmed. Experiment repetition approved.'
                : null),
        timestamp: getStageTimestamp(2) ?? (getStageStatus(2, 'LAB_TEACHER_PENDING') == 'APPROVED' ? 'Oct 15, 03:45 PM' : null),
      ),
      ApprovalStepData(
        stage: 3,
        stageTitle: 'Stage 3: Re-Lab In-Charge Verification',
        roleName: 'Re-Lab Faculty',
        approverName: 'Prof. Vikram Mehta',
        status: getStageStatus(3, 'RELAB_TEACHER_PENDING'),
        remarks: getStageRemarks(3) ??
            (getStageStatus(3, 'RELAB_TEACHER_PENDING') == 'APPROVED'
                ? 'Lab capacity verified. Seat assigned.'
                : null),
        timestamp: getStageTimestamp(3) ?? (getStageStatus(3, 'RELAB_TEACHER_PENDING') == 'APPROVED' ? 'Oct 16, 10:15 AM' : null),
      ),
      ApprovalStepData(
        stage: 4,
        stageTitle: 'Stage 4: Head of Department (HOD) Sign-Off',
        roleName: 'Department Head',
        approverName: 'Dr. Ramesh Gupta',
        status: getStageStatus(4, 'HOD_PENDING'),
        remarks: getStageRemarks(4) ??
            (getStageStatus(4, 'HOD_PENDING') == 'APPROVED'
                ? 'Cleared by HOD office. Quota verified.'
                : null),
        timestamp: getStageTimestamp(4) ?? (getStageStatus(4, 'HOD_PENDING') == 'APPROVED' ? 'Oct 16, 01:20 PM' : null),
      ),
    ];
  }

  void _showApprovalDialog(bool isApprove) {
    final remarksController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radius)),
        title: Text(
          isApprove ? 'Approve Re-Lab Application' : 'Reject Re-Lab Application',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              isApprove
                  ? 'Endorse this application to forward it to the next verification stage:'
                  : 'Enter the rationale for rejecting this application:',
              style: const TextStyle(fontSize: 13, color: Color(0xFF475569)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: remarksController,
              decoration: InputDecoration(
                labelText: isApprove ? 'Remarks (Optional)' : 'Rejection Reason *',
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              final auth = Provider.of<AuthProvider>(context, listen: false);
              _dataService.approveRequest(
                requestId: widget.requestId,
                approverRole: auth.role ?? 'teacher_guardian',
                status: isApprove ? 'APPROVED' : 'REJECTED',
                remarks: remarksController.text.trim(),
              );
              _loadRequest();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isApprove ? AppTheme.primaryTeal : AppTheme.statusRejected,
              foregroundColor: Colors.white,
            ),
            child: Text(isApprove ? 'Confirm Approval' : 'Reject'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryTeal),
          ),
        ),
      );
    }

    if (_request == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Application Detail')),
        body: const Center(
          child: Text('Application not found.', style: TextStyle(color: Color(0xFF64748B))),
        ),
      );
    }

    final auth = Provider.of<AuthProvider>(context);
    final userRole = auth.role ?? 'student';

    final subject = _request!['subject_lab']?['subject_name'] ?? 'Laboratory Session';
    final subjectCode = _request!['subject_lab']?['subject_code'] ?? 'CS3101';
    final missedDateRaw = _request!['missed_date'];
    final experimentName = _request!['experiment_name'];
    final status = _request!['status'] ?? 'DRAFT';
    final reason = _request!['reason'] ?? '';
    final studentName = _request!['student']?['name'] ?? 'Rahul Sharma';
    final regNum = _request!['student']?['registration_number'] ?? '21BCE1001';
    final attachments = _request!['attachments'] as List<dynamic>? ?? [];

    String formattedMissedDate = missedDateRaw;
    try {
      formattedMissedDate = DateFormat.yMMMMd().format(DateTime.parse(missedDateRaw));
    } catch (_) {}

    final dotColor = _getStatusDotColor(status);
    final statusText = _formatStatusLabel(status);
    final approvals = _request!['approvals'] as List<dynamic>? ?? [];

    int userStage = 1;
    if (userRole == 'teacher_guardian') userStage = 1;
    if (userRole == 'lab_teacher') userStage = 2;
    if (userRole == 'relab_teacher') userStage = 3;
    if (userRole == 'hod') userStage = 4;

    final myApproval = approvals.firstWhereOrNull(
      (a) => a['stage'] == userStage || a['approver_role'] == userRole,
    );
    final isMyStageApproved = myApproval != null && myApproval['status'] == 'APPROVED';
    final isMyStageRejected = myApproval != null && myApproval['status'] == 'REJECTED';
    final isOverallRejected = status == 'REJECTED';
    final isOverallApproved = status == 'APPROVED' || status == 'SLOT_SELECTED' || status == 'SCHEDULED' || status == 'COMPLETED';

    final rejApproval = approvals.firstWhereOrNull(
      (a) => a['status'] == 'REJECTED',
    );
    final rejectionRemarks = rejApproval?['remarks']?.toString() ?? '';

    bool canApprove = false;
    if (!isMyStageApproved && !isMyStageRejected && !isOverallRejected) {
      if (userRole == 'teacher_guardian' && status == 'TG_PENDING') canApprove = true;
      if (userRole == 'lab_teacher' && status == 'LAB_TEACHER_PENDING') canApprove = true;
      if (userRole == 'relab_teacher' && status == 'RELAB_TEACHER_PENDING') canApprove = true;
      if (userRole == 'hod' && status == 'HOD_PENDING') canApprove = true;
      if (userRole == 'admin' && status.contains('PENDING')) canApprove = true;
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Application Detail', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Application Details Container (Linear clean layout with hairline borders)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppTheme.radius),
                    border: Border.all(color: AppTheme.hairlineBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status Dot & Code
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 7,
                                height: 7,
                                decoration: BoxDecoration(
                                  color: dotColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                statusText,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: dotColor,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            subjectCode,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Title & Experiment
                      Text(
                        subject,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      if (experimentName != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          experimentName,
                          style: const TextStyle(fontSize: 12.5, color: Color(0xFF475569)),
                        ),
                      ],
                      const SizedBox(height: 12),

                      const Divider(height: 1, color: AppTheme.hairlineBorder),
                      const SizedBox(height: 12),

                      // Student Info & Missed Date
                      Row(
                        children: [
                          const Icon(Icons.person_outline, size: 14, color: Color(0xFF64748B)),
                          const SizedBox(width: 6),
                          Text(
                            '$studentName ($regNum)',
                            style: const TextStyle(fontSize: 12, color: Color(0xFF334155)),
                          ),
                          const Spacer(),
                          const Icon(Icons.calendar_today_outlined, size: 13, color: Color(0xFF64748B)),
                          const SizedBox(width: 6),
                          Text(
                            formattedMissedDate,
                            style: const TextStyle(fontSize: 12, color: Color(0xFF334155)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Reason for Absence in plain text
                      const Text(
                        'Reason for Absence:',
                        style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        reason,
                        style: const TextStyle(fontSize: 12.5, color: Color(0xFF1E293B), height: 1.4),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Active Verification State Banner (Approved / Rejected)
                if (isMyStageApproved) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDFA),
                      borderRadius: BorderRadius.circular(AppTheme.radius),
                      border: Border.all(color: const Color(0xFF99F6E4)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.check_circle_rounded, color: AppTheme.primaryTeal, size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Active Verification: Stage $userStage Endorsed',
                                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF0F766E)),
                                  ),
                                  const Spacer(),
                                  if (myApproval['created_at'] != null)
                                    Text(
                                      DateFormat.MMMd().format(DateTime.parse(myApproval['created_at'].toString())),
                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF0F766E)),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Text(
                                isOverallApproved
                                    ? 'All clearances finalized. Application is fully approved for student scheduling.'
                                    : 'You endorsed this application. It has actively advanced in the verification chain below.',
                                style: const TextStyle(fontSize: 11.5, color: Color(0xFF134E4A)),
                              ),
                              if (myApproval['remarks'] != null && myApproval['remarks'].toString().isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  'Your Remarks: "${myApproval['remarks']}"',
                                  style: const TextStyle(fontSize: 11.5, fontStyle: FontStyle.italic, color: Color(0xFF115E59)),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ] else if (isOverallRejected) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(AppTheme.radius),
                      border: Border.all(color: const Color(0xFFFCA5A5)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.cancel_rounded, color: AppTheme.statusRejected, size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Active Verification: Application Rejected',
                                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF991B1B)),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                isMyStageRejected
                                    ? 'You rejected this application during verification.'
                                    : 'This application was rejected during verification and will not proceed.',
                                style: const TextStyle(fontSize: 11.5, color: Color(0xFF7F1D1D)),
                              ),
                              if (rejectionRemarks.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  'Rejection Reason: "$rejectionRemarks"',
                                  style: const TextStyle(fontSize: 11.5, fontStyle: FontStyle.italic, color: Color(0xFF991B1B)),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // 2. Supporting Enclosure Card
                if (attachments.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppTheme.radius),
                      border: Border.all(color: AppTheme.hairlineBorder),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.attach_file, color: Color(0xFF475569), size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                attachments.first['file_name'] ?? 'Enclosure Document',
                                style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12.5, color: Color(0xFF0F172A)),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                attachments.first['file_size'] ?? 'Attached Proof',
                                style: const TextStyle(color: Color(0xFF64748B), fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        OutlinedButton(
                          onPressed: () async {
                            final action = await FileViewerModal.show(
                              context,
                              fileName: attachments.first['file_name'] ?? 'Document.pdf',
                              filePath: attachments.first['file_path'],
                              fileBytes: attachments.first['file_bytes'],
                              fileSize: attachments.first['file_size'],
                              requestInfo: {
                                'student_name': studentName,
                                'registration_number': regNum,
                                'missed_date': formattedMissedDate,
                                'reason': reason,
                                'subject_name': subject,
                              },
                              canApprove: canApprove,
                            );
                            if (!mounted) return;
                            if (action == 'approve') {
                              _showApprovalDialog(true);
                            } else if (action == 'reject') {
                              _showApprovalDialog(false);
                            }
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            minimumSize: const Size(0, 32),
                            side: const BorderSide(color: AppTheme.hairlineBorder),
                          ),
                          child: const Text('View Document', style: TextStyle(fontSize: 11.5)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // 3. Focal Action for Approved Requests (Student Slot Booking)
                if (status == 'APPROVED' && userRole == 'student') ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppTheme.radius),
                      border: Border.all(color: AppTheme.primaryTeal),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Clearance Complete — Select Timetable Slot',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13.5,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Your application has completed all 4 departmental approval gates. Choose a clash-free slot with another section.',
                          style: TextStyle(color: Color(0xFF475569), fontSize: 12, height: 1.35),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => SelectSlotScreen(
                                  requestId: widget.requestId,
                                  subjectName: subject,
                                ),
                              ),
                            ).then((_) => _loadRequest());
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryTeal,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Select Slot'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // 4. Swiggy-Style Vertical Approval Stepper
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppTheme.radius),
                    border: Border.all(color: AppTheme.hairlineBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Approval Chain',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5, color: Color(0xFF0F172A)),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        '4-stage verification hierarchy progress',
                        style: TextStyle(color: Color(0xFF64748B), fontSize: 11.5),
                      ),
                      const SizedBox(height: 16),
                      ApprovalTimelineStepper(steps: _buildStepperData()),
                    ],
                  ),
                ),

                // 5. Approver Action Bar (if current user can approve)
                if (canApprove) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _showApprovalDialog(false),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.statusRejected,
                            side: const BorderSide(color: Color(0xFFFCA5A5)),
                            minimumSize: const Size(0, 44),
                          ),
                          child: const Text('Reject Application', style: TextStyle(fontWeight: FontWeight.w600)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _showApprovalDialog(true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryTeal,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(0, 44),
                          ),
                          child: const Text('Approve Stage', style: TextStyle(fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
