import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ApprovalStepData {
  final int stage;
  final String stageTitle;
  final String roleName;
  final String? approverName;
  final String status; // 'APPROVED', 'REJECTED', 'PENDING', 'QUEUED'
  final String? remarks;
  final String? timestamp;

  const ApprovalStepData({
    required this.stage,
    required this.stageTitle,
    required this.roleName,
    this.approverName,
    required this.status,
    this.remarks,
    this.timestamp,
  });
}

class ApprovalTimelineStepper extends StatelessWidget {
  final List<ApprovalStepData> steps;

  const ApprovalTimelineStepper({super.key, required this.steps});

  Color _getStatusDotColor(String status) {
    switch (status.toUpperCase()) {
      case 'APPROVED':
        return AppTheme.primaryTeal;
      case 'REJECTED':
        return AppTheme.statusRejected;
      case 'PENDING':
        return AppTheme.statusPending;
      default:
        return const Color(0xFFCBD5E1); // slate-300
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(steps.length, (index) {
        final step = steps[index];
        final isLast = index == steps.length - 1;
        final statusUpper = step.status.toUpperCase();
        final isApproved = statusUpper == 'APPROVED';
        final isRejected = statusUpper == 'REJECTED';
        final isPending = statusUpper == 'PENDING';
        final dotColor = _getStatusDotColor(step.status);

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left: Swiggy-style Continuous Timeline Track & Node
              SizedBox(
                width: 20,
                child: Column(
                  children: [
                    const SizedBox(height: 3),
                    // Swiggy-style Node Dot
                    if (isApproved)
                      Container(
                        width: 14,
                        height: 14,
                        decoration: const BoxDecoration(
                          color: AppTheme.primaryTeal,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check, size: 10, color: Colors.white),
                      )
                    else if (isPending)
                      Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.statusPending, width: 3),
                        ),
                      )
                    else if (isRejected)
                      Container(
                        width: 14,
                        height: 14,
                        decoration: const BoxDecoration(
                          color: AppTheme.statusRejected,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, size: 10, color: Colors.white),
                      )
                    else
                      Container(
                        width: 10,
                        height: 10,
                        margin: const EdgeInsets.symmetric(vertical: 2),
                        decoration: const BoxDecoration(
                          color: Color(0xFFE2E8F0),
                          shape: BoxShape.circle,
                        ),
                      ),

                    // Continuous Line
                    if (!isLast)
                      Expanded(
                        child: Container(
                          width: 1.5,
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          color: isApproved ? AppTheme.primaryTeal : const Color(0xFFE4E7E7),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // Right: Step Details
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Stage Title & Status Text
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              step.stageTitle,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isPending ? FontWeight.w600 : FontWeight.w500,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                          ),
                          // Subtle small status text (no loud pill)
                          Text(
                            isApproved
                                ? 'Cleared'
                                : isPending
                                    ? 'In Review'
                                    : isRejected
                                        ? 'Rejected'
                                        : 'Waiting',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: dotColor,
                            ),
                          ),
                        ],
                      ),

                      // Approver Name / Designation & Timestamp
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            step.approverName ?? step.roleName,
                            style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                          ),
                          if (step.timestamp != null) ...[
                            const Text(' • ', style: TextStyle(color: Color(0xFF94A3B8))),
                            Text(
                              step.timestamp!,
                              style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                            ),
                          ],
                        ],
                      ),

                      // Remarks Callout in Plain Language (Swiggy note style)
                      if (step.remarks != null && step.remarks!.trim().isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7F8F8),
                            borderRadius: BorderRadius.circular(AppTheme.radius),
                            border: Border.all(color: AppTheme.hairlineBorder),
                          ),
                          child: Text(
                            step.remarks!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF334155),
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
