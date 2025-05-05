import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../../data/repositories/auth_repository_impl.dart';
import '../../../data/repositories/order_repository_impl.dart';
import '../../../presentation/blocs/order/order_bloc.dart';
import '../../../core/services/storage/storage_service.dart';
import '../../../core/services/firebase/firebase_service.dart';

/// Service for handling Firebase Cloud Messaging
class FirebaseMessagingService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final OrderRepositoryImpl _orderRepository;
  final AuthRepositoryImpl _authRepository;
  final OrderBloc _orderBloc;
  final StorageService _storageService;
  final FirebaseService _firebaseService;

  // Stream controller for order notifications
  final StreamController<Map<String, dynamic>> _orderNotificationController =
      StreamController<Map<String, dynamic>>.broadcast();

  // Getter for the order notification stream
  Stream<Map<String, dynamic>> get orderNotifications =>
      _orderNotificationController.stream;

  // Android notification channel details
  final AndroidNotificationChannel _channel = const AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.high,
  );

  FirebaseMessagingService({
    required OrderRepositoryImpl orderRepository,
    required AuthRepositoryImpl authRepository,
    required OrderBloc orderBloc,
    required StorageService storageService,
    required FirebaseService firebaseService,
  })  : _orderRepository = orderRepository,
        _authRepository = authRepository,
        _orderBloc = orderBloc,
        _storageService = storageService,
        _firebaseService = firebaseService;

  /// Initialize the FCM service
  Future<void> initialize() async {
    try {
      // Request permission
      await _requestPermission();

      // Configure notification channels for Android
      await _configureLocalNotifications();

      // Get FCM token and save it
      await refreshToken();

      // Listen for token refreshes
      _firebaseMessaging.onTokenRefresh.listen((token) {
        _updateToken(token);
      });

      // Handle background/terminated messages
      FirebaseMessaging.onBackgroundMessage(
          _firebaseMessagingBackgroundHandler);

      // Handle messages when app is in foreground
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle when user taps on notification and app is in background
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

      // Check if app was opened from a notification when app was terminated
      await _checkInitialMessage();

      debugPrint('Firebase Cloud Messaging initialized successfully');
    } catch (e) {
      debugPrint('Error initializing Firebase Cloud Messaging: $e');
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

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  /// Handle when notification is tapped
  void _onNotificationTapped(NotificationResponse response) {
    if (response.payload == null) return;

    try {
      final data = json.decode(response.payload!) as Map<String, dynamic>;
      if (data.containsKey('orderId')) {
        // Fetch order details
        _fetchOrderDetails(data['orderId'] as String);
      }
    } catch (e) {
      debugPrint('Error handling notification tap: $e');
    }
  }

  /// Check if app was opened from a notification
  Future<void> _checkInitialMessage() async {
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      await _processOrderNotification(initialMessage);
    }
  }

  /// Handle foreground messages
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    debugPrint('Got a message in foreground!');
    debugPrint('Message data: ${message.data}');

    if (message.notification != null) {
      debugPrint(
          'Message also contained a notification: ${message.notification?.title}');

      // Show local notification
      await _showLocalNotification(message);

      // Process message data
      await _processOrderNotification(message);
    }
  }

  /// Handle when app is opened from notification
  Future<void> _handleMessageOpenedApp(RemoteMessage message) async {
    debugPrint('A new onMessageOpenedApp event was published!');
    debugPrint('Message data: ${message.data}');

    // Process message data
    await _processOrderNotification(message);
  }

  /// Process order notification
  Future<void> _processOrderNotification(RemoteMessage message) async {
    final data = message.data;

    // Check if this is an order-related notification
    if (data.containsKey('type')) {
      String notificationType = data['type'];

      if (notificationType == 'new_order' ||
          notificationType == 'order_request') {
        if (data.containsKey('orderId')) {
          String orderId = data['orderId'] as String;

          // Create a notification document in delivery_notifications collection
          try {
            await _firebaseService.addDocument(
              'delivery_notifications',
              {
                'orderId': orderId,
                'type': notificationType,
                'created_at': FieldValue.serverTimestamp(),
                'data': data,
              },
            );
          } catch (e) {
            debugPrint('Error creating delivery notification: $e');
          }

          // Fetch order details and refresh active orders
          await _fetchOrderDetails(orderId);
          _orderBloc.add(FetchActiveOrdersEvent());
        }
      }
    }
  }

  /// Show local notification
  Future<void> _showLocalNotification(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null && !kIsWeb) {
      await _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channel.id,
            _channel.name,
            channelDescription: _channel.description,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        payload: json.encode(message.data),
      );
    }
  }

  /// Fetch order details
  Future<void> _fetchOrderDetails(String orderId) async {
    _orderBloc.add(FetchOrderDetailsEvent(orderId: orderId));
  }

  /// Refreshes FCM token and saves it
  Future<String?> refreshToken() async {
    try {
      final token = await _firebaseMessaging.getToken();
      debugPrint('FCM Token: $token');

      if (token != null) {
        await _updateToken(token);
      }

      return token;
    } catch (e) {
      debugPrint('Error refreshing FCM token: $e');
      return null;
    }
  }

  /// Updates token in Firestore
  Future<void> _updateToken(String token) async {
    try {
      // Get the stored token to compare
      final storedToken = _storageService.getFcmToken();

      // Only update if the token has changed
      if (storedToken != token) {
        await _authRepository.updateFcmToken(token);
        await _storageService.saveFcmToken(token);
        debugPrint('FCM token updated successfully');
      } else {
        debugPrint('FCM token unchanged, skipping update');
      }
    } catch (e) {
      debugPrint('Error updating FCM token: $e');
    }
  }

  /// Dispose resources
  void dispose() {
    _orderNotificationController.close();
  }
}

/// Background message handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Need to initialize Firebase here if using other Firebase services
  debugPrint('Handling a background message: ${message.messageId}');
}
