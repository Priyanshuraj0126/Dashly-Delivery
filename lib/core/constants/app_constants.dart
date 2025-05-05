/// This class contains all the constants used throughout the application
class AppConstants {
  // App Info
  static const String appName = 'Dashly Delivery';
  static const String appVersion = '1.0.0';
  static const int appBuildNumber = 1;
  static const String packageName = 'com.hilwitz.dashly_delivery';

  // Firestore Collections
  static const String usersCollection = 'users';
  static const String deliveryBoysCollection = 'delivery_boys';
  static const String ordersCollection = 'orders';
  static const String storesCollection = 'stores';
  static const String zonesCollection = 'zones';
  static const String earningsCollection = 'earnings';

  // Order Status
  static const String orderStatusAssigned = 'assigned';
  static const String orderStatusOnTheWayToPickup = 'on_the_way_to_pickup';
  static const String orderStatusArrivedAtPickup = 'arrived_at_pickup';
  static const String orderStatusPickedUp = 'picked_up';
  static const String orderStatusOutForDelivery = 'out_for_delivery';
  static const String orderStatusArrivedAtDelivery = 'arrived_at_delivery';
  static const String orderStatusDelivered = 'delivered';
  static const String orderStatusCompleted = 'completed';

  // Delivery Boy Status
  static const String deliveryBoyStatusOnline = 'online';
  static const String deliveryBoyStatusOffline = 'offline';
  static const String deliveryBoyStatusBusy = 'busy';
  static const String deliveryBoyStatusOnBreak = 'on_break';

  // Payment Methods
  static const String paymentMethodCOD = 'COD';
  static const String paymentMethodOnline = 'online';

  // Payment Status
  static const String paymentStatusPending = 'pending';
  static const String paymentStatusCollected = 'collected';
  static const String paymentStatusVerified = 'verified';

  // Shared Preferences Keys
  static const String tokenKey = 'token';
  static const String userIdKey = 'userId';
  static const String userPhoneKey = 'userPhone';
  static const String fcmTokenKey = 'fcmToken';
  static const String onboardingCompleteKey = 'onboardingComplete';
  static const String languageCodeKey = 'languageCode';
  static const String themeKey = 'theme';

  // Notification Channels
  static const String orderNotificationChannelId = 'order_notification_channel';
  static const String orderNotificationChannelName = 'Order Notifications';
  static const String orderNotificationChannelDesc =
      'Notifications for new orders and updates';

  // Timeouts
  static const int locationUpdateIntervalSeconds = 30;
  static const int orderAcceptTimeoutSeconds = 30;
  static const int sessionTimeoutMinutes = 60;
  static const int maxSimultaneousOrders = 3;

  // Map Constants
  static const double defaultZoomLevel = 15.0;
  static const int locationUpdateIntervalMillis = 5000;
  static const int locationFastestIntervalMillis = 3000;
  static const double locationSmallestDisplacementMeters = 10.0;

  // UI Constants
  static const double borderRadius = 12.0;
  static const double buttonHeight = 50.0;
  static const double inputHeight = 56.0;
  static const double spacing = 16.0;
  static const double smallSpacing = 8.0;
  static const double largeSpacing = 24.0;

  // Asset Paths
  static const String logoPath = 'assets/images/logo.png';
  static const String placeholderUserImage =
      'assets/images/user_placeholder.png';
  static const String placeholderStoreImage =
      'assets/images/store_placeholder.png';

  // Error Messages
  static const String networkErrorMessage =
      'Unable to connect to the internet. Please check your connection and try again.';
  static const String serverErrorMessage =
      'Something went wrong on our end. Please try again later.';
  static const String unknownErrorMessage =
      'An unexpected error occurred. Please try again later.';
  static const String locationPermissionDeniedMessage =
      'Location permission is required to use this app.';

  // Api timeouts
  static const int connectionTimeout = 30000;
  static const int receiveTimeout = 30000;

  // New constants from the code block
  static const Duration sessionDuration = Duration(hours: 24);
  static const Duration sessionCheckDuration = Duration(minutes: 30);
  static const double orderSearchRadius = 5.0;
  static const double defaultMapZoom = 15.0;
  static const int maxOrderAssignmentTime = 30;
  static const double minEarningsPerOrder = 30.0;
  static const double baseDeliveryCharges = 20.0;
  static const double perKmDeliveryCharges = 10.0;
  static const String profileImagesPath = 'profile_images';
  static const String documentsPath = 'documents';
  static const String aadharCardDoc = 'aadhar_card';
  static const String panCardDoc = 'pan_card';
  static const String drivingLicenseDoc = 'driving_license';
  static const String vehicleRegistrationDoc = 'vehicle_registration';
  static const String vehicleInsuranceDoc = 'vehicle_insurance';
  static const String vehicleTypeBicycle = 'bicycle';
  static const String vehicleTypeMotorcycle = 'motorcycle';
  static const String vehicleTypeScooter = 'scooter';
  static const String vehicleTypeCar = 'car';
  static const String newOrderTemplate =
      'You have a new order to deliver from {}';
  static const String orderPickedUpTemplate =
      'You have picked up order #{} from {}';
  static const String orderDeliveredTemplate =
      'You have successfully delivered order #{}';
  static const String apiBaseUrl = 'https://api.dashly.com/v1';
  static const String mapsApiKey = 'YOUR_MAPS_API_KEY';
  static const String supportEmail = 'support@dashly.com';
  static const String supportPhone = '+919876543210';
}
