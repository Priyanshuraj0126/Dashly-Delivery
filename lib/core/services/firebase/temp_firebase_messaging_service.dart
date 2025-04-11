import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../../core/services/auth/auth_service.dart';
import '../../../core/services/firebase/firebase_service.dart';
import '../../../core/services/location/location_service.dart';
import '../../../core/services/storage/storage_service.dart';
import '../../../data/repositories/auth_repository_impl.dart';
import '../../../data/repositories/delivery_repository_impl.dart';
import '../../../data/repositories/order_repository_impl.dart';
import '../../../presentation/blocs/order/order_bloc.dart';
import 'firebase_messaging_service.dart';

/// Temporary Firebase Messaging Service for initialization
/// This is used to break circular dependencies during app initialization
class TempFirebaseMessagingService extends FirebaseMessagingService {
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

  TempFirebaseMessagingService()
      : super(
          orderRepository: OrderRepositoryImpl(
            firebaseService: FirebaseService(),
            messagingService: null,
          ),
          authRepository: AuthRepositoryImpl(
            authService: AuthService(),
            firebaseService: FirebaseService(),
            storageService: StorageService(),
          ),
          orderBloc: OrderBloc(
            orderRepository: OrderRepositoryImpl(
              firebaseService: FirebaseService(),
              messagingService: null,
            ),
            deliveryRepository: DeliveryRepositoryImpl(
              firebaseService: FirebaseService(),
              locationService: LocationService(),
            ),
          ),
        );

  @override
  Future<void> initialize() async {
    try {
      // Request permission
      await _requestPermission();

      // Configure notification channels for Android
      await _configureLocalNotifications();

      debugPrint('Temporary Firebase Cloud Messaging initialized successfully');
    } catch (e) {
      debugPrint('Error initializing Temporary Firebase Cloud Messaging: $e');
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
}
