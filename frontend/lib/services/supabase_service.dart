import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final SupabaseClient client = Supabase.instance.client;

  Session? get currentSession => client.auth.currentSession;
  User? get currentUser => client.auth.currentUser;
  String? get accessToken => currentSession?.accessToken;

  Future<AuthResponse> signIn(String email, String password) async {
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String name,
    required String role,
    String? phone,
    String? registrationNumber,
    String? sectionId,
    String? teacherGuardianId,
    String? departmentId,
  }) async {
    final Map<String, dynamic> metadata = {
      'name': name,
      'role': role,
    };
    if (phone != null && phone.isNotEmpty) metadata['phone'] = phone;
    if (registrationNumber != null && registrationNumber.isNotEmpty) {
      metadata['registration_number'] = registrationNumber;
    }
    if (sectionId != null && sectionId.isNotEmpty) {
      metadata['section_id'] = sectionId;
    }
    if (teacherGuardianId != null && teacherGuardianId.isNotEmpty) {
      metadata['teacher_guardian_id'] = teacherGuardianId;
    }
    if (departmentId != null && departmentId.isNotEmpty) {
      metadata['department_id'] = departmentId;
    }

    return await client.auth.signUp(
      email: email,
      password: password,
      data: metadata,
    );
  }

  Future<void> signOut() async {
    await client.auth.signOut();
  }
}
