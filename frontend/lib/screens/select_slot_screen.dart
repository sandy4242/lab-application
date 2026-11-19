import 'package:flutter/material.dart';
import '../services/mock_data_service.dart';
import 'package:intl/intl.dart';
import '../widgets/slot_match_card.dart';
import '../theme/app_theme.dart';

class SelectSlotScreen extends StatefulWidget {
  final String requestId;
  final String subjectName;

  const SelectSlotScreen({
    super.key,
    required this.requestId,
    required this.subjectName,
  });

  @override
  State<SelectSlotScreen> createState() => _SelectSlotScreenState();
}

class _SelectSlotScreenState extends State<SelectSlotScreen> {
  final MockDataService _dataService = MockDataService();
  List<dynamic> _matches = [];
  bool _isLoading = true;
  bool _isBooking = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchMatches();
  }

  Future<void> _fetchMatches() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final matches = _dataService.getMatchingSlots(widget.requestId);
      if (mounted) {
        setState(() {
          _matches = matches;
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

  Future<void> _bookSelectedSlot(String timetableId, String date) async {
    setState(() {
      _isBooking = true;
    });

    try {
      _dataService.bookSlot(
        requestId: widget.requestId,
        timetableId: timetableId,
        date: date,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Re-Lab Slot Booked Successfully!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context); // Return to dashboard
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Booking failed: $e'), backgroundColor: Colors.red),
      );
      setState(() {
        _isBooking = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Re-Lab Slot'),
      ),
      body: _isLoading || _isBooking
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(_isBooking ? 'Locking and booking your slot...' : 'Calculating matching slots...', style: const TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Error: $_error', style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 12),
                      ElevatedButton(onPressed: _fetchMatches, child: const Text('Retry')),
                    ],
                  ),
                )
              : _matches.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.event_busy, size: 60, color: Colors.grey.shade400),
                            const SizedBox(height: 16),
                            const Text(
                              'No matching slots found in the next 14 days.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Ensure your master section timetable is set, and that there are no student conflicts during scheduled sessions.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey, fontSize: 13),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Back to Dashboard')),
                          ],
                        ),
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          color: Colors.teal.shade50,
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.subjectName,
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Below are ranked available timetable slots matching your missed lab, filtered by conflicts.',
                                style: TextStyle(color: Colors.grey, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.all(12),
                            itemCount: _matches.length,
                            itemBuilder: (context, index) {
                              final match = _matches[index];
                              final timetableId = match['timetable_id'];
                              final dateRaw = match['date'];
                              final room = match['room'];
                              final teacherName = match['teacher_name'];
                              final sectionName = match['section_name'];
                              final score = match['score'] as int;
                              final availableCap = match['available_capacity'] as int;

                              String formattedDate = dateRaw;
                              try {
                                formattedDate = DateFormat.yMMMEd().format(DateTime.parse(dateRaw));
                              } catch (_) {}

                              return SlotMatchCard(
                                sectionName: sectionName,
                                room: room,
                                teacherName: teacherName,
                                dayOfWeek: formattedDate,
                                timeRange: '14:00 - 16:00',
                                matchPercentage: score,
                                currentLoad: (30 - availableCap).clamp(0, 30),
                                capacity: 30,
                                isBooking: _isBooking,
                                onBookSlot: () {
                                  showDialog(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text('Confirm Re-Lab Slot Booking'),
                                      content: Text(
                                        'Do you want to book this re-lab slot on $formattedDate in $room conducted by $teacherName?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(ctx),
                                          child: const Text('Cancel'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.pop(ctx);
                                            _bookSelectedSlot(timetableId, dateRaw);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppTheme.primaryEmerald,
                                            foregroundColor: Colors.white,
                                          ),
                                          child: const Text('Confirm Booking'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
    );
  }
}
