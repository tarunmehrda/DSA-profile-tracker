import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/dashboard_data.dart';
import '../models/user_profile.dart';

class ApiService {
  // Use the computer's actual local IP for physical device testing
  static const String baseUrl = 'http://localhost:5000/api';

  Future<UserProfile> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 15));

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return UserProfile.fromJson(responseData['data']);
      } else {
        throw Exception(responseData['message'] ?? 'Failed to login');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<UserProfile> register(String name, String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'name': name,
        'email': email,
        'password': password,
      }),
    );

    final responseData = json.decode(response.body);

    if (response.statusCode == 201) {
      return UserProfile.fromJson(responseData['data']);
    } else {
      throw Exception(responseData['message'] ?? 'Failed to register');
    }
  }

  Future<DashboardData> fetchDashboardData(String userId, String token) async {
    try {
      print('ApiService: GET $baseUrl/dashboard/$userId');
      final response = await http.get(
        Uri.parse('$baseUrl/dashboard/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 60));

      print('ApiService: Response status ${response.statusCode}');
      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return DashboardData.fromJson(responseData['data']);
      } else {
        throw Exception(responseData['message'] ?? 'Failed to fetch dashboard data');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<DashboardData> refreshDashboardData(String userId, String token) async {
    try {
      print('ApiService: POST $baseUrl/dashboard/$userId/refresh');
      final response = await http.post(
        Uri.parse('$baseUrl/dashboard/$userId/refresh'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 120)); // Longer timeout for fresh scrape

      print('ApiService: Refresh response status ${response.statusCode}');
      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return DashboardData.fromJson(responseData['data']);
      } else {
        throw Exception(responseData['message'] ?? 'Failed to refresh dashboard data');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateUsernames(
    String userId,
    String token, {
    String? leetcodeUsername,
    String? codeforcesUsername,
    String? codechefUsername,
    String? gfgUsername,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/auth/usernames/$userId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        if (leetcodeUsername != null) 'leetcodeUsername': leetcodeUsername,
        if (codeforcesUsername != null) 'codeforcesUsername': codeforcesUsername,
        if (codechefUsername != null) 'codechefUsername': codechefUsername,
        if (gfgUsername != null) 'gfgUsername': gfgUsername,
      }),
    );

    if (response.statusCode != 200) {
      final responseData = json.decode(response.body);
      throw Exception(responseData['message'] ?? 'Failed to update usernames');
    }
  }

  Future<List<Map<String, dynamic>>> fetchLeaderboard(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/dashboard/leaderboard'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final responseData = json.decode(response.body);

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(responseData['data']);
    } else {
      throw Exception(responseData['message'] ?? 'Failed to fetch leaderboard');
    }
  }

  Future<Map<String, dynamic>> compareUsers(String token, String user1Id, String user2Id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/dashboard/compare?user1Id=$user1Id&user2Id=$user2Id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final responseData = json.decode(response.body);

    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(responseData['data']);
    } else {
      throw Exception(responseData['message'] ?? 'Failed to compare users');
    }
  }
}
