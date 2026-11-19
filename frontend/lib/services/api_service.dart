import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiConfig {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:5000/api';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:5000/api';
    } else {
      return 'http://localhost:5000/api';
    }
  }
}

class ApiService {
  final String _baseUrl = ApiConfig.baseUrl;

  Map<String, String> _getHeaders(String token) {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> getProfile(String token) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/auth/profile'),
      headers: _getHeaders(token),
    );
    return _parseResponse(response);
  }

  Future<Map<String, dynamic>> updateProfile(String token, String name, String phone) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/auth/profile'),
      headers: _getHeaders(token),
      body: jsonEncode({
        'name': name,
        'phone': phone,
      }),
    );
    return _parseResponse(response);
  }

  Future<Map<String, dynamic>> createRequest(String token, Map<String, dynamic> requestData) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/requests'),
      headers: _getHeaders(token),
      body: jsonEncode(requestData),
    );
    return _parseResponse(response);
  }

  Future<List<dynamic>> getRequests(String token) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/requests'),
      headers: _getHeaders(token),
    );
    final data = _parseResponse(response);
    if (data.containsKey('requests')) {
      return data['requests'];
    }
    return [];
  }

  Future<Map<String, dynamic>> approveRequest(
    String token,
    String requestId,
    String status,
    String remarks,
  ) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/requests/$requestId/approve'),
      headers: _getHeaders(token),
      body: jsonEncode({
        'status': status,
        'remarks': remarks,
      }),
    );
    return _parseResponse(response);
  }

  Future<List<dynamic>> getMatchingSlots(String token, String requestId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/requests/$requestId/matches'),
      headers: _getHeaders(token),
    );
    final data = _parseResponse(response);
    if (data.containsKey('matches')) {
      return data['matches'];
    }
    return [];
  }

  Future<Map<String, dynamic>> bookSlot(
    String token,
    String requestId,
    String timetableId,
    String date,
  ) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/requests/$requestId/book'),
      headers: _getHeaders(token),
      body: jsonEncode({
        'timetableId': timetableId,
        'date': date,
      }),
    );
    return _parseResponse(response);
  }

  Future<Map<String, dynamic>> completeSession(
    String token,
    String requestId,
    String remarks,
  ) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/requests/$requestId/complete'),
      headers: _getHeaders(token),
      body: jsonEncode({
        'remarks': remarks,
      }),
    );
    return _parseResponse(response);
  }

  Future<Map<String, dynamic>> getDashboardStats(String token) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/dashboard/stats'),
      headers: _getHeaders(token),
    );
    return _parseResponse(response);
  }

  Future<Map<String, dynamic>> sendMessageToAI(String token, String message) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/ai/chat'),
      headers: _getHeaders(token),
      body: jsonEncode({
        'message': message,
      }),
    );
    return _parseResponse(response);
  }

  Future<Map<String, dynamic>> getRoutine(String token) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/routine'),
      headers: _getHeaders(token),
    );
    return _parseResponse(response);
  }

  Future<Map<String, dynamic>> saveRoutine(String token, List<dynamic> slots) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/routine'),
      headers: _getHeaders(token),
      body: jsonEncode({
        'slots': slots,
      }),
    );
    return _parseResponse(response);
  }

  Future<Map<String, dynamic>> parseRoutineAI(
    String token, {
    String? imageBase64,
    String? mimeType,
    String? rawText,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/routine/parse-ai'),
      headers: _getHeaders(token),
      body: jsonEncode({
        if (imageBase64 != null) 'imageBase64': imageBase64,
        if (mimeType != null) 'mimeType': mimeType,
        if (rawText != null) 'rawText': rawText,
      }),
    );
    return _parseResponse(response);
  }

  Future<Map<String, dynamic>> resetRoutine(String token) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/routine'),
      headers: _getHeaders(token),
    );
    return _parseResponse(response);
  }

  Map<String, dynamic> _parseResponse(http.Response response) {
    final body = response.body;
    try {
      final decoded = jsonDecode(body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return decoded is Map ? decoded as Map<String, dynamic> : {'data': decoded};
      } else {
        throw HttpException(decoded['error'] ?? 'Request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      if (e is HttpException) rethrow;
      throw HttpException('Server returned invalid JSON format: $body');
    }
  }
}

class HttpException implements Exception {
  final String message;
  HttpException(this.message);
  @override
  String toString() => message;
}
