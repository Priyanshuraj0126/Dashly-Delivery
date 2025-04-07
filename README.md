# Dashly Delivery App

A hyperlocal delivery application for Tier 2/3/4 cities in India. This app serves as the delivery partner platform for the Dashly ecosystem.

## Features

### Authentication
- Phone number-based OTP authentication
- Profile setup and verification
- Document and vehicle registration

### Order Management
- View and accept new orders
- Real-time order tracking
- Order history and statistics
- Payment collection and verification

### Location Services
- Zone-based operation
- Real-time location tracking
- Navigation to pickup and delivery locations
- Zone adherence monitoring

### Earnings and Analytics
- Daily, weekly, and monthly earnings reports
- Order performance metrics
- Delivery statistics and insights

## Technical Specifications

### Architecture
- BLoC pattern for state management
- Repository pattern for data access
- Service-oriented approach for core functionalities

### Backend Integration
- Firebase Authentication for secure login
- Firestore for real-time data synchronization
- Firebase Cloud Messaging for push notifications
- Firebase Storage for document and image uploads

### Maps and Location
- Google Maps integration for navigation
- Geolocator for precise location tracking
- Geofencing for zone-based operations

### Offline Support
- Local data caching for offline operation
- Automatic synchronization when back online
- Reduced data usage for low connectivity areas

## Development Setup

### Prerequisites
- Flutter SDK (2.17.0 or higher)
- Dart SDK (2.17.0 or higher)
- Android Studio / VS Code
- Firebase project setup

### Getting Started
1. Clone the repository
2. Run `flutter pub get` to install dependencies
3. Configure Firebase (add your own `google-services.json` / `GoogleService-Info.plist` files)
4. Run `flutter run` to launch the app

## Localization
The app supports multiple languages:
- English
- Hindi
- Marathi

## License
Copyright © 2023 Dashly. All rights reserved.
