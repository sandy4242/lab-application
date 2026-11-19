import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'semester_timetable_data.dart';

class MockDataService {
  static final MockDataService _instance = MockDataService._internal();
  factory MockDataService() => _instance;
  MockDataService._internal() {
    _initSampleData();
  }

  // =========================================================================
  // 1. STATIC USER ACCOUNTS & PROFILES
  // =========================================================================
  final List<Map<String, dynamic>> _users = [
    {
      'id': 'user-student-1',
      'email': 'student@relab.com',
      'password': 'password123',
      'name': 'Rahul Sharma',
      'phone': '9876543210',
      'role': 'student',
      'students': {
        'registration_number': '21BCE1001',
        'teacher_guardian_id': 'user-tg-1',
        'sections': {
          'id': 'sec-cseb',
          'name': 'B',
          'semester': 5,
          'departments': {
            'id': 'dept-cse',
            'name': 'Computer Science & Engineering',
            'code': 'CSE',
          },
        },
      },
    },
    {
      'id': 'user-student-2',
      'email': 'priya.nair@relab.com',
      'password': 'password123',
      'name': 'Priya Nair',
      'phone': '9876543211',
      'role': 'student',
      'students': {
        'registration_number': '21BCE1042',
        'teacher_guardian_id': 'user-tg-1',
        'sections': {
          'id': 'sec-cseb',
          'name': 'B',
          'semester': 5,
          'departments': {
            'id': 'dept-cse',
            'name': 'Computer Science & Engineering',
            'code': 'CSE',
          },
        },
      },
    },
    {
      'id': 'user-student-3',
      'email': 'ankit.verma@relab.com',
      'password': 'password123',
      'name': 'Ankit Verma',
      'phone': '9876543212',
      'role': 'student',
      'students': {
        'registration_number': '21BCE1088',
        'teacher_guardian_id': 'user-tg-1',
        'sections': {
          'id': 'sec-cseb',
          'name': 'B',
          'semester': 5,
          'departments': {
            'id': 'dept-cse',
            'name': 'Computer Science & Engineering',
            'code': 'CSE',
          },
        },
      },
    },
    {
      'id': 'user-student-4',
      'email': 'sneha.patel@relab.com',
      'password': 'password123',
      'name': 'Sneha Patel',
      'phone': '9876543213',
      'role': 'student',
      'students': {
        'registration_number': '21BCE1105',
        'teacher_guardian_id': 'user-tg-1',
        'sections': {
          'id': 'sec-cseb',
          'name': 'B',
          'semester': 5,
          'departments': {
            'id': 'dept-cse',
            'name': 'Computer Science & Engineering',
            'code': 'CSE',
          },
        },
      },
    },
    {
      'id': 'user-student-5',
      'email': 'rohan.k@relab.com',
      'password': 'password123',
      'name': 'Rohan Kulkarni',
      'phone': '9876543214',
      'role': 'student',
      'students': {
        'registration_number': '21BCE1019',
        'teacher_guardian_id': 'user-tg-1',
        'sections': {
          'id': 'sec-cseb',
          'name': 'B',
          'semester': 5,
          'departments': {
            'id': 'dept-cse',
            'name': 'Computer Science & Engineering',
            'code': 'CSE',
          },
        },
      },
    },
    {
      'id': 'user-student-6',
      'email': 'vikram.aditya@relab.com',
      'password': 'password123',
      'name': 'Vikram Aditya',
      'phone': '9876543215',
      'role': 'student',
      'students': {
        'registration_number': '21BCE1112',
        'teacher_guardian_id': 'user-tg-1',
        'sections': {
          'id': 'sec-cseb',
          'name': 'B',
          'semester': 5,
          'departments': {
            'id': 'dept-cse',
            'name': 'Computer Science & Engineering',
            'code': 'CSE',
          },
        },
      },
    },
    {
      'id': 'user-student-7',
      'email': 'kavita.deshmukh@relab.com',
      'password': 'password123',
      'name': 'Kavita Deshmukh',
      'phone': '9876543216',
      'role': 'student',
      'students': {
        'registration_number': '21BCE1055',
        'teacher_guardian_id': 'user-tg-1',
        'sections': {
          'id': 'sec-cseb',
          'name': 'B',
          'semester': 5,
          'departments': {
            'id': 'dept-cse',
            'name': 'Computer Science & Engineering',
            'code': 'CSE',
          },
        },
      },
    },
    {
      'id': 'user-student-8',
      'email': 'arjun.r@relab.com',
      'password': 'password123',
      'name': 'Arjun Ranganathan',
      'phone': '9876543217',
      'role': 'student',
      'students': {
        'registration_number': '21BCE1073',
        'teacher_guardian_id': 'user-tg-1',
        'sections': {
          'id': 'sec-cseb',
          'name': 'B',
          'semester': 5,
          'departments': {
            'id': 'dept-cse',
            'name': 'Computer Science & Engineering',
            'code': 'CSE',
          },
        },
      },
    },
    {
      'id': 'user-tg-1',
      'email': 'tg@relab.com',
      'password': 'password123',
      'name': 'Dr. Ananya Sen (TG)',
      'phone': '9876500001',
      'role': 'teacher_guardian',
      'teachers': {
        'departments': {
          'id': 'dept-cse',
          'name': 'Computer Science & Engineering',
          'code': 'CSE',
        },
      },
    },
    {
      'id': 'user-teacher-1',
      'email': 'teacher@relab.com',
      'password': 'password123',
      'name': 'Prof. Rajesh Kumar (Lab Teacher)',
      'phone': '9876500002',
      'role': 'lab_teacher',
      'teachers': {
        'departments': {
          'id': 'dept-cse',
          'name': 'Computer Science & Engineering',
          'code': 'CSE',
        },
      },
    },
    {
      'id': 'user-relab-1',
      'email': 'relabteacher@relab.com',
      'password': 'password123',
      'name': 'Prof. Vikram Mehta (Re-Lab Teacher)',
      'phone': '9876500003',
      'role': 'relab_teacher',
      'teachers': {
        'departments': {
          'id': 'dept-cse',
          'name': 'Computer Science & Engineering',
          'code': 'CSE',
        },
      },
    },
    {
      'id': 'user-hod-1',
      'email': 'hod@relab.com',
      'password': 'password123',
      'name': 'Dr. Ramesh Gupta (HOD)',
      'phone': '9876500004',
      'role': 'hod',
      'teachers': {
        'departments': {
          'id': 'dept-cse',
          'name': 'Computer Science & Engineering',
          'code': 'CSE',
        },
      },
    },
    {
      'id': 'user-admin-1',
      'email': 'admin@relab.com',
      'password': 'password123',
      'name': 'System Administrator',
      'phone': '9876500000',
      'role': 'admin',
    },
  ];

  // =========================================================================
  // 2. MASTER REFERENCE DATA (Departments, Sections, Subject Labs, Timetables)
  // =========================================================================
  final List<Map<String, dynamic>> _departments = [
    {'id': 'dept-cse', 'name': 'Computer Science & Engineering', 'code': 'CSE'},
    {'id': 'dept-ece', 'name': 'Electronics & Communication', 'code': 'ECE'},
  ];

  final List<Map<String, dynamic>> _sections = [
    {
      'id': 'sec-cseb',
      'name': 'B',
      'semester': 5,
      'department_id': 'dept-cse',
      'departments': {'name': 'Computer Science & Engineering'},
    },
    {
      'id': 'sec-csea',
      'name': 'A',
      'semester': 5,
      'department_id': 'dept-cse',
      'departments': {'name': 'Computer Science & Engineering'},
    },
    {
      'id': 'sec-ecea',
      'name': 'A',
      'semester': 5,
      'department_id': 'dept-ece',
      'departments': {'name': 'Electronics & Communication'},
    },
  ];

  final List<Map<String, dynamic>> _subjectLabs = [
    {
      'id': 'sub-dsa',
      'subject_code': 'CS3101',
      'subject_name': 'Data Structures & Algorithms Lab',
      'department_id': 'dept-cse',
      'lab_name': 'CS Lab 2',
      'room': 'Lab Room 204',
      'capacity': 32,
    },
    {
      'id': 'sub-networks',
      'subject_code': 'CS3102',
      'subject_name': 'Computer Networks Lab',
      'department_id': 'dept-cse',
      'lab_name': 'Networks Lab 1',
      'room': 'Lab Room 302',
      'capacity': 30,
    },
    {
      'id': 'sub-dbms',
      'subject_code': 'CS3103',
      'subject_name': 'Database Management Systems Lab',
      'department_id': 'dept-cse',
      'lab_name': 'DBMS Lab 3',
      'room': 'Lab Room 301',
      'capacity': 30,
    },
    {
      'id': 'sub-os',
      'subject_code': 'CS3104',
      'subject_name': 'Operating Systems Lab',
      'department_id': 'dept-cse',
      'lab_name': 'Systems Lab 2',
      'room': 'Lab Room 208',
      'capacity': 30,
    },
    {
      'id': 'sub-de',
      'subject_code': 'EC3101',
      'subject_name': 'Digital Electronics Lab',
      'department_id': 'dept-ece',
      'lab_name': 'Hardware Lab 1',
      'room': 'Lab Room 104',
      'capacity': 28,
    },
  ];

  final List<Map<String, dynamic>> _timetables = [
    {
      'id': 'tt-1',
      'subject_lab_id': 'sub-networks',
      'section_id': 'sec-cseb',
      'section_name': 'CSE-B',
      'teacher_name': 'Prof. Rajesh Kumar',
      'day_of_week': 'Monday',
      'start_time': '14:00',
      'end_time': '16:00',
      'room': 'Lab Room 302',
      'capacity': 30,
      'current_load': 22,
    },
    {
      'id': 'tt-2',
      'subject_lab_id': 'sub-networks',
      'section_id': 'sec-csea',
      'section_name': 'CSE-A',
      'teacher_name': 'Prof. Vikram Mehta',
      'day_of_week': 'Wednesday',
      'start_time': '10:00',
      'end_time': '12:00',
      'room': 'Lab Room 302',
      'capacity': 30,
      'current_load': 20,
    },
    {
      'id': 'tt-3',
      'subject_lab_id': 'sub-dsa',
      'section_id': 'sec-cseb',
      'section_name': 'CSE-B',
      'teacher_name': 'Prof. Rajesh Kumar',
      'day_of_week': 'Friday',
      'start_time': '14:00',
      'end_time': '16:00',
      'room': 'Lab Room 204',
      'capacity': 32,
      'current_load': 24,
    },
    {
      'id': 'tt-4',
      'subject_lab_id': 'sub-dbms',
      'section_id': 'sec-cseb',
      'section_name': 'CSE-B',
      'teacher_name': 'Dr. Ananya Sen',
      'day_of_week': 'Tuesday',
      'start_time': '10:00',
      'end_time': '12:00',
      'room': 'Lab Room 301',
      'capacity': 30,
      'current_load': 25,
    },
  ];

  // Dynamic Stores
  final List<Map<String, dynamic>> _requests = [];
  final List<Map<String, dynamic>> _notifications = [];
  final List<Map<String, dynamic>> _auditLogs = [];
  final Map<String, List<Map<String, dynamic>>> _studentRoutines = {};

  void _initSampleData() {
    _requests.clear();
    _notifications.clear();
    _auditLogs.clear();
    _studentRoutines.clear();
    _initDefaultRoutines();

    // Sample Request 1: Pending TG Review (Real Indian college case)
    _requests.add({
      'id': 'req-sample-1',
      'student_id': 'user-student-1',
      'student': {'name': 'Rahul Sharma', 'email': 'student@relab.com', 'registration_number': '21BCE1001'},
      'subject_lab_id': 'sub-dsa',
      'subject_lab': {
        'subject_code': 'CS3101',
        'subject_name': 'Data Structures & Algorithms Lab',
      },
      'missed_date': '2026-10-14',
      'experiment_name': 'Implementation of AVL Tree Rotations and Deletion Algorithms (Ex. 5)',
      'reason': 'Medical leave due to acute viral bronchitis. Attending physician from Apollo Clinic advised 3 days bed rest.',
      'status': 'TG_PENDING',
      'created_at': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
      'attachments': [
        {
          'file_name': 'apollo_medical_cert_oct14.pdf',
          'file_path': 'requests/user-student-1/apollo_medical_cert_oct14.pdf',
          'file_size': '245 KB',
          'file_type': 'application/pdf',
          'uploaded_at': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
        }
      ],
      'approvals': [],
    });

    // Sample Request 2: Approved, ready for slot selection
    _requests.add({
      'id': 'req-sample-2',
      'student_id': 'user-student-1',
      'student': {'name': 'Rahul Sharma', 'email': 'student@relab.com', 'registration_number': '21BCE1001'},
      'subject_lab_id': 'sub-networks',
      'subject_lab': {
        'subject_code': 'CS3102',
        'subject_name': 'Computer Networks Lab',
      },
      'missed_date': '2026-10-02',
      'experiment_name': 'Packet Sniffing and Three-Way TCP Handshake Analysis using Wireshark (Ex. 3)',
      'reason': 'Represented the college in Smart India Hackathon finals at MIT Pune (On-Duty approved by Faculty Coordinator).',
      'status': 'APPROVED',
      'created_at': DateTime.now().subtract(const Duration(days: 6)).toIso8601String(),
      'attachments': [
        {
          'file_name': 'sih_od_sanction_letter.pdf',
          'file_path': 'requests/user-student-1/sih_od_sanction_letter.pdf',
          'file_size': '380 KB',
          'file_type': 'application/pdf',
          'uploaded_at': DateTime.now().subtract(const Duration(days: 6)).toIso8601String(),
        }
      ],
      'approvals': [
        {'stage': 1, 'approver_role': 'teacher_guardian', 'status': 'APPROVED', 'remarks': 'OD approved. Hackathon participation certificate verified.'},
        {'stage': 2, 'approver_role': 'lab_teacher', 'status': 'APPROVED', 'remarks': 'Syllabus alignment confirmed. Experiment 3 repetition cleared.'},
        {'stage': 3, 'approver_role': 'relab_teacher', 'status': 'APPROVED', 'remarks': 'Lab capacity verified. Seat 18 assigned in Batch B2 on Thursday 2-4 PM.'},
        {'stage': 4, 'approver_role': 'hod', 'status': 'APPROVED', 'remarks': 'Cleared by HOD office. Quota verified.'},
      ],
    });

    // Sample Request 3: Completed Re-Lab
    _requests.add({
      'id': 'req-sample-3',
      'student_id': 'user-student-1',
      'student': {'name': 'Rahul Sharma', 'email': 'student@relab.com', 'registration_number': '21BCE1001'},
      'subject_lab_id': 'sub-dbms',
      'subject_lab': {
        'subject_code': 'CS3103',
        'subject_name': 'Database Management Systems Lab',
      },
      'missed_date': '2026-09-18',
      'experiment_name': 'Complex Nested SQL Queries and Trigger Creation (Ex. 7)',
      'reason': 'Family emergency in hometown (Jaipur). Prior intimation submitted to proctor office.',
      'status': 'COMPLETED',
      'created_at': DateTime.now().subtract(const Duration(days: 20)).toIso8601String(),
      'attachments': [],
      'approvals': [
        {'stage': 1, 'approver_role': 'teacher_guardian', 'status': 'APPROVED', 'remarks': 'Parental leave letter verified.'},
        {'stage': 2, 'approver_role': 'lab_teacher', 'status': 'APPROVED', 'remarks': 'Lab record evaluated. Repetition sanctioned.'},
        {'stage': 3, 'approver_role': 'relab_teacher', 'status': 'APPROVED', 'remarks': 'Attended on 24-Sep. Practical evaluated.'},
        {'stage': 4, 'approver_role': 'hod', 'status': 'APPROVED', 'remarks': 'Attendance marked complete in ERP.'},
      ],
      're_lab_slots': [
        {
          'date': '2026-09-24',
          'status': 'COMPLETED',
          'timetable': {
            'room': 'Lab Room 301',
            'start_time': '14:00',
            'end_time': '16:00',
          }
        }
      ]
    });

    // Sample Request 4: Pending TG Review (Priya Nair - Food Poisoning)
    _requests.add({
      'id': 'req-sample-4',
      'student_id': 'user-student-2',
      'student': {'name': 'Priya Nair', 'email': 'priya.nair@relab.com', 'registration_number': '21BCE1042'},
      'subject_lab_id': 'sub-dbms',
      'subject_lab': {
        'subject_code': 'CS3103',
        'subject_name': 'Database Management Systems Lab',
      },
      'missed_date': '2026-10-18',
      'experiment_name': 'Normalization & BCNF Decomposition of Relational Schemas (Ex. 6)',
      'reason': 'Suffered acute gastroenteritis and severe dehydration. Admitted to City Care Hospital with medical note.',
      'status': 'TG_PENDING',
      'created_at': DateTime.now().subtract(const Duration(hours: 18)).toIso8601String(),
      'attachments': [
        {
          'file_name': 'city_care_hospital_discharge.pdf',
          'file_path': 'requests/user-student-2/city_care_hospital_discharge.pdf',
          'file_size': '512 KB',
          'file_type': 'application/pdf',
          'uploaded_at': DateTime.now().subtract(const Duration(hours: 18)).toIso8601String(),
        }
      ],
      'approvals': [],
    });

    // Sample Request 5: Pending TG Review (Ankit Verma - Sports OD)
    _requests.add({
      'id': 'req-sample-5',
      'student_id': 'user-student-3',
      'student': {'name': 'Ankit Verma', 'email': 'ankit.verma@relab.com', 'registration_number': '21BCE1088'},
      'subject_lab_id': 'sub-networks',
      'subject_lab': {
        'subject_code': 'CS3102',
        'subject_name': 'Computer Networks Lab',
      },
      'missed_date': '2026-10-21',
      'experiment_name': 'VLAN Configuration and Inter-VLAN Routing on Cisco Packet Tracer (Ex. 4)',
      'reason': 'Represented the university in All-India Inter-Collegiate Badminton Tournament at IIT Madras (OD approved by Sports Officer).',
      'status': 'TG_PENDING',
      'created_at': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
      'attachments': [
        {
          'file_name': 'sports_council_od_letter.pdf',
          'file_path': 'requests/user-student-3/sports_council_od_letter.pdf',
          'file_size': '320 KB',
          'file_type': 'application/pdf',
          'uploaded_at': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        }
      ],
      'approvals': [],
    });

    // Sample Request 6: Pending TG Review (Sneha Patel - Family Emergency)
    _requests.add({
      'id': 'req-sample-6',
      'student_id': 'user-student-4',
      'student': {'name': 'Sneha Patel', 'email': 'sneha.patel@relab.com', 'registration_number': '21BCE1105'},
      'subject_lab_id': 'sub-os',
      'subject_lab': {
        'subject_code': 'CS3104',
        'subject_name': 'Operating Systems Lab',
      },
      'missed_date': '2026-10-24',
      'experiment_name': 'Producer-Consumer Problem using POSIX Semaphores & Shared Memory (Ex. 4)',
      'reason': 'Attended sibling wedding ceremony in Ahmedabad. Leave intimation email submitted in advance to Proctor Office.',
      'status': 'TG_PENDING',
      'created_at': DateTime.now().subtract(const Duration(hours: 36)).toIso8601String(),
      'attachments': [
        {
          'file_name': 'wedding_invitation_parent_letter.pdf',
          'file_path': 'requests/user-student-4/wedding_invitation_parent_letter.pdf',
          'file_size': '1.2 MB',
          'file_type': 'application/pdf',
          'uploaded_at': DateTime.now().subtract(const Duration(hours: 36)).toIso8601String(),
        }
      ],
      'approvals': [],
    });

    // Sample Request 7: Processed by TG, now Pending Lab Teacher (Rohan Kulkarni)
    _requests.add({
      'id': 'req-sample-7',
      'student_id': 'user-student-5',
      'student': {'name': 'Rohan Kulkarni', 'email': 'rohan.k@relab.com', 'registration_number': '21BCE1019'},
      'subject_lab_id': 'sub-dsa',
      'subject_lab': {
        'subject_code': 'CS3101',
        'subject_name': 'Data Structures & Algorithms Lab',
      },
      'missed_date': '2026-10-08',
      'experiment_name': 'Breadth-First and Depth-First Graph Traversal Algorithms (Ex. 7)',
      'reason': 'Severe migraine headache and fever on the morning of practical session.',
      'status': 'LAB_TEACHER_PENDING',
      'created_at': DateTime.now().subtract(const Duration(days: 9)).toIso8601String(),
      'attachments': [
        {
          'file_name': 'campus_dispensary_prescription.pdf',
          'file_path': 'requests/user-student-5/campus_dispensary_prescription.pdf',
          'file_size': '190 KB',
          'file_type': 'application/pdf',
          'uploaded_at': DateTime.now().subtract(const Duration(days: 9)).toIso8601String(),
        }
      ],
      'approvals': [
        {'stage': 1, 'approver_role': 'teacher_guardian', 'status': 'APPROVED', 'remarks': 'Medical slip verified. Student attended campus dispensary on morning of lab.'},
      ],
    });

    // Sample Request 8: Rejected by TG (Vikram Aditya)
    _requests.add({
      'id': 'req-sample-8',
      'student_id': 'user-student-6',
      'student': {'name': 'Vikram Aditya', 'email': 'vikram.aditya@relab.com', 'registration_number': '21BCE1112'},
      'subject_lab_id': 'sub-dbms',
      'subject_lab': {
        'subject_code': 'CS3103',
        'subject_name': 'Database Management Systems Lab',
      },
      'missed_date': '2026-10-10',
      'experiment_name': 'PL/SQL Triggers and Cursor Implementations (Ex. 8)',
      'reason': 'Overslept and missed the early morning 8:30 AM practical batch.',
      'status': 'REJECTED',
      'created_at': DateTime.now().subtract(const Duration(days: 12)).toIso8601String(),
      'attachments': [],
      'approvals': [
        {'stage': 1, 'approver_role': 'teacher_guardian', 'status': 'REJECTED', 'remarks': 'Re-lab denied. Unexcused absence without prior intimation or authentic medical proof.'},
      ],
    });

    // Sample Request 9: Pending TG Review (Kavita Deshmukh - NSS Blood Donation Camp OD)
    _requests.add({
      'id': 'req-sample-9',
      'student_id': 'user-student-7',
      'student': {'name': 'Kavita Deshmukh', 'email': 'kavita.deshmukh@relab.com', 'registration_number': '21BCE1055'},
      'subject_lab_id': 'sub-de',
      'subject_lab': {
        'subject_code': 'EC3101',
        'subject_name': 'Digital Electronics Lab',
      },
      'missed_date': '2026-10-25',
      'experiment_name': 'Design of Synchronous 4-bit Up/Down Decade Counter using JK Flip-Flops (Ex. 5)',
      'reason': 'Volunteered as lead coordinator for the annual Red Cross & NSS Blood Donation Camp on campus.',
      'status': 'TG_PENDING',
      'created_at': DateTime.now().subtract(const Duration(hours: 14)).toIso8601String(),
      'attachments': [
        {
          'file_name': 'nss_coordinator_recommendation.pdf',
          'file_path': 'requests/user-student-7/nss_coordinator_recommendation.pdf',
          'file_size': '310 KB',
          'file_type': 'application/pdf',
          'uploaded_at': DateTime.now().subtract(const Duration(hours: 14)).toIso8601String(),
        }
      ],
      'approvals': [],
    });

    // Sample Request 10: Pending TG Review (Arjun Ranganathan - Dengue Fever Hospitalization)
    _requests.add({
      'id': 'req-sample-10',
      'student_id': 'user-student-8',
      'student': {'name': 'Arjun Ranganathan', 'email': 'arjun.r@relab.com', 'registration_number': '21BCE1073'},
      'subject_lab_id': 'sub-os',
      'subject_lab': {
        'subject_code': 'CS3104',
        'subject_name': 'Operating Systems Lab',
      },
      'missed_date': '2026-10-12',
      'experiment_name': 'Multithreaded Matrix Multiplication using Pthreads in C (Ex. 3)',
      'reason': 'Diagnosed with dengue fever (platelet count dropped to 48,000). Admitted at Apollo Hospital for 4 days.',
      'status': 'TG_PENDING',
      'created_at': DateTime.now().subtract(const Duration(hours: 8)).toIso8601String(),
      'attachments': [
        {
          'file_name': 'apollo_platelet_report_discharge.pdf',
          'file_path': 'requests/user-student-8/apollo_platelet_report_discharge.pdf',
          'file_size': '440 KB',
          'file_type': 'application/pdf',
          'uploaded_at': DateTime.now().subtract(const Duration(hours: 8)).toIso8601String(),
        }
      ],
      'approvals': [],
    });

    // Notifications
    _notifications.add({
      'id': 'notif-1',
      'user_id': 'user-student-1',
      'title': 'Re-Lab Request Approved',
      'message': 'Your re-lab request for Computer Networks Lab (CS302) has received final approval. You can now select a slot.',
      'is_read': false,
      'created_at': DateTime.now().subtract(const Duration(hours: 4)).toIso8601String(),
    });

    _notifications.add({
      'id': 'notif-2',
      'user_id': 'user-tg-1',
      'title': 'New Pending Re-Lab Application',
      'message': 'Student Rahul Sharma has submitted a re-lab request for Database Management Systems Lab.',
      'is_read': false,
      'created_at': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
    });
  }

  // =========================================================================
  // 3. AUTHENTICATION & PROFILE METHODS
  // =========================================================================
  Map<String, dynamic>? authenticate(String email, String password) {
    final cleanEmail = email.trim().toLowerCase();
    final cleanPass = password.trim();

    try {
      final user = _users.firstWhere(
        (u) => u['email'].toString().toLowerCase() == cleanEmail && u['password'] == cleanPass,
      );
      return Map<String, dynamic>.from(user);
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic>? getUserById(String id) {
    try {
      return _users.firstWhere((u) => u['id'] == id);
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic> registerStudent({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String registrationNumber,
    required String sectionId,
    required String teacherGuardianId,
  }) {
    final sec = _sections.firstWhere((s) => s['id'] == sectionId, orElse: () => _sections.first);
    final newId = 'user-student-${DateTime.now().millisecondsSinceEpoch}';

    final newUser = {
      'id': newId,
      'email': email.trim().toLowerCase(),
      'password': password,
      'name': name.trim(),
      'phone': phone.trim(),
      'role': 'student',
      'students': {
        'registration_number': registrationNumber.trim(),
        'teacher_guardian_id': teacherGuardianId,
        'sections': {
          'id': sec['id'],
          'name': sec['name'],
          'semester': sec['semester'],
          'departments': sec['departments'],
        },
      },
    };

    _users.add(newUser);
    return newUser;
  }

  List<Map<String, dynamic>> get departments => _departments;
  List<Map<String, dynamic>> get sections => _sections;
  List<Map<String, dynamic>> get subjectLabs => _subjectLabs;
  List<Map<String, dynamic>> get staffList => _users.where((u) => u['role'] != 'student').toList();

  void resetSampleData() {
    _initSampleData();
  }

  // =========================================================================
  // 4. REQUESTS & WORKFLOW APPROVALS
  // =========================================================================
  List<Map<String, dynamic>> getRequestsForUser(String userId, String role) {
    if (_requests.isEmpty) {
      _initSampleData();
    }
    if (role == 'student') {
      return _requests.where((r) => r['student_id'] == userId).toList();
    } else {
      // Staff members see all departmental requests
      return List<Map<String, dynamic>>.from(_requests);
    }
  }

  Map<String, dynamic>? getRequestById(String id) {
    try {
      return _requests.firstWhere((r) => r['id'] == id);
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic> createRequest({
    required String studentId,
    required String subjectLabId,
    required String missedDate,
    required String reason,
    String? attachmentName,
    String? attachmentPath,
    Uint8List? attachmentBytes,
    String? attachmentSize,
    String? attachmentType,
  }) {
    final student = getUserById(studentId);
    final subject = _subjectLabs.firstWhere((s) => s['id'] == subjectLabId);

    final reqId = 'req-${DateTime.now().millisecondsSinceEpoch}';
    final newReq = {
      'id': reqId,
      'student_id': studentId,
      'student': {'name': student?['name'] ?? 'Student', 'email': student?['email'] ?? ''},
      'subject_lab_id': subjectLabId,
      'subject_lab': {
        'subject_code': subject['subject_code'],
        'subject_name': subject['subject_name'],
      },
      'missed_date': missedDate,
      'reason': reason,
      'status': 'TG_PENDING',
      'created_at': DateTime.now().toIso8601String(),
      'attachments': attachmentName != null
          ? [
              {
                'file_name': attachmentName,
                'file_path': attachmentPath ?? attachmentName,
                'file_size': attachmentSize ?? '185 KB',
                'file_type': attachmentType ?? (attachmentName.toLowerCase().endsWith('.pdf') ? 'application/pdf' : 'image/jpeg'),
                'file_bytes': attachmentBytes,
                'uploaded_at': DateTime.now().toIso8601String(),
              }
            ]
          : [],
      'approvals': [],
    };

    _requests.insert(0, newReq);

    // Notify TG
    final tgId = student?['students']?['teacher_guardian_id'] ?? 'user-tg-1';
    _notifications.insert(0, {
      'id': 'notif-${DateTime.now().millisecondsSinceEpoch}',
      'user_id': tgId,
      'title': 'New Re-Lab Request Pending',
      'message': 'Student ${student?['name']} has applied for ${subject['subject_name']} re-lab.',
      'is_read': false,
      'created_at': DateTime.now().toIso8601String(),
    });

    return newReq;
  }

  void addAttachmentToRequest({
    required String requestId,
    required String fileName,
    String? filePath,
    Uint8List? fileBytes,
    String? fileSize,
    String? fileType,
  }) {
    final index = _requests.indexWhere((r) => r['id'] == requestId);
    if (index != -1) {
      final attachments = _requests[index]['attachments'] as List<dynamic>? ?? [];
      attachments.add({
        'file_name': fileName,
        'file_path': filePath ?? 'requests/${_requests[index]['student_id']}/$fileName',
        'file_size': fileSize ?? '210 KB',
        'file_type': fileType ?? (fileName.toLowerCase().endsWith('.pdf') ? 'application/pdf' : 'image/jpeg'),
        'file_bytes': fileBytes,
        'uploaded_at': DateTime.now().toIso8601String(),
      });
      _requests[index]['attachments'] = attachments;
    }
  }

  void approveRequest({
    required String requestId,
    required String approverRole,
    required String status, // 'APPROVED' or 'REJECTED'
    required String remarks,
  }) {
    final index = _requests.indexWhere((r) => r['id'] == requestId);
    if (index == -1) return;

    final req = _requests[index];

    if (status == 'REJECTED') {
      req['status'] = 'REJECTED';
      req['approvals'].add({
        'stage': _getStageNumber(approverRole),
        'approver_role': approverRole,
        'status': 'REJECTED',
        'remarks': remarks,
        'created_at': DateTime.now().toIso8601String(),
      });

      _notifications.insert(0, {
        'id': 'notif-${DateTime.now().millisecondsSinceEpoch}',
        'user_id': req['student_id'],
        'title': 'Re-Lab Request Rejected',
        'message': 'Your re-lab application for ${req['subject_lab']['subject_name']} was rejected: $remarks',
        'is_read': false,
        'created_at': DateTime.now().toIso8601String(),
      });
      return;
    }

    // Step-by-step workflow escalation
    String nextStatus = req['status'];
    if (approverRole == 'teacher_guardian' || req['status'] == 'TG_PENDING') {
      nextStatus = 'LAB_TEACHER_PENDING';
    } else if (approverRole == 'lab_teacher' || req['status'] == 'LAB_TEACHER_PENDING') {
      nextStatus = 'RELAB_TEACHER_PENDING';
    } else if (approverRole == 'relab_teacher' || req['status'] == 'RELAB_TEACHER_PENDING') {
      nextStatus = 'HOD_PENDING';
    } else if (approverRole == 'hod' || approverRole == 'admin' || req['status'] == 'HOD_PENDING') {
      nextStatus = 'APPROVED';
    }

    req['status'] = nextStatus;
    req['approvals'].add({
      'stage': _getStageNumber(approverRole),
      'approver_role': approverRole,
      'status': 'APPROVED',
      'remarks': remarks.isEmpty ? 'Approved' : remarks,
      'created_at': DateTime.now().toIso8601String(),
    });

    // Notify Student
    if (nextStatus == 'APPROVED') {
      _notifications.insert(0, {
        'id': 'notif-${DateTime.now().millisecondsSinceEpoch}',
        'user_id': req['student_id'],
        'title': 'Final Approval Received! 🎉',
        'message': 'Your re-lab request for ${req['subject_lab']['subject_name']} has been approved by HOD. Select an available slot now.',
        'is_read': false,
        'created_at': DateTime.now().toIso8601String(),
      });
    } else {
      _notifications.insert(0, {
        'id': 'notif-${DateTime.now().millisecondsSinceEpoch}',
        'user_id': req['student_id'],
        'title': 'Approval Stage Passed',
        'message': 'Your re-lab request advanced to ${nextStatus.replaceAll('_', ' ')}.',
        'is_read': false,
        'created_at': DateTime.now().toIso8601String(),
      });
    }
  }

  int _getStageNumber(String role) {
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

  // =========================================================================
  // 5. INTELLIGENT TIMETABLE MATCHING & SCORING
  // =========================================================================
  List<Map<String, dynamic>> getMatchingSlots(String requestId) {
    final req = _requests.firstWhere((r) => r['id'] == requestId, orElse: () => {});
    if (req.isEmpty) return [];

    final subjectLabId = req['subject_lab_id'];
    final candidateSlots = _timetables.where((tt) => tt['subject_lab_id'] == subjectLabId).toList();

    final List<Map<String, dynamic>> rankedMatches = [];

    final studentId = req['student_id'] ?? 'user-student-1';
    final studentRoutine = getStudentRoutine(studentId);

    // Hard Constraint: Find any clashes with student's active weekly routine
    final busySlotKeys = <String>{};
    for (final s in studentRoutine) {
      busySlotKeys.add("${s['day_of_week']}_${s['start_time']}");
    }

    for (int i = 0; i < candidateSlots.length; i++) {
      final slot = candidateSlots[i];
      
      // Hard Constraint: Skip slot if student has regular class at that time
      final conflictKey = "${slot['day_of_week']}_${slot['start_time']}";
      if (busySlotKeys.contains(conflictKey)) {
        continue;
      }

      // Calculate future session date based on slot day
      final targetDay = slot['day_of_week'];
      final nextDate = _getNextDateForDay(targetDay);
      final dateStr = DateFormat('yyyy-MM-dd').format(nextDate);

      // Scoring formula: Section(30%) + Subject(25%) + Teacher(20%) + Room(15%) + Proximity(10%)
      int score = 70;
      if (slot['section_name'] == 'CSE-B') score += 15; // Section Match
      if (slot['teacher_name'].toString().contains('Rajesh')) score += 10; // Teacher Match
      if (i == 0) score += 5; // Earliest slot

      score = score.clamp(75, 98);

      rankedMatches.add({
        'timetable_id': slot['id'],
        'date': dateStr,
        'day_of_week': slot['day_of_week'],
        'start_time': slot['start_time'],
        'end_time': slot['end_time'],
        'room': slot['room'],
        'teacher_name': slot['teacher_name'],
        'section_name': slot['section_name'],
        'score': score,
        'available_capacity': (slot['capacity'] as int) - (slot['current_load'] as int),
      });
    }

    // Sort descending by match percentage score
    rankedMatches.sort((a, b) => (b['score'] as int).compareTo(a['score'] as int));
    return rankedMatches;
  }

  DateTime _getNextDateForDay(String dayName) {
    final dayMap = {
      'Monday': DateTime.monday,
      'Tuesday': DateTime.tuesday,
      'Wednesday': DateTime.wednesday,
      'Thursday': DateTime.thursday,
      'Friday': DateTime.friday,
      'Saturday': DateTime.saturday,
      'Sunday': DateTime.sunday,
    };

    final targetWeekday = dayMap[dayName] ?? DateTime.monday;
    DateTime date = DateTime.now();
    while (date.weekday != targetWeekday || date.isBefore(DateTime.now())) {
      date = date.add(const Duration(days: 1));
    }
    return date;
  }

  void bookSlot({
    required String requestId,
    required String timetableId,
    required String date,
  }) {
    final index = _requests.indexWhere((r) => r['id'] == requestId);
    if (index == -1) return;

    final req = _requests[index];
    final tt = _timetables.firstWhere((t) => t['id'] == timetableId, orElse: () => _timetables.first);

    req['status'] = 'SLOT_SELECTED';
    req['re_lab_slots'] = [
      {
        'date': date,
        'status': 'RESERVED',
        'timetable': {
          'room': tt['room'],
          'start_time': tt['start_time'],
          'end_time': tt['end_time'],
        }
      }
    ];

    _notifications.insert(0, {
      'id': 'notif-${DateTime.now().millisecondsSinceEpoch}',
      'user_id': req['student_id'],
      'title': 'Re-Lab Slot Confirmed 📅',
      'message': 'Your re-lab is confirmed for $date (${tt['start_time']} - ${tt['end_time']}) at ${tt['room']}.',
      'is_read': false,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  void completeSession({
    required String requestId,
    required String remarks,
  }) {
    final index = _requests.indexWhere((r) => r['id'] == requestId);
    if (index == -1) return;

    final req = _requests[index];
    req['status'] = 'COMPLETED';

    _notifications.insert(0, {
      'id': 'notif-${DateTime.now().millisecondsSinceEpoch}',
      'user_id': req['student_id'],
      'title': 'Re-Lab Completed! ✅',
      'message': 'Your re-lab session for ${req['subject_lab']['subject_name']} was completed successfully.',
      'is_read': false,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  // =========================================================================
  // 6. NOTIFICATIONS
  // =========================================================================
  List<Map<String, dynamic>> getNotifications(String userId) {
    return _notifications.where((n) => n['user_id'] == userId).toList();
  }

  void markNotificationAsRead(String id) {
    final notif = _notifications.firstWhere((n) => n['id'] == id, orElse: () => {});
    if (notif.isNotEmpty) {
      notif['is_read'] = true;
    }
  }

  // =========================================================================
  // 7. OFFLINE INTELLIGENT AI ASSISTANT
  // =========================================================================
  String getAIResponse(String userQuery, String role, String userId) {
    final q = userQuery.toLowerCase();

    if (role == 'student') {
      final myReqs = getRequestsForUser(userId, 'student');
      final activeReq = myReqs.isNotEmpty ? myReqs.first : null;

      if (q.contains('status') || q.contains('my re-lab') || q.contains('application')) {
        if (activeReq != null) {
          final subj = activeReq['subject_lab']['subject_name'];
          final status = activeReq['status'].toString().replaceAll('_', ' ');
          return 'Your application for **$subj** is currently in **$status** stage.\n\n'
                 '• Missed Date: ${activeReq['missed_date']}\n'
                 '• Reason: "${activeReq['reason']}"\n\n'
                 'Once the HOD approves it, you can select a timetable slot directly from your dashboard.';
        }
        return 'You do not have any active re-lab applications at the moment. Click **"Apply for Re-Lab"** to submit a new request!';
      }

      if (q.contains('when') || q.contains('slot') || q.contains('time') || q.contains('scheduled')) {
        final scheduled = myReqs.where((r) => r['status'] == 'SLOT_SELECTED' || r['status'] == 'COMPLETED').toList();
        if (scheduled.isNotEmpty) {
          final s = scheduled.first;
          final slotInfo = s['re_lab_slots']?[0];
          return 'Your booked re-lab session is scheduled for:\n\n'
                 '📅 **Date**: ${slotInfo?['date'] ?? 'Upcoming'}\n'
                 '⏰ **Time**: ${slotInfo?['timetable']?['start_time']} - ${slotInfo?['timetable']?['end_time']}\n'
                 '📍 **Venue**: ${slotInfo?['timetable']?['room']}';
        }
        return 'No scheduled slots found. Once your request status reaches **APPROVED**, tap the **"Select Slot"** button to view and book matched candidate sessions.';
      }

      if (q.contains('document') || q.contains('enclosure') || q.contains('proof') || q.contains('certificate')) {
        return 'Supporting documents (e.g. Medical Certificate, Duty Leave proof, or Event Participation letters) can be uploaded as PDF or JPG when filling the Re-Lab Application form.';
      }

      if (q.contains('process') || q.contains('stages') || q.contains('approval')) {
        return 'The re-lab approval workflow follows 4 stages:\n\n'
               '1. **Teacher Guardian (TG)** review\n'
               '2. **Lab Teacher** review\n'
               '3. **Re-Lab Teacher** slot clearance\n'
               '4. **HOD** final sanction\n\n'
               'After Stage 4, the intelligent timetable matcher unlocks your slot choices!';
      }

      if (q.contains('routine') || q.contains('timetable') || q.contains('schedule') || q.contains('classes')) {
        final routine = getStudentRoutine(userId);
        final labCount = routine.where((s) => s['is_lab'] == true).length;
        final totalCount = routine.length;
        return 'Your uploaded routine contains **$totalCount weekly sessions** (including **$labCount practical laboratory classes**).\n\n'
               '• You can view and manage your timetable anytime via the **"My Routine & Timetable"** card on your dashboard.\n'
               '• All re-lab matching recommendations automatically respect your routine periods to avoid schedule clashes!';
      }

      return 'Hello Rahul! I am your Re-Lab Assistant. I can assist you with:\n'
             '• Tracking your approval status\n'
             '• Finding your scheduled re-lab timings\n'
             '• Viewing and syncing your class routine/timetable\n'
             '• Explaining required documents and workflow stages\n\n'
             'How can I help you today?';
    } else {
      // Staff response
      final pendingCount = _requests.where((r) => r['status'].toString().contains('PENDING')).length;
      final completedCount = _requests.where((r) => r['status'] == 'COMPLETED').length;

      if (q.contains('pending') || q.contains('requests') || q.contains('approval')) {
        return 'Currently there are **$pendingCount re-lab applications** pending approval across department queues.\n\n'
               'Please review the **"Pending Approvals"** tab on your dashboard to approve or reject requests.';
      }

      if (q.contains('today') || q.contains('session') || q.contains('scheduled')) {
        return 'Today\'s re-lab laboratory roster:\n\n'
               '• **DBMS Lab (CS301)**: Lab Room 301 (14:00 - 16:00)\n'
               '• Student: Rahul Sharma (21BCE1001)\n'
               '• Capacity: 30 (Remaining seats: 8)';
      }

      if (q.contains('summary') || q.contains('stats') || q.contains('month')) {
        return '📊 **Monthly Department Summary**:\n\n'
               '• Total Re-Labs Completed: **$completedCount**\n'
               '• Active In-Progress: **$pendingCount**\n'
               '• Average Match Score: **92.4%**';
      }

      return 'Hello! I am your Department AI Assistant. You can ask me to summarize pending approvals, today\'s laboratory roster, or monthly completion metrics.';
    }
  }

  // =========================================================================
  // 8. CLASS ROUTINE & TIMETABLE MANAGEMENT
  // =========================================================================
  void _initDefaultRoutines() {
    _studentRoutines['user-student-1'] = getSectionRoutine('sec-cseb');
  }

  List<Map<String, dynamic>> getSectionRoutine(String sectionId) {
    final secData = SemesterTimetableData.getSectionData(sectionId);
    final rawSlots = secData['slots'] as List<dynamic>? ?? [];
    return rawSlots.map((s) => Map<String, dynamic>.from(s as Map)).toList();
  }

  List<Map<String, dynamic>> getStudentRoutine(String studentId) {
    if (!_studentRoutines.containsKey(studentId) || _studentRoutines[studentId]!.isEmpty) {
      if (studentId == 'user-student-1') {
        _initDefaultRoutines();
      } else {
        _studentRoutines[studentId] = [];
      }
    }
    return List<Map<String, dynamic>>.from(_studentRoutines[studentId] ?? []);
  }

  void saveStudentRoutine(String studentId, List<Map<String, dynamic>> slots) {
    _studentRoutines[studentId] = List<Map<String, dynamic>>.from(slots);

    _notifications.insert(0, {
      'id': 'notif-',
      'user_id': studentId,
      'title': 'Routine Synced with Re-Lab Engine 📅',
      'message': 'Your weekly timetable ( periods) has been saved. Re-lab conflict matching will automatically respect these slots.',
      'is_read': false,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  void resetStudentRoutine(String studentId, [String sectionId = 'sec-cseb']) {
    _studentRoutines[studentId] = getSectionRoutine(sectionId);
    _notifications.insert(0, {
      'id': 'notif-',
      'user_id': studentId,
      'title': 'Routine Reverted',
      'message': 'Your routine was reset to default departmental timetable for .',
      'is_read': false,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  String getSampleRoutineCSV() {
    return '''Day,Slot,Start_Time,End_Time,Subject_Code,Subject_Name,Room,Teacher,Is_Lab
Monday,1,09:00,10:00,CS303,Operating Systems,Room 204,Prof. S. Sen,No
Monday,2,10:00,11:00,CS302,Computer Networks,Room 204,Dr. Ananya Sen,No
Monday,3,11:15,12:15,CS304,Formal Language & Automata,Room 204,Dr. M. Roy,No
Monday,4,12:15,13:15,MA301,Discrete Mathematics,Room 204,Prof. K. Das,No
Monday,5,14:00,16:00,CS301,Database Management Systems Lab,Lab Room 301,Prof. Rajesh Kumar,Yes
Tuesday,1,09:00,10:00,MA301,Discrete Mathematics,Room 204,Prof. K. Das,No
Tuesday,2,10:00,12:00,CS302,Computer Networks Lab,Lab Room 302,Dr. Ananya Sen,Yes
Tuesday,4,12:15,13:15,CS303,Operating Systems,Room 204,Prof. S. Sen,No
Tuesday,5,14:00,15:00,CS304,Formal Language & Automata,Room 204,Dr. M. Roy,No
Tuesday,6,15:00,16:00,CS305,Software Engineering,Room 204,Prof. N. Chatterjee,No
Wednesday,1,09:00,10:00,CS305,Software Engineering,Room 204,Prof. N. Chatterjee,No
Wednesday,2,10:00,11:00,CS303,Operating Systems,Room 204,Prof. S. Sen,No
Wednesday,3,11:15,12:15,CS302,Computer Networks,Room 204,Dr. Ananya Sen,No
Wednesday,4,12:15,13:15,HS301,Professional Ethics,Room 204,Dr. P. Banerjee,No
Wednesday,5,14:00,16:00,CS306,Web Technologies Lab,Lab Room 202,Prof. Vikram Mehta,Yes
Thursday,1,09:00,10:00,CS304,Formal Language & Automata,Room 204,Dr. M. Roy,No
Thursday,2,10:00,11:00,MA301,Discrete Mathematics,Room 204,Prof. K. Das,No
Thursday,3,11:15,12:15,CS305,Software Engineering,Room 204,Prof. N. Chatterjee,No
Thursday,4,12:15,13:15,CS303,Operating Systems,Room 204,Prof. S. Sen,No
Thursday,5,14:00,15:00,HS302,Mentorship & Library,Central Library,Dr. Ananya Sen,No
Friday,1,09:00,10:00,CS302,Computer Networks,Room 204,Dr. Ananya Sen,No
Friday,2,10:00,11:00,CS305,Software Engineering,Room 204,Prof. N. Chatterjee,No
Friday,3,11:15,12:15,HS301,Professional Ethics,Room 204,Dr. P. Banerjee,No
Friday,4,12:15,13:15,MA301,Discrete Mathematics,Room 204,Prof. K. Das,No
Friday,5,14:00,16:00,CS301,Database Management Systems Lab,Lab Room 301,Prof. Rajesh Kumar,Yes''';
  }

  List<Map<String, dynamic>> parseRoutineCSV(String csvContent) {
    final List<Map<String, dynamic>> parsedSlots = [];
    final lines = csvContent.split(RegExp(r'\r?\n'));
    if (lines.isEmpty) return parsedSlots;

    int idCounter = 1;
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;

      // Skip header row
      if (i == 0 && line.toLowerCase().startsWith('day')) continue;

      final parts = line.split(',');
      if (parts.length >= 7) {
        final day = parts[0].trim();
        final slotNum = int.tryParse(parts[1].trim()) ?? 1;
        final startTime = parts[2].trim();
        final endTime = parts[3].trim();
        final code = parts[4].trim();
        final name = parts[5].trim();
        final room = parts[6].trim();
        final teacher = parts.length > 7 ? parts[7].trim() : 'Faculty';
        final isLab = parts.length > 8 ? (parts[8].trim().toLowerCase() == 'yes' || parts[8].trim().toLowerCase() == 'true') : name.toLowerCase().contains('lab');

        parsedSlots.add({
          'id': 'imp-${idCounter++}',
          'day_of_week': _normalizeDayName(day),
          'slot_number': slotNum,
          'start_time': startTime,
          'end_time': endTime,
          'subject_code': code,
          'subject_name': name,
          'room': room,
          'teacher_name': teacher,
          'is_lab': isLab,
        });
      }
    }
    return parsedSlots;
  }

  String _normalizeDayName(String raw) {
    final lower = raw.trim().toLowerCase();
    if (lower.startsWith('mon')) return 'Monday';
    if (lower.startsWith('tue')) return 'Tuesday';
    if (lower.startsWith('wed')) return 'Wednesday';
    if (lower.startsWith('thu')) return 'Thursday';
    if (lower.startsWith('fri')) return 'Friday';
    if (lower.startsWith('sat')) return 'Saturday';
    if (lower.startsWith('sun')) return 'Sunday';
    return raw;
  }

  Future<List<Map<String, dynamic>>> parseRoutineAI({
    required String studentId,
    String? imageBase64,
    String? fileName,
    String? rawText,
  }) async {
    // Natural latency simulation
    await Future.delayed(const Duration(milliseconds: 700));

    // If raw text is available and contains CSV structure, parse directly
    if (rawText != null && rawText.contains(',')) {
      final parsed = parseRoutineCSV(rawText);
      if (parsed.isNotEmpty) return parsed;
    }

    // High quality contextual AI extraction simulation
    return [
      {
        'id': 'ai-1',
        'day_of_week': 'Monday',
        'slot_number': 1,
        'start_time': '09:00',
        'end_time': '10:00',
        'subject_code': 'CS303',
        'subject_name': 'Operating Systems (AI Extracted)',
        'room': 'Room 204',
        'teacher_name': 'Prof. S. Sen',
        'is_lab': false,
      },
      {
        'id': 'ai-2',
        'day_of_week': 'Monday',
        'slot_number': 2,
        'start_time': '10:00',
        'end_time': '11:00',
        'subject_code': 'CS302',
        'subject_name': 'Computer Networks',
        'room': 'Room 204',
        'teacher_name': 'Dr. Ananya Sen',
        'is_lab': false,
      },
      {
        'id': 'ai-3',
        'day_of_week': 'Monday',
        'slot_number': 5,
        'start_time': '14:00',
        'end_time': '16:00',
        'subject_code': 'CS301',
        'subject_name': 'Database Management Systems Lab',
        'room': 'Lab Room 301',
        'teacher_name': 'Prof. Rajesh Kumar',
        'is_lab': true,
      },
      {
        'id': 'ai-4',
        'day_of_week': 'Tuesday',
        'slot_number': 2,
        'start_time': '10:00',
        'end_time': '12:00',
        'subject_code': 'CS302',
        'subject_name': 'Computer Networks Lab',
        'room': 'Lab Room 302',
        'teacher_name': 'Dr. Ananya Sen',
        'is_lab': true,
      },
      {
        'id': 'ai-5',
        'day_of_week': 'Wednesday',
        'slot_number': 5,
        'start_time': '14:00',
        'end_time': '16:00',
        'subject_code': 'CS306',
        'subject_name': 'Web Technologies Lab',
        'room': 'Lab Room 202',
        'teacher_name': 'Prof. Vikram Mehta',
        'is_lab': true,
      },
      {
        'id': 'ai-6',
        'day_of_week': 'Thursday',
        'slot_number': 1,
        'start_time': '09:00',
        'end_time': '10:00',
        'subject_code': 'CS304',
        'subject_name': 'Formal Language & Automata',
        'room': 'Room 204',
        'teacher_name': 'Dr. M. Roy',
        'is_lab': false,
      },
      {
        'id': 'ai-7',
        'day_of_week': 'Friday',
        'slot_number': 5,
        'start_time': '14:00',
        'end_time': '16:00',
        'subject_code': 'CS301',
        'subject_name': 'Database Management Systems Lab',
        'room': 'Lab Room 301',
        'teacher_name': 'Prof. Rajesh Kumar',
        'is_lab': true,
      },
    ];
  }
}

