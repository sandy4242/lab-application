import 'package:flutter/material.dart';
import '../services/mock_data_service.dart';

class AuthProvider extends ChangeNotifier {
  final MockDataService _dataService = MockDataService();

  bool _isLoading = false;
  Map<String, dynamic>? _userProfile;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  Map<String, dynamic>? get userProfile => _userProfile;
  String? get errorMessage => _errorMessage;

  bool get isAuthenticated => _userProfile != null;
  String? get userId => _userProfile?['id'];
  String? get role => _userProfile?['role'];
  String? get name => _userProfile?['name'];
  String? get token => 'mock-token-session';

  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 250));

    final user = _dataService.authenticate(email, password);
    if (user != null) {
      _userProfile = user;
      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      _errorMessage = 'Invalid email or password. Use test credentials (e.g. student@relab.com / password123)';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signUp({
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
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 300));

    try {
      final newUser = _dataService.registerStudent(
        name: name,
        email: email,
        password: password,
        phone: phone ?? '',
        registrationNumber: registrationNumber ?? '21BCE0000',
        sectionId: sectionId ?? 'sec-cseb',
        teacherGuardianId: teacherGuardianId ?? 'user-tg-1',
      );
      _userProfile = newUser;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 150));
    _userProfile = null;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }
}
