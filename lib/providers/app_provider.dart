import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user_profile.dart';
import '../models/dashboard_data.dart';
import '../services/api_service.dart';

class AppProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  UserProfile? _userProfile;
  DashboardData? _dashboardData;
  List<Map<String, dynamic>>? _leaderboard;
  bool _isLoading = false;
  String? _error;

  UserProfile? get userProfile => _userProfile;
  DashboardData? get dashboardData => _dashboardData;
  List<Map<String, dynamic>>? get leaderboard => _leaderboard;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _userProfile != null && _userProfile!.token != null;

  // Initialize app - load saved user data
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user_profile');
    
    if (userJson != null) {
      final profile = UserProfile.fromJson(json.decode(userJson));
      
      if (profile.token == null) {
        await prefs.remove('user_profile');
        _userProfile = null;
      } else {
        _userProfile = profile;
        notifyListeners();
        
        // Auto-fetch dashboard data if usernames are set
        if (_hasUsernames()) {
          await fetchDashboardData();
        }
      }
    } else {
      // No user profile found
    }
  }

  // Login user
  Future<void> login(String email, String name) async {
    print('AppProvider: Login attempt for $email');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('AppProvider: Calling ApiService.login...');
      // Try to login first, if fails, register
      try {
        _userProfile = await _apiService.login(email, 'password123');
        print('AppProvider: Login successful');
      } catch (e) {
        print('AppProvider: Login failed, trying registration: $e');
        // If login fails, try to register
        _userProfile = await _apiService.register(name, email, 'password123');
        print('AppProvider: Registration successful');
      }
      
      await _saveUserProfile();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('AppProvider: Final login error: $e');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update platform usernames
  Future<void> updateUsernames({
    String? leetcodeUsername,
    String? codeforcesUsername,
    String? codechefUsername,
    String? gfgUsername,
  }) async {
    if (_userProfile == null) {
      print('AppProvider: Cannot update usernames, user not logged in.');
      return;
    }

    print('AppProvider: Updating usernames for user ID: ${_userProfile!.id}');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _apiService.updateUsernames(
        _userProfile!.id,
        _userProfile!.token!,
        leetcodeUsername: leetcodeUsername,
        codeforcesUsername: codeforcesUsername,
        codechefUsername: codechefUsername,
        gfgUsername: gfgUsername,
      );

      _userProfile = _userProfile!.copyWith(
        leetcodeUsername: leetcodeUsername,
        codeforcesUsername: codeforcesUsername,
        codechefUsername: codechefUsername,
        gfgUsername: gfgUsername,
      );

      await _saveUserProfile();
      
      // Fetch fresh dashboard data
      await fetchDashboardData();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch dashboard data
  Future<void> fetchDashboardData() async {
    if (_userProfile == null || _userProfile!.token == null || _isLoading) {
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('AppProvider: Starting to fetch dashboard data...');
      _dashboardData = await _apiService.fetchDashboardData(
        _userProfile!.id,
        _userProfile!.token!,
      );
      
      print('AppProvider: Dashboard data fetched successfully');
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('AppProvider: Error fetching dashboard data: $e');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Force refresh dashboard data
  Future<void> refreshDashboardData() async {
    if (_userProfile == null || _userProfile!.token == null || _isLoading) {
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('AppProvider: Starting to refresh dashboard data...');
      _dashboardData = await _apiService.refreshDashboardData(
        _userProfile!.id,
        _userProfile!.token!,
      );
      
      print('AppProvider: Dashboard data refreshed successfully');
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('AppProvider: Error refreshing dashboard data: $e');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch leaderboard
  Future<void> fetchLeaderboard() async {
    if (_userProfile == null || _userProfile!.token == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      _leaderboard = await _apiService.fetchLeaderboard(_userProfile!.token!);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Compare with another user
  Future<Map<String, dynamic>> compareWithUser(String targetUserId) async {
    if (_userProfile == null || _userProfile!.token == null) {
      throw Exception('Not logged in');
    }
    return await _apiService.compareUsers(_userProfile!.token!, _userProfile!.id, targetUserId);
  }

  // Logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    
    _userProfile = null;
    _dashboardData = null;
    _error = null;
    notifyListeners();
  }

  // Save user profile to local storage
  Future<void> _saveUserProfile() async {
    if (_userProfile == null) return;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_profile', json.encode(_userProfile!.toJson()));
  }

  // Check if user has set usernames
  bool _hasUsernames() {
    return _userProfile?.leetcodeUsername != null ||
        _userProfile?.codeforcesUsername != null ||
        _userProfile?.codechefUsername != null ||
        _userProfile?.gfgUsername != null;
  }
}
