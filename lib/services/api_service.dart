import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  // Ganti dengan IP mesin backend kamu
  static const String baseUrl = "http://localhost:8000";

  // ── Auth ──────────────────────────────────────────────────
  static Future<Map<String, dynamic>> login(
      String employeeId, String password) async {
    final res = await http
        .post(
          Uri.parse("$baseUrl/auth/login"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"employee_id": employeeId, "password": password}),
        )
        .timeout(
          // ← tambahkan ini
          const Duration(seconds: 10),
          onTimeout: () =>
              throw Exception('Server tidak merespons. Cek koneksi.'),
        );
    if (res.statusCode != 200) throw Exception(jsonDecode(res.body)['detail']);
    final data = jsonDecode(res.body);

    debugPrint('Login response keys: ${data.keys}');
    debugPrint('employee_id value: ${data['employee_id']}');

    // Simpan token + role
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', data['access_token']);
    await prefs.setString('role', data['role']);
    await prefs.setString('name', data['name']);
    await prefs.setString('unit', data['unit'] ?? '');
    await prefs.setString('employee_id', data['employee_id'] ?? '');
    return data;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<Map<String, String>> authHeaders() async {
    final token = await _getToken();
    return {
      "Content-Type": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };
  }

  // ── Update FCM token ke backend ───────────────────────────
  static Future<void> updateFcmToken(String fcmToken) async {
    final headers = await authHeaders();
    await http.put(
      Uri.parse("$baseUrl/auth/fcm-token?token=$fcmToken"),
      headers: headers,
    );
  }

  // ── Dashboard (home screen) ───────────────────────────────
  static Future<Map<String, dynamic>> getDashboard() async {
    final headers = await authHeaders();
    final res = await http.get(
      Uri.parse("$baseUrl/dashboard/live"),
      headers: headers,
    );
    if (res.statusCode != 200) throw Exception('Gagal load dashboard');
    return jsonDecode(res.body);
  }

  // ── Alerts ────────────────────────────────────────────────
  static Future<List<dynamic>> getAlerts({String? status}) async {
    final headers = await authHeaders();
    final uri = Uri.parse("$baseUrl/alerts").replace(
      queryParameters: {if (status != null) 'status': status},
    );
    final res = await http.get(uri, headers: headers);
    if (res.statusCode != 200) throw Exception('Gagal load alerts');
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> acknowledgeAlert(int alertId) async {
    final headers = await authHeaders();
    final res = await http.post(
      Uri.parse("$baseUrl/alerts/$alertId/acknowledge"),
      headers: headers,
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> resolveAlert(int alertId) async {
    final headers = await authHeaders();
    final res = await http.post(
      Uri.parse("$baseUrl/alerts/$alertId/resolve"),
      headers: headers,
    );
    return jsonDecode(res.body);
  }

  // Supervisor only
  static Future<Map<String, dynamic>> escalateAlert(int alertId) async {
    final headers = await authHeaders();
    final res = await http.post(
      Uri.parse("$baseUrl/alerts/$alertId/escalate"),
      headers: headers,
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> assignAlert(
      int alertId, int userId) async {
    final headers = await authHeaders();
    final res = await http.post(
      Uri.parse("$baseUrl/alerts/$alertId/assign"),
      headers: headers,
      body: jsonEncode({"user_id": userId}),
    );
    return jsonDecode(res.body);
  }

  // ── Drift (supervisor only) ───────────────────────────────
  static Future<Map<String, dynamic>> getDriftStatus() async {
    final headers = await authHeaders();
    final res = await http.get(
      Uri.parse("$baseUrl/drift/status"),
      headers: headers,
    );
    if (res.statusCode != 200) throw Exception('Gagal load drift');
    return jsonDecode(res.body);
  }

  // ── History ───────────────────────────────────────────────
  static Future<Map<String, dynamic>> getHistory() async {
    final headers = await authHeaders();
    final res = await http.get(
      Uri.parse("$baseUrl/history"),
      headers: headers,
    );
    if (res.statusCode != 200) throw Exception('Gagal load history');
    return jsonDecode(res.body);
  }

  // ── Predict (opsional, kalau ada sensor feed langsung) ────
  static Future<Map<String, dynamic>> predict(
      List<double> xmeas, List<double> xmv, String unit) async {
    final headers = await authHeaders();
    final res = await http.post(
      Uri.parse("$baseUrl/predict"),
      headers: headers,
      body: jsonEncode({"xmeas": xmeas, "xmv": xmv, "unit": unit}),
    );
    return jsonDecode(res.body);
  }

  static Future<List<dynamic>> getActiveAlerts() async {
    final headers = await authHeaders();
    // Fetch active + acknowledged
    final results = await Future.wait([
      http.get(Uri.parse("$baseUrl/alerts?status=active"), headers: headers),
      http.get(Uri.parse("$baseUrl/alerts?status=acknowledged"),
          headers: headers),
    ]);
    final active = jsonDecode(results[0].body) as List;
    final acknowledged = jsonDecode(results[1].body) as List;
    return [...active, ...acknowledged];
  }

  static Future<SharedPreferences> getPrefs() async {
    return await SharedPreferences.getInstance();
  }
}
