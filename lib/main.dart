import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
import 'providers/settings_provider.dart';
import 'config/routes/app_routes.dart';

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

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final prefs = await SharedPreferences.getInstance();

  // Initialize services
  final storageService = StorageService();
  await storageService.init();

  final authService = AuthService();
  final locationService = LocationService();
  final firebaseService = FirebaseService();

  // Initialize repositories
  final authRepository = AuthRepositoryImpl(
    authService: authService,
    firebaseService: firebaseService,
    storageService: storageService,
  );

  final deliveryRepository = DeliveryRepositoryImpl(
    firebaseService: firebaseService,
    locationService: locationService,
  );

  final orderRepository = OrderRepositoryImpl(
    firebaseService: firebaseService,
    messagingService:
        null, // Will be updated after FirebaseMessagingService is created
  );

  final userRepository = UserRepository(
    firebaseService: firebaseService,
  );

  // Initialize blocs
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

  // Initialize Firebase Messaging Service after all dependencies are created
  final firebaseMessagingService = FirebaseMessagingService(
    orderRepository: orderRepository,
    authRepository: authRepository,
    orderBloc: orderBloc,
  );
  await firebaseMessagingService.initialize();

  // Update the order repository with the messaging service
  orderRepository.updateMessagingService(firebaseMessagingService);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => SettingsProvider(prefs),
        ),
        BlocProvider<AuthBloc>(create: (context) => authBloc),
        BlocProvider<LocationBloc>(create: (context) => locationBloc),
        BlocProvider<OrderBloc>(create: (context) => orderBloc),
      ],
      child: const MyApp(),
    ),
  );
}

/// Main application widget
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        return MaterialApp(
          title: 'Dashly Delivery',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              secondary: AppColors.secondary,
              error: AppColors.error,
              surface: AppColors.background,
              onPrimary: Colors.white,
              onSecondary: Colors.white,
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
          ),
          locale: Locale(settings.selectedLanguage),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'), // English
            Locale('hi'), // Hindi
            Locale('mr'), // Marathi
          ],
          onGenerateRoute: AppRoutes.generateRoute,
          home: const SplashScreen(),
        );
      },
    );
  }
}
