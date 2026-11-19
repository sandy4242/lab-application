import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SlotMatchCard extends StatelessWidget {
  final String sectionName;
  final String room;
  final String teacherName;
  final String dayOfWeek;
  final String timeRange;
  final int matchPercentage;
  final int currentLoad;
  final int capacity;
  final bool isBooking;
  final VoidCallback onBookSlot;

  const SlotMatchCard({
    super.key,
    required this.sectionName,
    required this.room,
    required this.teacherName,
    required this.dayOfWeek,
    required this.timeRange,
    required this.matchPercentage,
    this.currentLoad = 18,
    this.capacity = 30,
    this.isBooking = false,
    required this.onBookSlot,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        border: Border.all(color: AppTheme.hairlineBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Day, Time & Match Percentage
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppTheme.primaryTeal,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$dayOfWeek • $timeRange',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13.5,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
                Text(
                  '$matchPercentage% Match',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryTeal,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Metadata Grid (compact Linear style)
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Batch & Room', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                      const SizedBox(height: 1),
                      Text(
                        'Sec $sectionName • $room',
                        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500, color: Color(0xFF0F172A)),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Faculty In-Charge', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                      const SizedBox(height: 1),
                      Text(
                        teacherName,
                        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500, color: Color(0xFF0F172A)),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Text(
                  '$currentLoad/$capacity Seats',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Booking Button
            SizedBox(
              width: double.infinity,
              height: 38,
              child: ElevatedButton(
                onPressed: isBooking ? null : onBookSlot,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryTeal,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radius)),
                ),
                child: isBooking
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text(
                        'Book Slot',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
