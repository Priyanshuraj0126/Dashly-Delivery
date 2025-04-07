import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Service for handling local storage operations
class StorageService {
  static const String _authTokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const String _phoneNumberKey = 'phone_number';
  static const String _credentialsKey = 'credentials';
  static const String _settingsKey = 'settings';
  static const String _lastActiveKey = 'last_active';
  static const String _sessionTimeoutKey = 'session_timeout';
  static const String _isOnlineKey = 'is_online';
  static const String _currentZoneKey = 'current_zone';
  static const String _fcmTokenKey = 'fcm_token';
  static const String _isProfileCompleteKey = 'is_profile_complete';
  static const String _onboardingCompletedKey = 'onboarding_completed';

  SharedPreferences? _prefs;

  /// Initialize the storage service
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Save authentication token
  Future<void> saveAuthToken(String token) async {
    await _prefs?.setString(_authTokenKey, token);
  }

  /// Get authentication token
  String? getAuthToken() {
    return _prefs?.getString(_authTokenKey);
  }

  /// Remove authentication token
  Future<void> removeAuthToken() async {
    await _prefs?.remove(_authTokenKey);
  }

  /// Save user ID
  Future<void> saveUserId(String userId) async {
    await _prefs?.setString(_userIdKey, userId);
  }

  /// Get user ID
  String? getUserId() {
    return _prefs?.getString(_userIdKey);
  }

  /// Remove user ID
  Future<void> removeUserId() async {
    await _prefs?.remove(_userIdKey);
  }

  /// Save phone number
  Future<void> savePhoneNumber(String phoneNumber) async {
    await _prefs?.setString(_phoneNumberKey, phoneNumber);
  }

  /// Get phone number
  String? getPhoneNumber() {
    return _prefs?.getString(_phoneNumberKey);
  }

  /// Remove phone number
  Future<void> removePhoneNumber() async {
    await _prefs?.remove(_phoneNumberKey);
  }

  /// Save user credentials
  Future<void> saveCredentials(Map<String, dynamic> credentials) async {
    await _prefs?.setString(_credentialsKey, jsonEncode(credentials));
  }

  /// Get user credentials
  Map<String, dynamic>? getCredentials() {
    final credentialsStr = _prefs?.getString(_credentialsKey);
    if (credentialsStr == null) return null;

    try {
      return jsonDecode(credentialsStr) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  /// Save app settings
  Future<void> saveSettings(Map<String, dynamic> settings) async {
    await _prefs?.setString(_settingsKey, jsonEncode(settings));
  }

  /// Get app settings
  Map<String, dynamic> getSettings() {
    final settingsStr = _prefs?.getString(_settingsKey);
    if (settingsStr == null) return {};

    try {
      return jsonDecode(settingsStr) as Map<String, dynamic>;
    } catch (e) {
      return {};
    }
  }

  /// Update last active timestamp
  Future<void> updateLastActiveTimestamp() async {
    await _prefs?.setInt(_lastActiveKey, DateTime.now().millisecondsSinceEpoch);
  }

  /// Get last active timestamp
  int? getLastActiveTimestamp() {
    return _prefs?.getInt(_lastActiveKey);
  }

  /// Save online status
  Future<void> saveOnlineStatus(bool isOnline) async {
    await _prefs?.setBool(_isOnlineKey, isOnline);
  }

  /// Get online status
  bool getOnlineStatus() {
    return _prefs?.getBool(_isOnlineKey) ?? false;
  }

  /// Save current zone
  Future<void> saveCurrentZone(String zoneId) async {
    await _prefs?.setString(_currentZoneKey, zoneId);
  }

  /// Get current zone
  String? getCurrentZone() {
    return _prefs?.getString(_currentZoneKey);
  }

  /// Remove current zone
  Future<void> removeCurrentZone() async {
    await _prefs?.remove(_currentZoneKey);
  }

  /// Save FCM token
  Future<void> saveFcmToken(String token) async {
    await _prefs?.setString(_fcmTokenKey, token);
  }

  /// Get FCM token
  String? getFcmToken() {
    return _prefs?.getString(_fcmTokenKey);
  }

  /// Remove FCM token
  Future<void> removeFcmToken() async {
    await _prefs?.remove(_fcmTokenKey);
  }

  /// Save profile completion status
  Future<void> saveProfileCompletionStatus(bool isComplete) async {
    await _prefs?.setBool(_isProfileCompleteKey, isComplete);
  }

  /// Get profile completion status
  bool getProfileCompletionStatus() {
    return _prefs?.getBool(_isProfileCompleteKey) ?? false;
  }

  /// Save onboarding completion status
  Future<void> saveOnboardingCompletionStatus(bool isCompleted) async {
    await _prefs?.setBool(_onboardingCompletedKey, isCompleted);
  }

  /// Get onboarding completion status
  bool getOnboardingCompletionStatus() {
    return _prefs?.getBool(_onboardingCompletedKey) ?? false;
  }

  /// Clear all stored data
  Future<void> clearAll() async {
    await _prefs?.clear();
  }

  /// Check if session is expired
  bool isSessionExpired({int maxDuration = 24 * 60 * 60 * 1000}) {
    final lastActive = getLastActiveTimestamp();
    if (lastActive == null) return true;

    final now = DateTime.now().millisecondsSinceEpoch;
    final difference = now - lastActive;
    return difference > maxDuration;
  }
}
