import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../services/mock_data_service.dart';
import '../services/semester_timetable_data.dart';

class RoutineTimetableScreen extends StatefulWidget {
  const RoutineTimetableScreen({super.key});

  @override
  State<RoutineTimetableScreen> createState() => _RoutineTimetableScreenState();
}

class _RoutineTimetableScreenState extends State<RoutineTimetableScreen> {
  final MockDataService _dataService = MockDataService();
  
  // Section state (default to B. Tech III Sem B, matching Rahul Sharma)
  String _selectedSectionId = 'sec-cseb';
  int _viewMode = 0; // 0: Daily Schedule, 1: Weekly Matrix, 2: Course & Faculty Roster
  String _selectedDay = 'Monday';
  final bool _isLoading = false;

  final List<String> _weekDays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
  ];

  static const Color primaryTeal = Color(0xFF0F766E);
  static const Color neutralBg = Color(0xFFF7F8F8);
  static const Color borderHairline = Color(0xFFE4E7E7);

  @override
  void initState() {
    super.initState();
    final today = DateFormat('EEEE').format(DateTime.now());
    if (_weekDays.contains(today)) {
      _selectedDay = today;
    }
  }

  Map<String, dynamic> get _currentSectionData =>
      SemesterTimetableData.getSectionData(_selectedSectionId);

  List<Map<String, dynamic>> get _currentSlots {
    final raw = (_currentSectionData['slots'] as List<dynamic>?) ?? [];
    return raw.map((s) => Map<String, dynamic>.from(s as Map)).toList();
  }

  List<Map<String, dynamic>> get _currentDaySlots {
    final dayList = _currentSlots.where((s) => s['day_of_week'] == _selectedDay).toList();
    dayList.sort((a, b) {
      final slotA = (a['slot_number'] as int?) ?? 0;
      final slotB = (b['slot_number'] as int?) ?? 0;
      return slotA.compareTo(slotB);
    });
    return dayList;
  }

  bool _isSectionActiveInEngine(String userId) {
    final studentRoutine = _dataService.getStudentRoutine(userId);
    if (studentRoutine.isEmpty) return false;
    if (_currentSlots.isNotEmpty && studentRoutine.isNotEmpty) {
      return studentRoutine.length == _currentSlots.length &&
          studentRoutine.first['subject_code'] == _currentSlots.first['subject_code'];
    }
    return false;
  }

  void _syncSectionToEngine(String userId) {
    _dataService.saveStudentRoutine(userId, _currentSlots);
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Synchronized ${_currentSectionData["metadata"]?["class_name"]} with Re-Lab Conflict Engine.',
        ),
        backgroundColor: primaryTeal,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showUploadDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _RoutineUploadBottomSheet(
        onRoutineUpdated: () {
          setState(() {});
        },
      ),
    );
  }

  void _resetToDefault() {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final userId = auth.userId ?? 'user-student-1';
    _dataService.resetStudentRoutine(userId, _selectedSectionId);
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Reverted to official departmental timetable.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final userId = auth.userId ?? 'user-student-1';
    final isEngineActive = _isSectionActiveInEngine(userId);
    final metadata = _currentSectionData['metadata'] as Map<String, dynamic>? ?? {};

    return Scaffold(
      backgroundColor: neutralBg,
      appBar: AppBar(
        title: const Text(
          '3rd Semester Timetable',
          style: TextStyle(
            fontSize: 16.5,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E293B),
            letterSpacing: -0.3,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: borderHairline, height: 1.0),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Color(0xFF475569)),
            onSelected: (val) {
              if (val == 'sync') _syncSectionToEngine(userId);
              if (val == 'upload') _showUploadDialog();
              if (val == 'reset') _resetToDefault();
            },
            itemBuilder: (ctx) => [
              PopupMenuItem(
                value: 'sync',
                child: Row(
                  children: [
                    Icon(Icons.sync, color: isEngineActive ? primaryTeal : Colors.grey, size: 18),
                    const SizedBox(width: 8),
                    Text(isEngineActive ? 'Already Synced with Engine' : 'Sync Section to Re-Lab'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'upload',
                child: Row(
                  children: [
                    Icon(Icons.upload_file, color: Colors.blueGrey, size: 18),
                    SizedBox(width: 8),
                    Text('Upload / Scan Custom Timetable'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'reset',
                child: Row(
                  children: [
                    Icon(Icons.restore, color: Colors.blueGrey, size: 18),
                    SizedBox(width: 8),
                    Text('Reset to Department Default'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryTeal))
          : Column(
              children: [
                // 1. SECTION SWITCHER PILLS (A, B, C, AI & ML)
                _buildSectionSelector(userId),

                // 2. OFFICIAL INSTITUTIONAL HEADER & ENGINE STATUS
                _buildInstitutionalHeader(metadata, isEngineActive, userId),

                // 3. VIEW MODE TAB SELECTOR
                _buildViewModeSelector(),

                // 4. VIEW CONTENT
                Expanded(
                  child: IndexedStack(
                    index: _viewMode,
                    children: [
                      _buildDailyScheduleView(),
                      _buildWeeklyMatrixView(),
                      _buildCourseFacultyRosterView(),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  // =========================================================================
  // 1. SECTION SWITCHER
  // =========================================================================
  Widget _buildSectionSelector(String userId) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: SemesterTimetableData.sections.map((sec) {
            final isSelected = sec['id'] == _selectedSectionId;
            final isRahulSection = sec['id'] == 'sec-cseb';

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: InkWell(
                onTap: () {
                  setState(() {
                    _selectedSectionId = sec['id']!;
                  });
                },
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: isSelected ? primaryTeal : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isSelected ? primaryTeal : borderHairline,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        sec['label']!,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                          color: isSelected ? Colors.white : const Color(0xFF334155),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white.withOpacity(0.2) : Colors.white,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: isSelected ? Colors.white.withOpacity(0.3) : borderHairline,
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          sec['room']!.replaceAll('Room No. ', ''),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : const Color(0xFF64748B),
                          ),
                        ),
                      ),
                      if (isRahulSection) ...[
                        const SizedBox(width: 5),
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.amberAccent : Colors.teal,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // =========================================================================
  // 2. INSTITUTIONAL HEADER & LAB NOTICE
  // =========================================================================
  Widget _buildInstitutionalHeader(
    Map<String, dynamic> metadata,
    bool isEngineActive,
    String userId,
  ) {
    final dept = metadata['dept'] ?? 'DEPARTMENT OF COMPUTER SCIENCE & ENGINEERING';
    final className = metadata['class_name'] ?? 'B. TECH III SEM';
    final room = metadata['room'] ?? '';
    final wef = metadata['wef'] ?? '28th July 2026';

    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dept,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                        color: Color(0xFF0F766E),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$className • $room • WEF $wef',
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
              ),
              if (!isEngineActive)
                InkWell(
                  onTap: () => _syncSectionToEngine(userId),
                  borderRadius: BorderRadius.circular(5),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: const Color(0xFFBFDBFE), width: 1),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.sync, size: 13, color: Color(0xFF1D4ED8)),
                        SizedBox(width: 4),
                        Text(
                          'Sync Routine',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1D4ED8),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: const Color(0xFFBBF7D0), width: 1),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle, size: 13, color: Color(0xFF15803D)),
                      SizedBox(width: 4),
                      Text(
                        'Active in Engine',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF15803D),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: borderHairline, width: 1),
            ),
            child: const Row(
              children: [
                Icon(Icons.science, size: 14, color: primaryTeal),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'LAB TIMING: 9:00-11:00 AM • 11:15-1:15 PM • 1:15-3:15 PM • 3:30-5:30 PM  |  VENUE: MP LAB',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF334155),
                      letterSpacing: 0.1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // 3. VIEW MODE SELECTOR (Daily, Weekly, Faculty)
  // =========================================================================
  Widget _buildViewModeSelector() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(3),
        child: Row(
          children: [
            _buildModeTabItem(0, 'Daily Schedule', Icons.view_day_outlined),
            _buildModeTabItem(1, 'Weekly Matrix', Icons.grid_on_outlined),
            _buildModeTabItem(2, 'Course & Faculty', Icons.people_outline),
          ],
        ),
      ),
    );
  }

  Widget _buildModeTabItem(int mode, String label, IconData icon) {
    final isSelected = _viewMode == mode;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _viewMode = mode;
          });
        },
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    )
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 14,
                color: isSelected ? primaryTeal : const Color(0xFF64748B),
              ),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? const Color(0xFF0F172A) : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================================
  // VIEW 0: DAILY SCHEDULE VIEW
  // =========================================================================
  Widget _buildDailyScheduleView() {
    final slots = _currentDaySlots;

    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            children: _weekDays.map((d) {
              final isSelected = d == _selectedDay;
              final dayCount = _currentSlots.where((s) => s['day_of_week'] == d).length;

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedDay = d;
                      });
                    },
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected ? primaryTeal.withOpacity(0.1) : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isSelected ? primaryTeal : borderHairline,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            d.substring(0, 3).toUpperCase(),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                              color: isSelected ? primaryTeal : const Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            '$dayCount slots',
                            style: TextStyle(
                              fontSize: 9.5,
                              color: isSelected ? primaryTeal : const Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const Divider(height: 1, color: borderHairline),

        Expanded(
          child: slots.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.event_available, size: 48, color: Color(0xFFCBD5E1)),
                      const SizedBox(height: 8),
                      Text(
                        'No classes scheduled on $_selectedDay',
                        style: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
                  itemCount: slots.length,
                  separatorBuilder: (ctx, idx) {
                    final current = slots[idx];
                    final next = idx + 1 < slots.length ? slots[idx + 1] : null;

                    if (current['end_time'] == '11:00' && next != null && next['start_time'] == '11:15') {
                      return _buildRecessDivider('Morning Recess • 11:00 AM - 11:15 AM');
                    }
                    if (current['end_time'] == '15:15' && next != null && next['start_time'] == '15:30') {
                      return _buildRecessDivider('Afternoon Recess • 3:15 PM - 3:30 PM');
                    }
                    return const SizedBox(height: 8);
                  },
                  itemBuilder: (context, index) {
                    final slot = slots[index];
                    return _buildDailySlotCard(slot, index);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildRecessDivider(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Expanded(child: Divider(color: borderHairline, thickness: 1)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.coffee, size: 12, color: Color(0xFF64748B)),
                  const SizedBox(width: 4),
                  Text(
                    text,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Expanded(child: Divider(color: borderHairline, thickness: 1)),
        ],
      ),
    );
  }

  Widget _buildDailySlotCard(Map<String, dynamic> slot, int index) {
    final isLab = slot['is_lab'] == true;
    final subjectName = slot['subject_name'] ?? 'Class';
    final subjectCode = slot['subject_code'] ?? '';
    final startTime = slot['start_time'] ?? '';
    final endTime = slot['end_time'] ?? '';
    final room = slot['room'] ?? '';
    final teacher = slot['teacher_name'] ?? 'Faculty';
    final slotNum = slot['slot_number'] ?? (index + 1);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isLab ? const Color(0xFF99F6E4) : borderHairline,
          width: isLab ? 1.4 : 1.0,
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 76,
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
            decoration: BoxDecoration(
              color: isLab ? const Color(0xFFCCFBF1) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: isLab ? const Color(0xFF99F6E4) : borderHairline,
                width: 0.8,
              ),
            ),
            child: Column(
              children: [
                Text(
                  isLab ? 'LAB (2h)' : 'Period $slotNum',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: isLab ? const Color(0xFF0F766E) : const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  startTime,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                Text(
                  endTime,
                  style: const TextStyle(
                    fontSize: 10.5,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isLab ? const Color(0xFF0F766E) : const Color(0xFF334155),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        isLab ? 'LAB PRACTICAL' : (subjectCode.contains('EL') ? 'ELECTIVE' : 'THEORY'),
                        style: const TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      subjectCode,
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F766E),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: borderHairline, width: 0.8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.meeting_room_outlined, size: 11, color: Color(0xFF475569)),
                          const SizedBox(width: 3),
                          Text(
                            room,
                            style: const TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF334155),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  subjectName,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.person_outline, size: 13, color: Color(0xFF64748B)),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        teacher,
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: Color(0xFF475569),
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // VIEW 1: WEEKLY MATRIX GRID
  // =========================================================================
  Widget _buildWeeklyMatrixView() {
    final matrix = (_currentSectionData['matrix'] as Map<String, dynamic>?) ?? {};

    const timeHeaders = [
      'Day',
      '9:00 - 10:00',
      '10:00 - 11:00',
      '11:00 - 11:15',
      '11:15 - 12:15',
      '12:15 - 1:15',
      '1:15 - 2:15',
      '2:15 - 3:15',
      '3:15 - 3:30',
      '3:30 - 4:30',
      '4:30 - 5:30',
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      padding: const EdgeInsets.fromLTRB(10, 12, 10, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Row(
              children: [
                Icon(Icons.touch_app_outlined, size: 14, color: primaryTeal),
                SizedBox(width: 6),
                Text(
                  'Scroll horizontally to view all 8 periods. Tap any slot to inspect details.',
                  style: TextStyle(fontSize: 11, color: Color(0xFF475569)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: borderHairline, width: 1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DataTable(
                  columnSpacing: 14,
                  headingRowHeight: 38,
                  dataRowMinHeight: 48,
                  dataRowMaxHeight: 56,
                  headingRowColor: MaterialStateProperty.all(const Color(0xFFF8FAFC)),
                  border: TableBorder.all(color: borderHairline, width: 0.8),
                  columns: timeHeaders.map((header) {
                    final isBreak = header.contains('11:00 - 11:15') || header.contains('3:15 - 3:30');
                    return DataColumn(
                      label: Text(
                        header,
                        style: TextStyle(
                          fontSize: isBreak ? 10 : 11,
                          fontWeight: FontWeight.w700,
                          color: isBreak ? const Color(0xFF94A3B8) : const Color(0xFF1E293B),
                        ),
                      ),
                    );
                  }).toList(),
                  rows: _weekDays.map((day) {
                    final daySchedule = (matrix[day] as Map<String, dynamic>?) ?? {};

                    return DataRow(
                      cells: [
                        DataCell(
                          Text(
                            day.substring(0, 3).toUpperCase(),
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ),
                        _buildMatrixCell(daySchedule['09:00-10:00']),
                        _buildMatrixCell(daySchedule['10:00-11:00']),
                        const DataCell(
                          Center(
                            child: Text(
                              'RECESS',
                              style: TextStyle(fontSize: 9, color: Color(0xFF94A3B8), fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                        _buildMatrixCell(daySchedule['11:15-12:15']),
                        _buildMatrixCell(daySchedule['12:15-13:15']),
                        _buildMatrixCell(daySchedule['13:15-14:15']),
                        _buildMatrixCell(daySchedule['14:15-15:15']),
                        const DataCell(
                          Center(
                            child: Text(
                              'RECESS',
                              style: TextStyle(fontSize: 9, color: Color(0xFF94A3B8), fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                        _buildMatrixCell(daySchedule['15:30-16:30']),
                        _buildMatrixCell(daySchedule['16:30-17:30']),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  DataCell _buildMatrixCell(dynamic slotData) {
    if (slotData == null) {
      return const DataCell(
        Center(
          child: Text('—', style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 13)),
        ),
      );
    }

    final map = Map<String, dynamic>.from(slotData as Map);
    final isLab = map['is_lab'] == true;
    final code = map['code']?.toString() ?? '';
    final room = map['room']?.toString() ?? '';

    return DataCell(
      InkWell(
        onTap: () => _showSlotDetailsModal(map),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          decoration: BoxDecoration(
            color: isLab ? const Color(0xFFCCFBF1) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: isLab ? const Color(0xFF5EEAD4) : borderHairline,
              width: 0.8,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                code,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: isLab ? const Color(0xFF0F766E) : const Color(0xFF1E293B),
                ),
              ),
              if (room.isNotEmpty && room != 'Classroom')
                Text(
                  room,
                  style: TextStyle(
                    fontSize: 9,
                    color: isLab ? const Color(0xFF0F766E) : const Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSlotDetailsModal(Map<String, dynamic> slot) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: slot['is_lab'] == true ? primaryTeal : const Color(0xFF334155),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    slot['is_lab'] == true ? 'LAB PRACTICAL' : 'LECTURE',
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  slot['code'] ?? '',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF0F766E)),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              slot['name'] ?? 'Class Session',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 12),
            _buildDetailRow(Icons.meeting_room_outlined, 'Location', slot['room'] ?? 'Official Department Room'),
            const SizedBox(height: 6),
            _buildDetailRow(Icons.person_outline, 'Faculty', slot['teacher'] ?? 'Department Faculty'),
            if (slot['is_lab'] == true) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDFA),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFF99F6E4), width: 0.8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, size: 14, color: primaryTeal),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'This lab practical runs across two continuous periods in MP LAB.',
                        style: TextStyle(fontSize: 11, color: Color(0xFF0F766E)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 14, color: const Color(0xFF64748B)),
        const SizedBox(width: 6),
        Text('$label: ', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
          ),
        ),
      ],
    );
  }

  // =========================================================================
  // VIEW 2: COURSE & FACULTY ROSTER
  // =========================================================================
  Widget _buildCourseFacultyRosterView() {
    final roster = (_currentSectionData['courseRoster'] as List<dynamic>?) ?? [];
    final electiveRooms = (_currentSectionData['electiveRooms'] as Map<String, dynamic>?) ?? {};

    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: borderHairline, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
                child: Row(
                  children: [
                    const Icon(Icons.school_outlined, size: 16, color: primaryTeal),
                    const SizedBox(width: 6),
                    Text(
                      'Subjects & Faculty Allocation (${_currentSectionData["metadata"]?["class_name"]})',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: borderHairline),
              ...roster.map((item) {
                final sub = Map<String, dynamic>.from(item as Map);
                final code = sub['code'] ?? '';
                final name = sub['name'] ?? '';
                final faculty = sub['faculty'] ?? '';
                final shortFrom = sub['shortFrom'] ?? '';
                final credits = sub['credit'] ?? 4;
                final isLab = name.toLowerCase().contains('lab');

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: borderHairline, width: 0.8)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 72,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              code,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: isLab ? primaryTeal : const Color(0xFF1E293B),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: Text(
                                '$credits Cr',
                                style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              faculty,
                              style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: borderHairline, width: 0.8),
                        ),
                        child: Text(
                          shortFrom,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF334155),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 14),

        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: borderHairline, width: 1),
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.room_preferences_outlined, size: 16, color: primaryTeal),
                  SizedBox(width: 6),
                  Text(
                    'Elective Classroom & Lab Allocations',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                'PROGRAM ELECTIVE-I ROOMS:',
                style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: primaryTeal),
              ),
              const SizedBox(height: 4),
              _buildElectiveRoomPill('Java Programming', electiveRooms['Java Programming'] ?? 'MP LAB'),
              _buildElectiveRoomPill('Microprocessors & Peripheral Devices', electiveRooms['Microprocessors and Peripheral Devices'] ?? 'PG & R LAB-I'),
              _buildElectiveRoomPill('E-Commerce', electiveRooms['E-Commerce'] ?? 'ROOM E-306'),
              _buildElectiveRoomPill('Digital Signal Processing (DSP)', electiveRooms['DSP'] ?? 'ROOM E-307'),
              _buildElectiveRoomPill('MFML', electiveRooms['MFML'] ?? 'ROOM E-315'),
              const SizedBox(height: 10),
              const Text(
                'OPEN ELECTIVE ROOMS:',
                style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: primaryTeal),
              ),
              const SizedBox(height: 4),
              _buildElectiveRoomPill('Industry Version 4.0', electiveRooms['Industry Version 4.0'] ?? 'ROOM E-315'),
              _buildElectiveRoomPill('Python Programming', electiveRooms['Python'] ?? 'ROOM E-307'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildElectiveRoomPill(String title, String room) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '• $title',
              style: const TextStyle(fontSize: 11.5, color: Color(0xFF334155)),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: borderHairline, width: 0.8),
            ),
            child: Text(
              room,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: primaryTeal),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoutineUploadBottomSheet extends StatefulWidget {
  final VoidCallback onRoutineUpdated;

  const _RoutineUploadBottomSheet({required this.onRoutineUpdated});

  @override
  State<_RoutineUploadBottomSheet> createState() => _RoutineUploadBottomSheetState();
}

class _RoutineUploadBottomSheetState extends State<_RoutineUploadBottomSheet> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final MockDataService _dataService = MockDataService();

  // CSV Tab State
  final TextEditingController _csvTextController = TextEditingController();
  PlatformFile? _pickedFile;
  List<Map<String, dynamic>> _parsedSlotsPreview = [];
  String? _statusMessage;

  // AI Scanner Tab State
  PlatformFile? _aiPickedFile;
  bool _isAiScanning = false;
  List<Map<String, dynamic>> _aiExtractedSlots = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _csvTextController.dispose();
    super.dispose();
  }

  Future<void> _pickCsvOrJsonFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv', 'txt', 'json'],
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        setState(() {
          _pickedFile = file;
        });

        String content = '';
        if (file.bytes != null) {
          content = utf8.decode(file.bytes!);
        }
        _csvTextController.text = content;
        _parseCurrentInput(content);
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Error picking file: $e';
      });
    }
  }

  void _parseCurrentInput(String text) {
    if (text.trim().isEmpty) {
      setState(() {
        _parsedSlotsPreview = [];
      });
      return;
    }

    try {
      // Check if JSON
      if (text.trim().startsWith('[') || text.trim().startsWith('{')) {
        final decoded = jsonDecode(text);
        final list = decoded is List ? decoded : (decoded['slots'] ?? []);
        setState(() {
          _parsedSlotsPreview = List<Map<String, dynamic>>.from(list);
          _statusMessage = 'Parsed ${_parsedSlotsPreview.length} periods from JSON';
        });
      } else {
        // Parse CSV
        final slots = _dataService.parseRoutineCSV(text);
        setState(() {
          _parsedSlotsPreview = slots;
          _statusMessage = 'Parsed ${slots.length} periods from CSV';
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Parsing error: $e';
      });
    }
  }

  void _copySampleCsv() {
    final sample = _dataService.getSampleRoutineCSV();
    Clipboard.setData(ClipboardData(text: sample));
    _csvTextController.text = sample;
    _parseCurrentInput(sample);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sample CSV template loaded into editor and copied!')),
    );
  }

  void _saveParsedSlots(List<Map<String, dynamic>> slotsToSave) {
    if (slotsToSave.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No slots to save. Please parse or paste a routine first.'), backgroundColor: Colors.orange),
      );
      return;
    }

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final userId = auth.userId ?? 'user-student-1';
    _dataService.saveStudentRoutine(userId, slotsToSave);

    widget.onRoutineUpdated();
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Timetable updated with ${slotsToSave.length} periods & synced with Re-Lab Matcher!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _pickImageOrPdfForAI() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _aiPickedFile = result.files.first;
          _aiExtractedSlots = [];
        });
      }
    } catch (e) {
      debugPrint('Error picking image for AI: $e');
    }
  }

  Future<void> _runAiScan() async {
    if (_aiPickedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a timetable image or PDF first.'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() {
      _isAiScanning = true;
    });

    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final userId = auth.userId ?? 'user-student-1';

      String? base64Str;
      if (_aiPickedFile?.bytes != null) {
        base64Str = base64Encode(_aiPickedFile!.bytes!);
      }

      final extracted = await _dataService.parseRoutineAI(
        studentId: userId,
        imageBase64: base64Str,
        fileName: _aiPickedFile?.name,
      );

      setState(() {
        _aiExtractedSlots = extracted;
        _isAiScanning = false;
      });
    } catch (e) {
      setState(() {
        _isAiScanning = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('AI extraction failed: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header Drag Handle & Title
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Upload Class Routine',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Upload CSV/JSON template or scan your timetable with Gemini AI',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),

          // Tabs
          TabBar(
            controller: _tabController,
            labelColor: Colors.teal,
            indicatorColor: Colors.teal,
            tabs: const [
              Tab(icon: Icon(Icons.table_chart), text: 'CSV / JSON Template'),
              Tab(icon: Icon(Icons.document_scanner), text: 'AI Routine Scanner'),
            ],
          ),

          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildCsvTab(),
                _buildAiScannerTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCsvTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Actions bar
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickCsvOrJsonFile,
                  icon: const Icon(Icons.folder_open),
                  label: Text(_pickedFile != null ? _pickedFile!.name : 'Choose File'),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: _copySampleCsv,
                icon: const Icon(Icons.content_copy, size: 16),
                label: const Text('Sample Template'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal.shade50,
                  foregroundColor: Colors.teal.shade900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Text / Editor Area
          Expanded(
            flex: 2,
            child: TextField(
              controller: _csvTextController,
              maxLines: null,
              expands: true,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
              decoration: InputDecoration(
                hintText: 'Paste CSV or JSON here, or pick a file above...\n\nHeader format:\nDay,Slot,Start_Time,End_Time,Subject_Code,Subject_Name,Room,Teacher,Is_Lab',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.all(12),
              ),
              onChanged: _parseCurrentInput,
            ),
          ),
          const SizedBox(height: 8),

          if (_statusMessage != null && _statusMessage!.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                _statusMessage!,
                style: TextStyle(fontSize: 12, color: Colors.teal.shade800, fontWeight: FontWeight.w500),
              ),
            ),
          ],

          // Preview Count and Save Button
          if (_parsedSlotsPreview.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    'Ready: ${_parsedSlotsPreview.length} periods detected',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],

          ElevatedButton.icon(
            onPressed: _parsedSlotsPreview.isEmpty
                ? null
                : () => _saveParsedSlots(_parsedSlotsPreview),
            icon: const Icon(Icons.save),
            label: const Text('Apply & Sync Routine to Timetable'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiScannerTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // File picker box
          InkWell(
            onTap: _pickImageOrPdfForAI,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.teal.shade300, style: BorderStyle.solid, width: 1.5),
                borderRadius: BorderRadius.circular(12),
                color: Colors.teal.shade50.withOpacity(0.4),
              ),
              child: Column(
                children: [
                  const Icon(Icons.add_photo_alternate_outlined, size: 48, color: Colors.teal),
                  const SizedBox(height: 8),
                  Text(
                    _aiPickedFile != null
                        ? 'Selected: ${_aiPickedFile!.name}'
                        : 'Tap to select Routine Photo or Department PDF',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Supports JPG, PNG, PDF of your college schedule',
                    style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          ElevatedButton.icon(
            onPressed: (_aiPickedFile == null || _isAiScanning) ? null : _runAiScan,
            icon: _isAiScanning
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Icon(Icons.auto_awesome),
            label: Text(_isAiScanning ? 'Scanning with Gemini AI...' : 'Scan Routine with Gemini AI'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
          const SizedBox(height: 12),

          // Extracted items list
          Expanded(
            child: _aiExtractedSlots.isEmpty
                ? Center(
                    child: Text(
                      _isAiScanning
                          ? 'Extracting class periods, rooms, and teachers...'
                          : 'Select an image/PDF and tap "Scan Routine" to preview extracted slots.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.check_circle_outline, color: Colors.teal, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            'AI Extracted ${_aiExtractedSlots.length} Classes & Labs',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: ListView.separated(
                          itemCount: _aiExtractedSlots.length,
                          separatorBuilder: (c, i) => const Divider(height: 8),
                          itemBuilder: (c, index) {
                            final slot = _aiExtractedSlots[index];
                            final isLab = slot['is_lab'] == true;
                            return ListTile(
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              leading: CircleAvatar(
                                radius: 14,
                                backgroundColor: isLab ? Colors.teal : Colors.indigo,
                                child: Text(
                                  '${slot['slot_number'] ?? (index + 1)}',
                                  style: const TextStyle(color: Colors.white, fontSize: 11),
                                ),
                              ),
                              title: Text(
                                '${slot['day_of_week']} • ${slot['subject_name']}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5),
                              ),
                              subtitle: Text(
                                '${slot['start_time']} - ${slot['end_time']} | ${slot['room']} | ${slot['teacher_name']}',
                                style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                              ),
                            );
                          },
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _saveParsedSlots(_aiExtractedSlots),
                        icon: const Icon(Icons.check),
                        label: const Text('Confirm & Save AI Routine'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
