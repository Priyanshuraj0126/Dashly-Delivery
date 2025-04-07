# Dashly Delivery Boy App - Context

## Project Overview
Dashly is a hyperlocal delivery platform designed for Tier 2/3/4 cities in India. The platform consists of three key components:
1. *Customer App*: For placing orders and tracking deliveries
2. *Delivery Boy App*: For managing order pickups and deliveries (current focus)
3. *Seller App*: For vendors to manage inventory and orders (future development)

## Project Status
- Basic Flutter project initialized with flutter create
- Firebase integration already set up
- Google Services JSON file added to the project
- Project connected to the same Firebase project as the Customer App

## Technical Architecture

### Frontend
- *Framework*: Flutter (Cross-platform for Android and iOS)
- *Key Integrations*: Google Maps API for navigation and real-time tracking

### Backend
- *Database*: Firebase Firestore
  - Shared database between Customer and Delivery Boy apps
  - Real-time updates for order status
- *Authentication*: Firebase Authentication (Phone-based OTP)
- *Notifications*: Firebase Cloud Messaging (FCM)
- *Backend Logic*: Firebase Cloud Functions

## Business Model

### Zone-Based Delivery System
- Cities divided into geographic zones
- Delivery personnel assigned to specific zones
- Orders are only assigned to delivery personnel within the corresponding zone
- Admins can dynamically reassign personnel between zones based on demand

### Payment Model
- Delivery personnel receive monthly fixed income
- Performance is tracked through metrics like:
  - Total deliveries completed
  - Average delivery time
  - Customer ratings

## Target Users
The Delivery Boy App is designed for delivery personnel working in Tier 2/3/4 Indian cities, who may:
- Have varying levels of technical literacy
- Use entry-level to mid-range Android devices
- Require intuitive, easy-to-use interfaces with minimal text
- Prefer native language support (Hindi and regional languages)
- Need optimized performance for areas with potentially unstable internet connectivity

## Unique Selling Points
- Zone-based delivery model for efficiency
- Real-time tracking and navigation
- Performance analytics for delivery personnel
- Simplified order management flow

## Current Firebase Structure
The Firebase project is already structured with the following collections:
- *users*: Contains customer profiles
- *delivery_boys*: Contains delivery personnel profiles
- *orders*: Stores all order information
- *stores*: Contains store/vendor information
- *zones*: Defines geographic boundaries for delivery zones

This shared database structure allows seamless interaction between the Customer App and Delivery Boy App.