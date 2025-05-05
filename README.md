# Dashly Delivery App

Dashly Delivery is a mobile application for delivery personnel to manage their deliveries, track earnings, and update their profile.

## MVP Release Notes

This version is configured for an MVP internal testing release with the following simplifications:

1. **Single Delivery Person Mode**:
   - The app now operates in a single delivery area mode
   - Zone allocation functionality is disabled
   - All orders are automatically assigned to the single delivery driver

2. **Simplified Delivery Flow**:
   - Order receiving to delivery process has been streamlined
   - Location tracking is enabled but zone restriction checks are bypassed

3. **Admin Dashboard Metrics**:
   - Number of deliveries completed today
   - Minimum order quantity
   - Minimum order value
   - Total revenue

## Getting Started

### Prerequisites

- Flutter SDK (latest stable version)
- Android Studio / VS Code
- Firebase project with authentication, Firestore, and Cloud Storage

### Installation

1. Clone the repository
   ```
   git clone https://github.com/your-organization/dashly-delivery.git
   ```

2. Install dependencies
   ```
   flutter pub get
   ```

3. Run the app
   ```
   flutter run
   ```

## Features

- Authentication with phone number and OTP
- Order management (view, accept, complete)
- Earnings tracking
- Profile management
- Navigation to pickup and delivery locations
- Notifications for new orders

## Architecture

The app follows a Clean Architecture approach:

- **Data layer**: Repository implementations, data sources, models
- **Domain layer**: Entities, repository interfaces, use cases
- **Presentation layer**: BLoC state management, UI components, screens

## Technologies

- Flutter for cross-platform mobile development
- Firebase for backend services (Auth, Firestore, Storage)
- BLoC pattern for state management
- Google Maps for location and navigation

## Localization
The app supports multiple languages:
- English
- Hindi
- Marathi

## License
Copyright © 2023 Dashly. All rights reserved.
