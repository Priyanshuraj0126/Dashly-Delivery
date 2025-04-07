# Dashly Delivery Boy App - Complete Development Prompt

I need you to develop a production-ready Flutter application for Dashly's delivery personnel. This app will be used by delivery agents in Tier 2/3/4 Indian cities to manage order pickups and deliveries. The project has been initialized with flutter create and Firebase has been set up with the Google Services JSON file.

## Project Context & Current Status

- We've set up a basic Flutter project structure
- Firebase is integrated (connected to the same project as the Customer App)
- Google Services JSON file is added to the project

## Development Requirements

Create a fully functional, production-ready delivery boy app with the following capabilities:

### Authentication & Profile

- Phone number authentication with OTP verification
- Multi-step profile setup:
  - Personal details (name, photo, etc.)
  - Vehicle information
  - Document upload (Aadhar, PAN, vehicle license)
  - Bank account details
- Zone assignment and visualization

### Core Functionality

- Real-time order notifications and management
- Navigation to vendor and customer locations
- Complete order status workflow (Assigned → Picked Up → Out for Delivery → Delivered)
- Payment handling (COD and online verification)
- Performance tracking and analytics
- Offline functionality with data syncing

## Technical Requirements

- Use BLoC pattern for state management
- Implement clean architecture with appropriate layers
- Follow Material Design 3 guidelines
- Support both light and dark themes
- Multi-language support (Hindi and English)
- Optimize for low-end devices and unstable network conditions

## Development Process

Please follow this structured approach:

1. *Project Architecture*
   - Set up a clean, scalable folder structure
   - Configure proper state management
   - Establish Firebase services layer

2. *Authentication Module*
   - Implement Firebase phone authentication
   - Create multi-step profile setup
   - Design secure session management

3. *Home & Dashboard*
   - Create online/offline toggle
   - Build daily performance metrics
   - Implement active order display

4. *Order Management*
   - Develop real-time order notifications
   - Create order details screen
   - Build order acceptance mechanism

5. *Navigation & Mapping*
   - Integrate Google Maps
   - Implement real-time navigation
   - Create location tracking service

6. *Order Status Flow*
   - Build comprehensive status update system
   - Implement notification triggers for status changes
   - Create delivery confirmation mechanism

7. *Payment Module*
   - Develop COD collection confirmation
   - Create digital payment verification
   - Implement daily reconciliation

8. *Performance Tracking*
   - Build earnings dashboard
   - Create performance analytics
   - Implement rating system

9. *Offline Capabilities*
   - Develop data caching mechanism
   - Implement background sync
   - Create offline maps support

10. *Finalization*
    - Perform code optimization
    - Implement comprehensive error handling
    - Add appropriate logging

## Firebase Schema Understanding

Work with these Firestore collections:


delivery_boys/
  {delivery_boy_id}/
    personal_info: {name, phone, photo_url, etc.}
    vehicle_info: {type, registration, etc.}
    documents: {aadhar_url, pan_url, license_url}
    zone_id: "zone_123"
    status: "online/offline/on_delivery"
    fcm_token: "token_for_push_notifications"
    current_location: {lat, lng}
    statistics: {
      total_deliveries: 120,
      avg_rating: 4.7,
      total_earnings: 15000
    }

orders/
  {order_id}/
    customer_id: "user_123"
    vendor_id: "store_456"
    delivery_boy_id: "delivery_boy_789"
    status: "assigned/picked_up/out_for_delivery/delivered"
    items: [
      {item_id, name, quantity, price},
      ...
    ]
    pickup_address: {full address object}
    delivery_address: {full address object}
    payment: {
      method: "COD/online",
      amount: 350,
      status: "pending/collected/verified"
    }
    timestamps: {
      created_at: timestamp,
      assigned_at: timestamp,
      picked_up_at: timestamp,
      delivered_at: timestamp
    }

zones/
  {zone_id}/
    name: "Zone 1"
    city: "Indore"
    boundaries: [
      {lat, lng},
      ...
    ]
    active_delivery_boys: ["id1", "id2", ...]


## Screen-by-Screen Implementation

Implement the following screens with complete functionality:

### 1. Splash Screen
- Display Dashly logo
- Check authentication status
- Verify profile completion
- Redirect accordingly

### 2. Phone Authentication
- Phone number input with country code
- OTP verification
- Loading states and error handling

### 3. Profile Setup (Multi-step)
- Personal details form
- Vehicle information form
- Document upload interface
- Bank account details form
- Zone visualization and confirmation

### 4. Home Dashboard
- Online/Offline toggle
- Today's statistics (deliveries, earnings)
- Current rating display
- Active order card (if any)
- Quick actions menu

### 5. Order Notification
- Alert dialog with order preview
- Accept/Reject buttons
- Timer countdown
- Sound and vibration

### 6. Order Details
- Complete order information
- Vendor and customer details
- Navigation buttons
- Call/Chat options
- Status update controls

### 7. Navigation Screen
- Google Maps integration
- Real-time navigation
- Current order status
- Quick actions (call, mark status)
- Distance and ETA display

### 8. Payment Collection
- Amount verification
- Payment method display
- Cash collection confirmation
- Digital payment verification
- Receipt generation

### 9. Delivery Confirmation
- Customer OTP verification
- Photo capture option
- Delivery confirmation
- Rating request
- Next order preview (if available)

### 10. History & Earnings
- Daily/Weekly/Monthly toggles
- Earnings breakdown
- Order history list
- Performance metrics
- Payment schedule

### 11. Profile & Settings
- Profile information display
- Document status
- Account settings
- App preferences
- Language selection
- Theme toggle
- Support access

## UI/UX Requirements

- Clean, minimal interface suitable for quick interactions
- Large touch targets for use while on the move
- High contrast for outdoor visibility
- Intuitive iconography with minimal text
- Consistent color coding for status indicators
- Clear visual and audio feedback for important actions

## Important Implementation Notes

1. *Complete Implementation*: Do not leave any TODOs or placeholders. Implement every feature completely.

2. *Error Handling*: Include comprehensive error handling for all network operations, location services, and user interactions.

3. *Loading States*: Add appropriate loading indicators for all async operations.

4. *Background Services*: Implement proper background services for location tracking and order notifications.

5. *Battery Optimization*: Use geofencing and optimize location tracking to minimize battery consumption.

6. *Data Validation*: Implement thorough validation for all user inputs.

7. *Offline Support*: Ensure the app remains functional with degraded capabilities when offline.

8. *Security*: Properly secure sensitive data and implement session management.

9. *Performance*: Optimize for smooth performance on low-end devices.

10. *Testing*: Include unit tests for critical business logic.