import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/patient_model.dart';
import '../models/screening_model.dart';
import '../models/referral_model.dart';

class ApiService {
  final String baseUrl;
  String? authToken;

  ApiService({this.baseUrl = 'http://10.0.2.2:8000/api/v1'}); // Android emulator localhost alias

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (authToken != null) 'Authorization': 'Bearer $authToken',
      };

  Future<Map<String, dynamic>?> login(String username, String password) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        authToken = data['access_token'];
        return data;
      }
    } catch (_) {
      // Offline fallback
    }
    return null;
  }

  Future<bool> syncBatch({
    required List<PatientModel> patients,
    required List<ScreeningModel> screenings,
    required List<ReferralModel> referrals,
  }) async {
    try {
      final payload = {
        'client_timestamp': DateTime.now().toIso8601String(),
        'patients': patients.map((p) => p.toMap()).toList(),
        'screenings': screenings.map((s) => s.toMap()).toList(),
        'referrals': referrals.map((r) => r.toMap()).toList(),
      };

      final res = await http.post(
        Uri.parse('$baseUrl/sync'),
        headers: _headers,
        body: jsonEncode(payload),
      );
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<bool> resetDemoData() async {
    try {
      final res = await http.post(Uri.parse('$baseUrl/demo/reset'), headers: _headers);
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
