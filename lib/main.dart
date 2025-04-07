import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'core/constants/app_colors.dart';
import 'core/services/auth/auth_service.dart';
import 'core/services/firebase/firebase_messaging_service.dart';
import 'core/services/firebase/firebase_service.dart';
import 'core/services/location/location_service.dart';
import 'core/services/storage/storage_service.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/delivery_repository_impl.dart';
import 'data/repositories/order_repository_impl.dart';
import 'data/repositories/user_repository.dart';
import 'firebase_options.dart';
import 'presentation/blocs/auth/auth_bloc.dart';
import 'presentation/blocs/location/location_bloc.dart';
import 'presentation/blocs/order/order_bloc.dart';
import 'presentation/screens/splash/splash_screen.dart';

// Global initialization of notification channel for background messages
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// Background message handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Initialize Firebase (required to use any Firebase products in background isolate)
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Add logging to trace background notifications
  debugPrint('Handling a background message: ${message.messageId}');
  debugPrint('Message data: ${message.data}');

  // Show a notification to alert the user that an order has been received
  final notificationsPlugin = FlutterLocalNotificationsPlugin();

  // Initialize the plugin
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings(
    requestSoundPermission: true,
    requestBadgePermission: true,
    requestAlertPermission: true,
  );

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );

  await notificationsPlugin.initialize(initializationSettings);

  // Create a notification channel for Android
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.high,
  );

  await notificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  // Show notification
  if (message.notification != null) {
    await notificationsPlugin.show(
      message.notification.hashCode,
      message.notification?.title ?? 'New Order',
      message.notification?.body ?? 'You have a new order request',
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          icon: '@mipmap/ic_launcher',
          importance: Importance.high,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Set up background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Initialize services
  final storageService = StorageService();
  await storageService.init();

  final firebaseService = FirebaseService();
  final authService = AuthService();
  final locationService = LocationService();

  // Initialize repositories
  final userRepository = UserRepository(firebaseService: firebaseService);
  final authRepository = AuthRepositoryImpl(
    authService: authService,
    firebaseService: firebaseService,
    storageService: storageService,
  );
  final orderRepository = OrderRepositoryImpl(
    firebaseService: firebaseService,
  );
  final deliveryRepository = DeliveryRepositoryImpl(
    firebaseService: firebaseService,
    locationService: locationService,
  );

  // Create BLoCs
  final authBloc = AuthBloc(
    authService: authService,
    storageService: storageService,
    userRepository: userRepository,
  );

  final locationBloc = LocationBloc(
    locationService: locationService,
    deliveryRepository: deliveryRepository,
  );

  final orderBloc = OrderBloc(
    orderRepository: orderRepository,
    deliveryRepository: deliveryRepository,
  );

  // Initialize Firebase Messaging Service
  final firebaseMessagingService = FirebaseMessagingService(
    orderRepository: orderRepository,
    authRepository: authRepository,
    orderBloc: orderBloc,
  );
  await firebaseMessagingService.initialize();

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthService>(
          create: (context) => authService,
        ),
        RepositoryProvider<StorageService>(
          create: (context) => storageService,
        ),
        RepositoryProvider<FirebaseService>(
          create: (context) => firebaseService,
        ),
        RepositoryProvider<LocationService>(
          create: (context) => locationService,
        ),
        RepositoryProvider<UserRepository>(
          create: (context) => userRepository,
        ),
        RepositoryProvider<OrderRepositoryImpl>(
          create: (context) => orderRepository,
        ),
        RepositoryProvider<DeliveryRepositoryImpl>(
          create: (context) => deliveryRepository,
        ),
        RepositoryProvider<FirebaseMessagingService>(
          create: (context) => firebaseMessagingService,
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) => authBloc,
          ),
          BlocProvider<LocationBloc>(
            create: (context) => locationBloc,
          ),
          BlocProvider<OrderBloc>(
            create: (context) => orderBloc,
          ),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

/// Main application widget
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dashly Delivery',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          background: AppColors.background,
          surface: AppColors.surface,
          error: AppColors.error,
        ),
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.primary,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          titleTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
        fontFamily: 'Poppins',
        textTheme: TextTheme(
          displayLarge: TextStyle(color: AppColors.textPrimary),
          displayMedium: TextStyle(color: AppColors.textPrimary),
          displaySmall: TextStyle(color: AppColors.textPrimary),
          headlineLarge: TextStyle(color: AppColors.textPrimary),
          headlineMedium: TextStyle(color: AppColors.textPrimary),
          headlineSmall: TextStyle(color: AppColors.textPrimary),
          titleLarge: TextStyle(color: AppColors.textPrimary),
          titleMedium: TextStyle(color: AppColors.textPrimary),
          titleSmall: TextStyle(color: AppColors.textPrimary),
          bodyLarge: TextStyle(color: AppColors.textPrimary),
          bodyMedium: TextStyle(color: AppColors.textPrimary),
          bodySmall: TextStyle(color: AppColors.textSecondary),
          labelLarge: TextStyle(color: AppColors.textPrimary),
          labelMedium: TextStyle(color: AppColors.textPrimary),
          labelSmall: TextStyle(color: AppColors.textSecondary),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            textStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: AppColors.divider),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: AppColors.divider),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: AppColors.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: AppColors.error),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: AppColors.error, width: 2),
          ),
          fillColor: Colors.white,
          filled: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          labelStyle: TextStyle(color: AppColors.textSecondary),
          hintStyle: TextStyle(color: AppColors.textHint),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
