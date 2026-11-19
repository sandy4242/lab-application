// Official Departmental Timetable Data for B. Tech 3rd Semester (Odd Sem. 2026)
// Department of Computer Science & Engineering • WEF 28th July 2026

class SemesterTimetableData {
  static const List<Map<String, String>> sections = [
    {
      'id': 'sec-csea',
      'code': 'A',
      'label': 'III Sem A',
      'fullName': 'B. Tech III Sem A',
      'room': 'Room No. E-307',
      'dept': 'Department of Computer Science & Engineering',
    },
    {
      'id': 'sec-cseb',
      'code': 'B',
      'label': 'III Sem B',
      'fullName': 'B. Tech III Sem B',
      'room': 'Room No. E-306',
      'dept': 'Department of Computer Science & Engineering',
    },
    {
      'id': 'sec-csec',
      'code': 'C',
      'label': 'III Sem C',
      'fullName': 'B. Tech III Sem C',
      'room': 'Room No. E-307',
      'dept': 'Department of Computer Science & Engineering',
    },
    {
      'id': 'sec-cse-aiml',
      'code': 'AI & ML',
      'label': 'III Sem (AI & ML)',
      'fullName': 'B. Tech III Sem (AI & ML)',
      'room': 'Room No. E-315',
      'dept': 'Department of Computer Science & Engineering (AI ML)',
    },
  ];

  static Map<String, dynamic> getSectionData(String sectionId) {
    switch (sectionId) {
      case 'sec-csea':
        return _sectionAData;
      case 'sec-csec':
        return _sectionCData;
      case 'sec-cse-aiml':
        return _sectionAimlData;
      case 'sec-cseb':
      default:
        return _sectionBData;
    }
  }

  // =========================================================================
  // 1. SECTION A (Room E-307)
  // =========================================================================
  static final Map<String, dynamic> _sectionAData = {
    'metadata': {
      'title': 'TIME TABLE FOR THE SESSION AUGUST TO DECEMBER (ODD SEM.) 2026',
      'dept': 'DEPARTMENT OF COMPUTER SCIENCE & ENGINEERING',
      'class': 'B. TECH III SEM A',
      'wef': '28th July 2026',
      'room': 'Room No. E-307',
      'lab_timing_note': 'LAB TIMING: 9:00AM-11:00AM, 11:15AM-1:15PM, 1.15PM-3.15PM, 3.30-5.30PM • VENUE: MP LAB',
    },
    'subjects': [
      {'code': 'MA 205B1', 'name': 'DISCRETE MATHEMATICS', 'faculty': 'DR. AVIJIT PANJA', 'short': 'AP(MATHS)', 'credit': 4},
      {'code': 'CS209A1', 'name': 'DIGITAL DESIGN AND COMPUTER ORGANIZATION', 'faculty': 'DR. TANUSHREE BOSE', 'short': 'TB', 'credit': 4},
      {'code': 'CS 201A1', 'name': 'DATA STRUCTURES', 'faculty': 'DR. BIJOYETA ROY', 'short': 'BR', 'credit': 4},
      {'code': 'CS210A1', 'name': 'OBJECT ORIENTED CONCEPTS & PROGRAMMING USING C++', 'faculty': 'MR. TAWAL K. KOIRALA', 'short': 'TKK', 'credit': 4},
      {
        'code': 'CS 2**A3',
        'name': 'PROGRAM ELECTIVE-I (JAVA / MICROPROCESSOR / E-COMMERCE / DSP / MFML)',
        'faculty': 'DR. VIKASH KR. SINGH / DR. BIJAY RAI / MR. DIBYADEEP BHATTACHARYYA / DR. AMRITA BISWAS / DR. ASIT SAHA',
        'short': 'VKS/BiR/DB/AB/AS',
        'credit': 4,
      },
      {
        'code': 'CS 2**A2 / A8',
        'name': 'OPEN ELECTIVE-I / MINOR / NCC (INDUSTRY VERSION 4.0 / PYTHON)',
        'faculty': 'DR. DHRUBA NINGOMBAM / MRS. RUBAYA KHATUN',
        'short': 'DN/RK',
        'credit': 4,
      },
      {
        'code': 'CS 201A4',
        'name': 'DATA STRUCTURES LAB',
        'faculty': 'DR. BIJOYETA ROY / DR. VIKASH KUMAR SINGH / MR. SHUBHAJIT PANDA',
        'short': 'BR/VKS/SuP',
        'credit': 1,
        'is_lab': true,
      },
      {
        'code': 'CS 205A4',
        'name': 'OBJECT ORIENTED CONCEPTS & PROGRAMMING USING C++ LAB',
        'faculty': 'MR. TAWAL K. KOIRALA / MR. SANJOY GHATAK / DR. YOGESH',
        'short': 'TKK/SGH/YS',
        'credit': 1,
        'is_lab': true,
      },
      {'code': 'CS 201A5', 'name': 'PROJECT BASED LEARNING-1', 'faculty': 'DEPARTMENT FACULTY', 'short': 'PBL', 'credit': 1},
    ],
    'slots': [
      // Monday
      {'day_of_week': 'Monday', 'slot_number': 1, 'start_time': '09:00', 'end_time': '10:00', 'subject_code': 'CS209A1', 'subject_name': 'Digital Design & Computer Org', 'room': 'E-307', 'teacher_name': 'Dr. Tanushree Bose', 'is_lab': false},
      {'day_of_week': 'Monday', 'slot_number': 2, 'start_time': '10:00', 'end_time': '11:00', 'subject_code': 'MA205B1', 'subject_name': 'Discrete Mathematics', 'room': 'E-307', 'teacher_name': 'Dr. Avijit Panja', 'is_lab': false},
      {'day_of_week': 'Monday', 'slot_number': 3, 'start_time': '11:15', 'end_time': '12:15', 'subject_code': 'OPEN EL', 'subject_name': 'Open Elective-I', 'room': 'E-315/E-307', 'teacher_name': 'Dr. Dhruba N. / Mrs. Rubaya', 'is_lab': false},
      {'day_of_week': 'Monday', 'slot_number': 4, 'start_time': '12:15', 'end_time': '13:15', 'subject_code': 'CS 201A1', 'subject_name': 'Data Structures', 'room': 'E-307', 'teacher_name': 'Dr. Bijoyeta Roy', 'is_lab': false},
      {'day_of_week': 'Monday', 'slot_number': 5, 'start_time': '15:30', 'end_time': '17:30', 'subject_code': 'CS 201A4', 'subject_name': 'Data Structures Lab (MP LAB)', 'room': 'MP LAB', 'teacher_name': 'Dr. Bijoyeta Roy / Dr. Vikash Singh', 'is_lab': true},

      // Tuesday
      {'day_of_week': 'Tuesday', 'slot_number': 2, 'start_time': '10:00', 'end_time': '11:00', 'subject_code': 'CS210A1', 'subject_name': 'OOP using C++', 'room': 'E-214', 'teacher_name': 'Mr. Tawal K. Koirala', 'is_lab': false},
      {'day_of_week': 'Tuesday', 'slot_number': 3, 'start_time': '11:15', 'end_time': '13:15', 'subject_code': 'PROGRAM EL', 'subject_name': 'Program Elective-I (2 hrs)', 'room': 'Various', 'teacher_name': 'Faculty Team', 'is_lab': false},
      {'day_of_week': 'Tuesday', 'slot_number': 5, 'start_time': '14:15', 'end_time': '15:15', 'subject_code': 'MA205B1', 'subject_name': 'Discrete Mathematics', 'room': 'E-307', 'teacher_name': 'Dr. Avijit Panja', 'is_lab': false},
      {'day_of_week': 'Tuesday', 'slot_number': 6, 'start_time': '15:30', 'end_time': '16:30', 'subject_code': 'OPEN EL', 'subject_name': 'Open Elective-I', 'room': 'E-315/E-307', 'teacher_name': 'Elective Faculty', 'is_lab': false},
      {'day_of_week': 'Tuesday', 'slot_number': 7, 'start_time': '16:30', 'end_time': '17:30', 'subject_code': 'CS 201A1', 'subject_name': 'Data Structures', 'room': 'E-307', 'teacher_name': 'Dr. Bijoyeta Roy', 'is_lab': false},

      // Wednesday
      {'day_of_week': 'Wednesday', 'slot_number': 1, 'start_time': '09:00', 'end_time': '10:00', 'subject_code': 'MA205B1', 'subject_name': 'Discrete Mathematics', 'room': 'E-307', 'teacher_name': 'Dr. Avijit Panja', 'is_lab': false},
      {'day_of_week': 'Wednesday', 'slot_number': 2, 'start_time': '10:00', 'end_time': '11:00', 'subject_code': 'CS210A1', 'subject_name': 'OOP using C++', 'room': 'E-307', 'teacher_name': 'Mr. Tawal K. Koirala', 'is_lab': false},
      {'day_of_week': 'Wednesday', 'slot_number': 3, 'start_time': '11:15', 'end_time': '12:15', 'subject_code': 'OPEN EL', 'subject_name': 'Open Elective-I', 'room': 'E-315/E-307', 'teacher_name': 'Elective Faculty', 'is_lab': false},
      {'day_of_week': 'Wednesday', 'slot_number': 4, 'start_time': '12:15', 'end_time': '13:15', 'subject_code': 'CS209A1', 'subject_name': 'DDCO', 'room': 'E-307', 'teacher_name': 'Dr. Tanushree Bose', 'is_lab': false},
      {'day_of_week': 'Wednesday', 'slot_number': 5, 'start_time': '14:15', 'end_time': '15:15', 'subject_code': 'CS 201A1', 'subject_name': 'Data Structures', 'room': 'E-307', 'teacher_name': 'Dr. Bijoyeta Roy', 'is_lab': false},
      {'day_of_week': 'Wednesday', 'slot_number': 7, 'start_time': '16:30', 'end_time': '17:30', 'subject_code': 'PROGRAM EL', 'subject_name': 'Program Elective-I', 'room': 'Various', 'teacher_name': 'Faculty Team', 'is_lab': false},

      // Thursday
      {'day_of_week': 'Thursday', 'slot_number': 1, 'start_time': '09:00', 'end_time': '11:00', 'subject_code': 'CS 205A4', 'subject_name': 'OOP C++ Lab (MP LAB)', 'room': 'MP LAB', 'teacher_name': 'Mr. Tawal K. Koirala / Dr. Yogesh', 'is_lab': true},
      {'day_of_week': 'Thursday', 'slot_number': 3, 'start_time': '11:15', 'end_time': '12:15', 'subject_code': 'PROGRAM EL', 'subject_name': 'Program Elective-I', 'room': 'Various', 'teacher_name': 'Faculty Team', 'is_lab': false},
      {'day_of_week': 'Thursday', 'slot_number': 4, 'start_time': '13:15', 'end_time': '14:15', 'subject_code': 'CS209A1', 'subject_name': 'DDCO', 'room': 'E-307', 'teacher_name': 'Dr. Tanushree Bose', 'is_lab': false},
      {'day_of_week': 'Thursday', 'slot_number': 5, 'start_time': '14:15', 'end_time': '15:15', 'subject_code': 'CS210A1', 'subject_name': 'OOP using C++', 'room': 'E-307', 'teacher_name': 'Mr. Tawal K. Koirala', 'is_lab': false},
      {'day_of_week': 'Thursday', 'slot_number': 6, 'start_time': '15:30', 'end_time': '16:30', 'subject_code': 'OPEN EL', 'subject_name': 'Open Elective-I', 'room': 'E-315/E-307', 'teacher_name': 'Elective Faculty', 'is_lab': false},
      {'day_of_week': 'Thursday', 'slot_number': 7, 'start_time': '16:30', 'end_time': '17:30', 'subject_code': 'MA205B1', 'subject_name': 'Discrete Mathematics', 'room': 'E-307', 'teacher_name': 'Dr. Avijit Panja', 'is_lab': false},

      // Friday
      {'day_of_week': 'Friday', 'slot_number': 1, 'start_time': '09:00', 'end_time': '10:00', 'subject_code': 'CS210A1', 'subject_name': 'OOP using C++', 'room': 'E-307', 'teacher_name': 'Mr. Tawal K. Koirala', 'is_lab': false},
      {'day_of_week': 'Friday', 'slot_number': 2, 'start_time': '10:00', 'end_time': '11:00', 'subject_code': 'CS 201A1', 'subject_name': 'Data Structures', 'room': 'E-307', 'teacher_name': 'Dr. Bijoyeta Roy', 'is_lab': false},
      {'day_of_week': 'Friday', 'slot_number': 3, 'start_time': '11:15', 'end_time': '12:15', 'subject_code': 'PROGRAM EL', 'subject_name': 'Program Elective-I', 'room': 'Various', 'teacher_name': 'Faculty Team', 'is_lab': false},
      {'day_of_week': 'Friday', 'slot_number': 4, 'start_time': '12:15', 'end_time': '13:15', 'subject_code': 'CS209A1', 'subject_name': 'DDCO', 'room': 'E-307', 'teacher_name': 'Dr. Tanushree Bose', 'is_lab': false},
    ],
  };

  // =========================================================================
  // 2. SECTION B (Room E-306)
  // =========================================================================
  static final Map<String, dynamic> _sectionBData = {
    'metadata': {
      'title': 'TIME TABLE FOR THE SESSION AUGUST TO DECEMBER (ODD SEM.) 2026',
      'dept': 'DEPARTMENT OF COMPUTER SCIENCE & ENGINEERING',
      'class': 'B. TECH III SEM B',
      'wef': '28th July 2026',
      'room': 'Room No. E-306',
      'lab_timing_note': 'LAB TIMING: 9:00AM-11:00AM, 11:15AM-1:15PM, 1.15PM-3.15PM, 3.30-5.30PM • VENUE: MP LAB',
    },
    'subjects': [
      {'code': 'MA 205B1', 'name': 'DISCRETE MATHEMATICS', 'faculty': 'DR. ASIT SAHA', 'short': 'AS(MATHS)', 'credit': 4},
      {'code': 'CS209A1', 'name': 'DIGITAL DESIGN AND COMPUTER ORGANIZATION', 'faculty': 'DR. SAMARENDRA NATH SUR', 'short': 'SNS', 'credit': 4},
      {'code': 'CS 201A1', 'name': 'DATA STRUCTURES', 'faculty': 'DR. BIJOYETA ROY', 'short': 'BR', 'credit': 4},
      {'code': 'CS210A1', 'name': 'OBJECT ORIENTED CONCEPTS & PROGRAMMING USING C++', 'faculty': 'MR. TAWAL K. KOIRALA', 'short': 'TKK', 'credit': 4},
      {
        'code': 'CS 2**A3',
        'name': 'PROGRAM ELECTIVE-I (JAVA / MICROPROCESSOR / E-COMMERCE / DSP / MFML)',
        'faculty': 'DR. VIKASH KR. SINGH / DR. BIJAY RAI / MR. DIBYADEEP BHATTACHARYYA / DR. AMRITA BISWAS / DR. ASIT SAHA',
        'short': 'VKS/BiR/DB/AB/AS',
        'credit': 4,
      },
      {
        'code': 'CS 2**A2 / A8',
        'name': 'OPEN ELECTIVE-I / MINOR / NCC (INDUSTRY VERSION 4.0 / PYTHON)',
        'faculty': 'DR. DHRUBA NINGOMBAM / MRS. RUBAYA KHATUN',
        'short': 'DN/RK',
        'credit': 4,
      },
      {
        'code': 'CS 201A4',
        'name': 'DATA STRUCTURES LAB',
        'faculty': 'DR. BIJOYETA ROY / MR. SHUBHAM RANJAN / DR. ANIRBAN SENGUPTA',
        'short': 'BR/SuR/ASG',
        'credit': 1,
        'is_lab': true,
      },
      {
        'code': 'CS 205A4',
        'name': 'OBJECT ORIENTED CONCEPTS & PROGRAMMING USING C++ LAB',
        'faculty': 'MR. TAWAL K. KOIRALA / MR. DIBYADEEP BHATTACHARYYA / DR. YOGESH',
        'short': 'TKK/DB/YS',
        'credit': 1,
        'is_lab': true,
      },
      {'code': 'CS 201A5', 'name': 'PROJECT BASED LEARNING-1', 'faculty': 'DEPARTMENT FACULTY', 'short': 'PBL', 'credit': 1},
    ],
    'slots': [
      // Monday
      {'day_of_week': 'Monday', 'slot_number': 1, 'start_time': '09:00', 'end_time': '10:00', 'subject_code': 'CS 201A1', 'subject_name': 'Data Structures', 'room': 'E-306', 'teacher_name': 'Dr. Bijoyeta Roy', 'is_lab': false},
      {'day_of_week': 'Monday', 'slot_number': 2, 'start_time': '10:00', 'end_time': '11:00', 'subject_code': 'CS210A1', 'subject_name': 'OOP using C++', 'room': 'E-306', 'teacher_name': 'Mr. Tawal K. Koirala', 'is_lab': false},
      {'day_of_week': 'Monday', 'slot_number': 3, 'start_time': '11:15', 'end_time': '12:15', 'subject_code': 'OPEN EL', 'subject_name': 'Open Elective-I', 'room': 'E-315/E-307', 'teacher_name': 'Dr. Dhruba N. / Mrs. Rubaya', 'is_lab': false},
      {'day_of_week': 'Monday', 'slot_number': 4, 'start_time': '12:15', 'end_time': '13:15', 'subject_code': 'CS209A1', 'subject_name': 'DDCO', 'room': 'E-306', 'teacher_name': 'Dr. Samarendra Nath Sur', 'is_lab': false},
      {'day_of_week': 'Monday', 'slot_number': 7, 'start_time': '16:30', 'end_time': '17:30', 'subject_code': 'MA205B1', 'subject_name': 'Discrete Mathematics', 'room': 'E-306', 'teacher_name': 'Dr. Asit Saha', 'is_lab': false},

      // Tuesday
      {'day_of_week': 'Tuesday', 'slot_number': 1, 'start_time': '09:00', 'end_time': '11:00', 'subject_code': 'CS 201A4', 'subject_name': 'Data Structures Lab (MP LAB)', 'room': 'MP LAB', 'teacher_name': 'Dr. Bijoyeta Roy / Mr. Shubham Ranjan', 'is_lab': true},
      {'day_of_week': 'Tuesday', 'slot_number': 3, 'start_time': '11:15', 'end_time': '12:15', 'subject_code': 'CS209A1', 'subject_name': 'DDCO', 'room': 'E-201', 'teacher_name': 'Dr. Samarendra Nath Sur', 'is_lab': false},
      {'day_of_week': 'Tuesday', 'slot_number': 4, 'start_time': '12:15', 'end_time': '13:15', 'subject_code': 'PROGRAM EL', 'subject_name': 'Program Elective-I', 'room': 'Various', 'teacher_name': 'Faculty Team', 'is_lab': false},
      {'day_of_week': 'Tuesday', 'slot_number': 5, 'start_time': '14:15', 'end_time': '15:15', 'subject_code': 'CS 201A1', 'subject_name': 'Data Structures', 'room': 'E-306', 'teacher_name': 'Dr. Bijoyeta Roy', 'is_lab': false},
      {'day_of_week': 'Tuesday', 'slot_number': 6, 'start_time': '15:30', 'end_time': '16:30', 'subject_code': 'OPEN EL', 'subject_name': 'Open Elective-I', 'room': 'E-315/E-307', 'teacher_name': 'Elective Faculty', 'is_lab': false},
      {'day_of_week': 'Tuesday', 'slot_number': 7, 'start_time': '16:30', 'end_time': '17:30', 'subject_code': 'CS210A1', 'subject_name': 'OOP using C++', 'room': 'E-306', 'teacher_name': 'Mr. Tawal K. Koirala', 'is_lab': false},

      // Wednesday
      {'day_of_week': 'Wednesday', 'slot_number': 1, 'start_time': '09:00', 'end_time': '10:00', 'subject_code': 'MA205B1', 'subject_name': 'Discrete Mathematics', 'room': 'E-306', 'teacher_name': 'Dr. Asit Saha', 'is_lab': false},
      {'day_of_week': 'Wednesday', 'slot_number': 2, 'start_time': '10:00', 'end_time': '11:00', 'subject_code': 'CS 201A1', 'subject_name': 'Data Structures', 'room': 'E-306', 'teacher_name': 'Dr. Bijoyeta Roy', 'is_lab': false},
      {'day_of_week': 'Wednesday', 'slot_number': 3, 'start_time': '11:15', 'end_time': '12:15', 'subject_code': 'OPEN EL', 'subject_name': 'Open Elective-I', 'room': 'E-315/E-307', 'teacher_name': 'Elective Faculty', 'is_lab': false},
      {'day_of_week': 'Wednesday', 'slot_number': 4, 'start_time': '12:15', 'end_time': '13:15', 'subject_code': 'CS210A1', 'subject_name': 'OOP using C++', 'room': 'E-306', 'teacher_name': 'Mr. Tawal K. Koirala', 'is_lab': false},
      {'day_of_week': 'Wednesday', 'slot_number': 7, 'start_time': '16:30', 'end_time': '17:30', 'subject_code': 'PROGRAM EL', 'subject_name': 'Program Elective-I', 'room': 'Various', 'teacher_name': 'Faculty Team', 'is_lab': false},

      // Thursday
      {'day_of_week': 'Thursday', 'slot_number': 3, 'start_time': '11:15', 'end_time': '12:15', 'subject_code': 'PROGRAM EL', 'subject_name': 'Program Elective-I', 'room': 'Various', 'teacher_name': 'Faculty Team', 'is_lab': false},
      {'day_of_week': 'Thursday', 'slot_number': 4, 'start_time': '13:15', 'end_time': '14:15', 'subject_code': 'CS209A1', 'subject_name': 'DDCO', 'room': 'E-306', 'teacher_name': 'Dr. Samarendra Nath Sur', 'is_lab': false},
      {'day_of_week': 'Thursday', 'slot_number': 5, 'start_time': '14:15', 'end_time': '15:15', 'subject_code': 'CS 201A1', 'subject_name': 'Data Structures', 'room': 'E-306', 'teacher_name': 'Dr. Bijoyeta Roy', 'is_lab': false},
      {'day_of_week': 'Thursday', 'slot_number': 6, 'start_time': '15:30', 'end_time': '16:30', 'subject_code': 'OPEN EL', 'subject_name': 'Open Elective-I', 'room': 'E-315/E-307', 'teacher_name': 'Elective Faculty', 'is_lab': false},
      {'day_of_week': 'Thursday', 'slot_number': 7, 'start_time': '16:30', 'end_time': '17:30', 'subject_code': 'MA205B1', 'subject_name': 'Discrete Mathematics', 'room': 'E-306', 'teacher_name': 'Dr. Asit Saha', 'is_lab': false},

      // Friday
      {'day_of_week': 'Friday', 'slot_number': 1, 'start_time': '09:00', 'end_time': '10:00', 'subject_code': 'CS209A1', 'subject_name': 'DDCO', 'room': 'E-306', 'teacher_name': 'Dr. Samarendra Nath Sur', 'is_lab': false},
      {'day_of_week': 'Friday', 'slot_number': 2, 'start_time': '10:00', 'end_time': '11:00', 'subject_code': 'MA205B1', 'subject_name': 'Discrete Mathematics', 'room': 'E-306', 'teacher_name': 'Dr. Asit Saha', 'is_lab': false},
      {'day_of_week': 'Friday', 'slot_number': 3, 'start_time': '11:15', 'end_time': '12:15', 'subject_code': 'PROGRAM EL', 'subject_name': 'Program Elective-I', 'room': 'Various', 'teacher_name': 'Faculty Team', 'is_lab': false},
      {'day_of_week': 'Friday', 'slot_number': 4, 'start_time': '12:15', 'end_time': '13:15', 'subject_code': 'CS210A1', 'subject_name': 'OOP using C++', 'room': 'E-306', 'teacher_name': 'Mr. Tawal K. Koirala', 'is_lab': false},
      {'day_of_week': 'Friday', 'slot_number': 5, 'start_time': '15:30', 'end_time': '17:30', 'subject_code': 'CS 205A4', 'subject_name': 'OOP C++ Lab (MP LAB)', 'room': 'MP LAB', 'teacher_name': 'Mr. Tawal K. Koirala / Dr. Yogesh', 'is_lab': true},
    ],
  };

  // =========================================================================
  // 3. SECTION C (Room E-307)
  // =========================================================================
  static final Map<String, dynamic> _sectionCData = {
    'metadata': {
      'title': 'TIME TABLE FOR THE SESSION AUGUST TO DECEMBER (ODD SEM.) 2026',
      'dept': 'DEPARTMENT OF COMPUTER SCIENCE & ENGINEERING',
      'class': 'B. TECH III SEM C',
      'wef': '28th July 2026',
      'room': 'Room No. E-307',
      'lab_timing_note': 'LAB TIMING: 9:00AM-11:00AM, 11:15AM-1:15PM, 1.15PM-3.15PM, 3.30-5.30PM • VENUE: MP LAB',
    },
    'subjects': [
      {'code': 'MA 205B1', 'name': 'DISCRETE MATHEMATICS', 'faculty': 'DR. BIKASH THAKURI', 'short': 'BT(MATHS)', 'credit': 4},
      {'code': 'CS209A1', 'name': 'DIGITAL DESIGN AND COMPUTER ORGANIZATION', 'faculty': 'DR. YOGESH', 'short': 'YS', 'credit': 4},
      {'code': 'CS 201A1', 'name': 'DATA STRUCTURES', 'faculty': 'DR. JHUMA SUNUWAR', 'short': 'JS', 'credit': 4},
      {'code': 'CS210A1', 'name': 'OBJECT ORIENTED CONCEPTS & PROGRAMMING USING C++', 'faculty': 'MRS. MINAKSHI ROY', 'short': 'MR', 'credit': 4},
      {
        'code': 'CS 2**A3',
        'name': 'PROGRAM ELECTIVE-I (JAVA / MICROPROCESSOR / E-COMMERCE / DSP / MFML)',
        'faculty': 'DR. VIKASH KR. SINGH / DR. BIJAY RAI / MR. DIBYADEEP BHATTACHARYYA / DR. AMRITA BISWAS / DR. ASIT SAHA',
        'short': 'VKS/BiR/DB/AB/AS',
        'credit': 4,
      },
      {
        'code': 'CS 2**A2 / A8',
        'name': 'OPEN ELECTIVE-I / MINOR / NCC (INDUSTRY VERSION 4.0 / PYTHON)',
        'faculty': 'DR. DHRUBA NINGOMBAM / MRS. RUBAYA KHATUN',
        'short': 'DN/RK',
        'credit': 4,
      },
      {
        'code': 'CS 201A4',
        'name': 'DATA STRUCTURES LAB',
        'faculty': 'DR. JHUMA SUNUWAR / DR. VIKASH KUMAR SINGH / MR. BIRAJ UPADHYAYA',
        'short': 'JS/VKS/BU',
        'credit': 1,
        'is_lab': true,
      },
      {
        'code': 'CS 205A4',
        'name': 'OBJECT ORIENTED CONCEPTS & PROGRAMMING USING C++ LAB',
        'faculty': 'MRS. MINAKSHI ROY / DR. SANJOY GHATAK / DR. YOGESH',
        'short': 'MR/SGH/YS',
        'credit': 1,
        'is_lab': true,
      },
      {'code': 'CS 201A5', 'name': 'PROJECT BASED LEARNING-1', 'faculty': 'DEPARTMENT FACULTY', 'short': 'PBL', 'credit': 1},
    ],
    'slots': [
      // Monday
      {'day_of_week': 'Monday', 'slot_number': 1, 'start_time': '09:00', 'end_time': '11:00', 'subject_code': 'CS 201A4', 'subject_name': 'Data Structures Lab (MP LAB)', 'room': 'MP LAB', 'teacher_name': 'Dr. Jhuma Sunuwar / Mr. Biraj Upadhyaya', 'is_lab': true},
      {'day_of_week': 'Monday', 'slot_number': 3, 'start_time': '11:15', 'end_time': '12:15', 'subject_code': 'OPEN EL', 'subject_name': 'Open Elective-I', 'room': 'E-315/E-307', 'teacher_name': 'Dr. Dhruba N. / Mrs. Rubaya', 'is_lab': false},
      {'day_of_week': 'Monday', 'slot_number': 4, 'start_time': '13:15', 'end_time': '14:15', 'subject_code': 'MA205B1', 'subject_name': 'Discrete Mathematics', 'room': 'E-307', 'teacher_name': 'Dr. Bikash Thakuri', 'is_lab': false},
      {'day_of_week': 'Monday', 'slot_number': 5, 'start_time': '14:15', 'end_time': '15:15', 'subject_code': 'CS210A1', 'subject_name': 'OOP using C++', 'room': 'E-307', 'teacher_name': 'Mrs. Minakshi Roy', 'is_lab': false},
      {'day_of_week': 'Monday', 'slot_number': 6, 'start_time': '15:30', 'end_time': '16:30', 'subject_code': 'CS209A1', 'subject_name': 'DDCO', 'room': 'E-307', 'teacher_name': 'Dr. Yogesh', 'is_lab': false},
      {'day_of_week': 'Monday', 'slot_number': 7, 'start_time': '16:30', 'end_time': '17:30', 'subject_code': 'CS 201A1', 'subject_name': 'Data Structures', 'room': 'E-307', 'teacher_name': 'Dr. Jhuma Sunuwar', 'is_lab': false},

      // Tuesday
      {'day_of_week': 'Tuesday', 'slot_number': 1, 'start_time': '09:00', 'end_time': '10:00', 'subject_code': 'CS209A1', 'subject_name': 'DDCO', 'room': 'E-307', 'teacher_name': 'Dr. Yogesh', 'is_lab': false},
      {'day_of_week': 'Tuesday', 'slot_number': 3, 'start_time': '11:15', 'end_time': '12:15', 'subject_code': 'MA205B1', 'subject_name': 'Discrete Mathematics', 'room': 'E-307', 'teacher_name': 'Dr. Bikash Thakuri', 'is_lab': false},
      {'day_of_week': 'Tuesday', 'slot_number': 4, 'start_time': '12:15', 'end_time': '13:15', 'subject_code': 'PROGRAM EL', 'subject_name': 'Program Elective-I', 'room': 'Various', 'teacher_name': 'Faculty Team', 'is_lab': false},
      {'day_of_week': 'Tuesday', 'slot_number': 6, 'start_time': '15:30', 'end_time': '16:30', 'subject_code': 'OPEN EL', 'subject_name': 'Open Elective-I', 'room': 'E-315/E-307', 'teacher_name': 'Elective Faculty', 'is_lab': false},
      {'day_of_week': 'Tuesday', 'slot_number': 7, 'start_time': '16:30', 'end_time': '17:30', 'subject_code': 'CS 201A1', 'subject_name': 'Data Structures', 'room': 'E-214', 'teacher_name': 'Dr. Jhuma Sunuwar', 'is_lab': false},

      // Wednesday
      {'day_of_week': 'Wednesday', 'slot_number': 1, 'start_time': '09:00', 'end_time': '11:00', 'subject_code': 'CS 205A4', 'subject_name': 'OOP C++ Lab (MP LAB)', 'room': 'MP LAB', 'teacher_name': 'Mrs. Minakshi Roy / Dr. Yogesh', 'is_lab': true},
      {'day_of_week': 'Wednesday', 'slot_number': 3, 'start_time': '11:15', 'end_time': '12:15', 'subject_code': 'OPEN EL', 'subject_name': 'Open Elective-I', 'room': 'E-315/E-307', 'teacher_name': 'Elective Faculty', 'is_lab': false},
      {'day_of_week': 'Wednesday', 'slot_number': 4, 'start_time': '13:15', 'end_time': '14:15', 'subject_code': 'CS210A1', 'subject_name': 'OOP using C++', 'room': 'E-307', 'teacher_name': 'Mrs. Minakshi Roy', 'is_lab': false},
      {'day_of_week': 'Wednesday', 'slot_number': 6, 'start_time': '15:30', 'end_time': '16:30', 'subject_code': 'CS 201A1', 'subject_name': 'Data Structures', 'room': 'E-307', 'teacher_name': 'Dr. Jhuma Sunuwar', 'is_lab': false},
      {'day_of_week': 'Wednesday', 'slot_number': 7, 'start_time': '16:30', 'end_time': '17:30', 'subject_code': 'PROGRAM EL', 'subject_name': 'Program Elective-I', 'room': 'Various', 'teacher_name': 'Faculty Team', 'is_lab': false},

      // Thursday
      {'day_of_week': 'Thursday', 'slot_number': 1, 'start_time': '09:00', 'end_time': '10:00', 'subject_code': 'CS210A1', 'subject_name': 'OOP using C++', 'room': 'E-307', 'teacher_name': 'Mrs. Minakshi Roy', 'is_lab': false},
      {'day_of_week': 'Thursday', 'slot_number': 2, 'start_time': '10:00', 'end_time': '11:00', 'subject_code': 'MA205B1', 'subject_name': 'Discrete Mathematics', 'room': 'E-307', 'teacher_name': 'Dr. Bikash Thakuri', 'is_lab': false},
      {'day_of_week': 'Thursday', 'slot_number': 3, 'start_time': '11:15', 'end_time': '12:15', 'subject_code': 'PROGRAM EL', 'subject_name': 'Program Elective-I', 'room': 'Various', 'teacher_name': 'Faculty Team', 'is_lab': false},
      {'day_of_week': 'Thursday', 'slot_number': 4, 'start_time': '12:15', 'end_time': '13:15', 'subject_code': 'CS209A1', 'subject_name': 'DDCO', 'room': 'E-307', 'teacher_name': 'Dr. Yogesh', 'is_lab': false},
      {'day_of_week': 'Thursday', 'slot_number': 6, 'start_time': '15:30', 'end_time': '16:30', 'subject_code': 'OPEN EL', 'subject_name': 'Open Elective-I', 'room': 'E-315/E-307', 'teacher_name': 'Elective Faculty', 'is_lab': false},

      // Friday
      {'day_of_week': 'Friday', 'slot_number': 3, 'start_time': '11:15', 'end_time': '12:15', 'subject_code': 'PROGRAM EL', 'subject_name': 'Program Elective-I', 'room': 'Various', 'teacher_name': 'Faculty Team', 'is_lab': false},
      {'day_of_week': 'Friday', 'slot_number': 4, 'start_time': '13:15', 'end_time': '14:15', 'subject_code': 'CS209A1', 'subject_name': 'DDCO', 'room': 'E-307', 'teacher_name': 'Dr. Yogesh', 'is_lab': false},
      {'day_of_week': 'Friday', 'slot_number': 5, 'start_time': '14:15', 'end_time': '15:15', 'subject_code': 'CS 201A1', 'subject_name': 'Data Structures', 'room': 'E-307', 'teacher_name': 'Dr. Jhuma Sunuwar', 'is_lab': false},
      {'day_of_week': 'Friday', 'slot_number': 6, 'start_time': '15:30', 'end_time': '16:30', 'subject_code': 'MA205B1', 'subject_name': 'Discrete Mathematics', 'room': 'E-307', 'teacher_name': 'Dr. Bikash Thakuri', 'is_lab': false},
      {'day_of_week': 'Friday', 'slot_number': 7, 'start_time': '16:30', 'end_time': '17:30', 'subject_code': 'CS210A1', 'subject_name': 'OOP using C++', 'room': 'E-307', 'teacher_name': 'Mrs. Minakshi Roy', 'is_lab': false},
    ],
  };

  // =========================================================================
  // 4. SECTION AI & ML (Room E-315)
  // =========================================================================
  static final Map<String, dynamic> _sectionAimlData = {
    'metadata': {
      'title': 'TIME TABLE FOR THE SESSION AUGUST TO DECEMBER (ODD SEM.) 2026',
      'dept': 'DEPARTMENT OF COMPUTER SCIENCE & ENGINEERING (AI ML)',
      'class': 'B. TECH III SEM (AI & ML)',
      'wef': '28th July 2026',
      'room': 'Room No. E-315',
      'lab_timing_note': 'LAB TIMING: 9:00AM-11:00AM, 11:15AM-1:15PM, 1.15PM-3.15PM, 3.30-5.30PM • VENUE: MP LAB',
    },
    'subjects': [
      {'code': 'MA 205B1', 'name': 'DISCRETE MATHEMATICS', 'faculty': 'DR. BAPAN DAS', 'short': 'BD(MATHS)', 'credit': 4},
      {'code': 'CSML212A1', 'name': 'MACHINE LEARNING', 'faculty': 'MR. SHUBHAJIT PANDA', 'short': 'SuP', 'credit': 4},
      {'code': 'CSML 201A1', 'name': 'DATA STRUCTURES', 'faculty': 'MR. SHUBHAM RANJAN', 'short': 'SuR', 'credit': 4},
      {'code': 'CSML202B1', 'name': 'OBJECT ORIENTED CONCEPTS & PROGRAMMING USING C++', 'faculty': 'MR. ISH NATH JHA', 'short': 'INJ', 'credit': 4},
      {
        'code': 'CSML 2**A3',
        'name': 'PROGRAM ELECTIVE-I (JAVA / MICROPROCESSOR / E-COMMERCE / DSP / MFML)',
        'faculty': 'DR. VIKASH KR. SINGH / DR. BIJAY RAI / MR. DIBYADEEP BHATTACHARYYA / DR. AMRITA BISWAS / DR. ASIT SAHA',
        'short': 'VKS/BiR/DB/AB/AS',
        'credit': 4,
      },
      {
        'code': 'CSML 2**A2 / CS 2**A8',
        'name': 'OPEN ELECTIVE-I / MINOR / NCC (INDUSTRY VERSION 4.0 / PYTHON)',
        'faculty': 'DR. DHRUBA NINGOMBAM / MRS. RUBAYA KHATUN',
        'short': 'DN/RK',
        'credit': 4,
      },
      {
        'code': 'CSML 201A4',
        'name': 'DATA STRUCTURES LAB',
        'faculty': 'MR. SHUBHAM RANJAN / MR. BIRAJ UPADHYAYA / MR. SHUBHAJIT PANDA',
        'short': 'SuR/BU/SuP',
        'credit': 1,
        'is_lab': true,
      },
      {
        'code': 'CSML 202A4',
        'name': 'OBJECT ORIENTED CONCEPTS & PROGRAMMING USING C++ LAB',
        'faculty': 'MR. ISH NATH JHA / MR. DIBYADEEP BHATTACHARYYA / DR. ABHISHEK KUMAR',
        'short': 'INJ/DB/AK',
        'credit': 1,
        'is_lab': true,
      },
      {'code': 'CSML201A5', 'name': 'PROJECT BASED LEARNING-1', 'faculty': 'DEPARTMENT FACULTY', 'short': 'PBL', 'credit': 1},
    ],
    'slots': [
      // Monday
      {'day_of_week': 'Monday', 'slot_number': 1, 'start_time': '09:00', 'end_time': '10:00', 'subject_code': 'CSML 201A1', 'subject_name': 'Data Structures', 'room': 'E-315', 'teacher_name': 'Mr. Shubham Ranjan', 'is_lab': false},
      {'day_of_week': 'Monday', 'slot_number': 2, 'start_time': '10:00', 'end_time': '11:00', 'subject_code': 'MA205B1', 'subject_name': 'Discrete Mathematics', 'room': 'E-315', 'teacher_name': 'Dr. Bapan Das', 'is_lab': false},
      {'day_of_week': 'Monday', 'slot_number': 3, 'start_time': '11:15', 'end_time': '12:15', 'subject_code': 'OPEN EL', 'subject_name': 'Open Elective-I', 'room': 'E-315/E-307', 'teacher_name': 'Dr. Dhruba N. / Mrs. Rubaya', 'is_lab': false},
      {'day_of_week': 'Monday', 'slot_number': 4, 'start_time': '12:15', 'end_time': '13:15', 'subject_code': 'CSML212A1', 'subject_name': 'Machine Learning', 'room': 'E-315', 'teacher_name': 'Mr. Shubhajit Panda', 'is_lab': false},
      {'day_of_week': 'Monday', 'slot_number': 6, 'start_time': '15:30', 'end_time': '16:30', 'subject_code': 'CSML202B1', 'subject_name': 'OOP using C++', 'room': 'E-315', 'teacher_name': 'Mr. Ish Nath Jha', 'is_lab': false},

      // Tuesday
      {'day_of_week': 'Tuesday', 'slot_number': 2, 'start_time': '10:00', 'end_time': '11:00', 'subject_code': 'CSML202B1', 'subject_name': 'OOP using C++', 'room': 'E-315', 'teacher_name': 'Mr. Ish Nath Jha', 'is_lab': false},
      {'day_of_week': 'Tuesday', 'slot_number': 3, 'start_time': '11:15', 'end_time': '12:15', 'subject_code': 'CSML212A1', 'subject_name': 'Machine Learning', 'room': 'E-315', 'teacher_name': 'Mr. Shubhajit Panda', 'is_lab': false},
      {'day_of_week': 'Tuesday', 'slot_number': 4, 'start_time': '12:15', 'end_time': '13:15', 'subject_code': 'PROGRAM EL', 'subject_name': 'Program Elective-I', 'room': 'Various', 'teacher_name': 'Faculty Team', 'is_lab': false},
      {'day_of_week': 'Tuesday', 'slot_number': 5, 'start_time': '14:15', 'end_time': '15:15', 'subject_code': 'MA205B1', 'subject_name': 'Discrete Mathematics', 'room': 'E-315', 'teacher_name': 'Dr. Bapan Das', 'is_lab': false},
      {'day_of_week': 'Tuesday', 'slot_number': 6, 'start_time': '15:30', 'end_time': '16:30', 'subject_code': 'OPEN EL', 'subject_name': 'Open Elective-I', 'room': 'E-315/E-307', 'teacher_name': 'Elective Faculty', 'is_lab': false},
      {'day_of_week': 'Tuesday', 'slot_number': 7, 'start_time': '16:30', 'end_time': '17:30', 'subject_code': 'CSML 201A1', 'subject_name': 'Data Structures', 'room': 'E-315', 'teacher_name': 'Mr. Shubham Ranjan', 'is_lab': false},

      // Wednesday
      {'day_of_week': 'Wednesday', 'slot_number': 1, 'start_time': '09:00', 'end_time': '10:00', 'subject_code': 'MA205B1', 'subject_name': 'Discrete Mathematics', 'room': 'E-315', 'teacher_name': 'Dr. Bapan Das', 'is_lab': false},
      {'day_of_week': 'Wednesday', 'slot_number': 2, 'start_time': '10:00', 'end_time': '11:00', 'subject_code': 'CSML212A1', 'subject_name': 'Machine Learning', 'room': 'E-315', 'teacher_name': 'Mr. Shubhajit Panda', 'is_lab': false},
      {'day_of_week': 'Wednesday', 'slot_number': 3, 'start_time': '11:15', 'end_time': '12:15', 'subject_code': 'OPEN EL', 'subject_name': 'Open Elective-I', 'room': 'E-315/E-307', 'teacher_name': 'Elective Faculty', 'is_lab': false},
      {'day_of_week': 'Wednesday', 'slot_number': 4, 'start_time': '13:15', 'end_time': '15:15', 'subject_code': 'CSML 202A4', 'subject_name': 'OOP C++ Lab (MP LAB)', 'room': 'MP LAB', 'teacher_name': 'Mr. Ish Nath Jha / Dr. Abhishek Kumar', 'is_lab': true},
      {'day_of_week': 'Wednesday', 'slot_number': 6, 'start_time': '15:30', 'end_time': '16:30', 'subject_code': 'CSML202B1', 'subject_name': 'OOP using C++', 'room': 'E-315', 'teacher_name': 'Mr. Ish Nath Jha', 'is_lab': false},
      {'day_of_week': 'Wednesday', 'slot_number': 7, 'start_time': '16:30', 'end_time': '17:30', 'subject_code': 'PROGRAM EL', 'subject_name': 'Program Elective-I', 'room': 'Various', 'teacher_name': 'Faculty Team', 'is_lab': false},

      // Thursday
      {'day_of_week': 'Thursday', 'slot_number': 3, 'start_time': '11:15', 'end_time': '12:15', 'subject_code': 'PROGRAM EL', 'subject_name': 'Program Elective-I', 'room': 'Various', 'teacher_name': 'Faculty Team', 'is_lab': false},
      {'day_of_week': 'Thursday', 'slot_number': 4, 'start_time': '13:15', 'end_time': '14:15', 'subject_code': 'MA205B1', 'subject_name': 'Discrete Mathematics', 'room': 'E-315', 'teacher_name': 'Dr. Bapan Das', 'is_lab': false},
      {'day_of_week': 'Thursday', 'slot_number': 5, 'start_time': '14:15', 'end_time': '15:15', 'subject_code': 'CSML 201A1', 'subject_name': 'Data Structures', 'room': 'E-315', 'teacher_name': 'Mr. Shubham Ranjan', 'is_lab': false},
      {'day_of_week': 'Thursday', 'slot_number': 6, 'start_time': '15:30', 'end_time': '16:30', 'subject_code': 'OPEN EL', 'subject_name': 'Open Elective-I', 'room': 'E-315/E-307', 'teacher_name': 'Elective Faculty', 'is_lab': false},
      {'day_of_week': 'Thursday', 'slot_number': 7, 'start_time': '16:30', 'end_time': '17:30', 'subject_code': 'CSML202B1', 'subject_name': 'OOP using C++', 'room': 'E-315', 'teacher_name': 'Mr. Ish Nath Jha', 'is_lab': false},

      // Friday
      {'day_of_week': 'Friday', 'slot_number': 1, 'start_time': '09:00', 'end_time': '10:00', 'subject_code': 'CSML212A1', 'subject_name': 'Machine Learning', 'room': 'E-315', 'teacher_name': 'Mr. Shubhajit Panda', 'is_lab': false},
      {'day_of_week': 'Friday', 'slot_number': 2, 'start_time': '10:00', 'end_time': '11:00', 'subject_code': 'CSML 201A1', 'subject_name': 'Data Structures', 'room': 'E-315', 'teacher_name': 'Mr. Shubham Ranjan', 'is_lab': false},
      {'day_of_week': 'Friday', 'slot_number': 3, 'start_time': '11:15', 'end_time': '12:15', 'subject_code': 'PROGRAM EL', 'subject_name': 'Program Elective-I', 'room': 'Various', 'teacher_name': 'Faculty Team', 'is_lab': false},
      {'day_of_week': 'Friday', 'slot_number': 4, 'start_time': '13:15', 'end_time': '15:15', 'subject_code': 'CSML201A4', 'subject_name': 'Data Structures Lab (MP LAB)', 'room': 'MP LAB', 'teacher_name': 'Mr. Shubham Ranjan / Mr. Biraj Upadhyaya', 'is_lab': true},
    ],
  };

  // Elective Room Allocation notes
  static const List<Map<String, String>> electiveRoomAllocations = [
    {
      'type': 'PROGRAM ELECTIVE-I',
      'course': 'Java Programming',
      'code': 'CS201A3 / CSIC201A3 / CSML201B3 (VKS)',
      'venue': 'MP LAB',
    },
    {
      'type': 'PROGRAM ELECTIVE-I',
      'course': 'Microprocessors and Peripheral Devices',
      'code': 'CS228A3 / CSIC206A3 / CSML206A3 (BiR)',
      'venue': 'PG & R LAB-I',
    },
    {
      'type': 'PROGRAM ELECTIVE-I',
      'course': 'E-Commerce',
      'code': 'CS225A3 / CSML209A3 / CSIC228A3 (DB)',
      'venue': 'ROOM E-306',
    },
    {
      'type': 'PROGRAM ELECTIVE-I',
      'course': 'Digital Signal Processing (DSP)',
      'code': 'CS226A3 / CSML210A3 / CSIC229A3 (AB)',
      'venue': 'ROOM E-307',
    },
    {
      'type': 'PROGRAM ELECTIVE-I',
      'course': 'Mathematical Foundation for Machine Learning (MFML)',
      'code': 'CS227A3 / CSIC230A3 / CSML211A3 (AS)',
      'venue': 'ROOM E-315',
    },
    {
      'type': 'OPEN ELECTIVE-I',
      'course': 'Industry Version 4.0',
      'code': 'CS201A2 (DN)',
      'venue': 'ROOM E-315 / E-306',
    },
    {
      'type': 'OPEN ELECTIVE-I',
      'course': 'Python Programming',
      'code': 'CS203A2 (RK)',
      'venue': 'ROOM E-307',
    },
  ];
}
