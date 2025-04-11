import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Null implementation of Firebase Messaging Service for initialization
/// This is used to break circular dependencies during app initialization
class NullMessagingService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // Android notification channel details
  final AndroidNotificationChannel _channel = const AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.high,
  );

  /// Initialize the FCM service
  Future<void> initialize() async {
    try {
      // Request permission
      await _requestPermission();

      // Configure notification channels for Android
      await _configureLocalNotifications();

      debugPrint('Null Firebase Cloud Messaging initialized successfully');
    } catch (e) {
      debugPrint('Error initializing Null Firebase Cloud Messaging: $e');
    }
  }

  /// Request notification permissions
  Future<void> _requestPermission() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    debugPrint(
        'User granted notification permission: ${settings.authorizationStatus}');
  }

  /// Configure local notifications
  Future<void> _configureLocalNotifications() async {
    // Configure Android notification channel
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    // Configure initial settings
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _localNotifications.initialize(initializationSettings);
  }

  /// Refreshes FCM token and saves it
  Future<String?> refreshToken() async {
    try {
      final token = await _firebaseMessaging.getToken();
      debugPrint('FCM Token: $token');
      return token;
    } catch (e) {
      debugPrint('Error refreshing FCM token: $e');
      return null;
    }
  }

  /// Dispose resources
  void dispose() {
    // No resources to dispose
  }
}
