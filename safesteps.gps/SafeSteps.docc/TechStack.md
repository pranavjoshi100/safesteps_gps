# Tech Stack

System Architecture and Technologies

## Summary of App Functionality

SafeSteps GPS is designed to track pedestrian walking sessions and report environmental hazards in real-time. The app uses GPS tracking to monitor walking routes, automatically detect movement patterns, and allow users to capture and report hazards they encounter.

By leveraging Core Location for GPS tracking, data is sent to Firebase Firestore for cloud storage and synchronization across devices. The app analyzes movement patterns to automatically suggest starting or stopping walking sessions, providing users with contextual notifications.

The app also features pre-defined walking routes, indoor building navigation for hazard reporting, and comprehensive historical session review with map visualization.

There are also safety tips and best practices available throughout the app for pedestrian safety.

## Local iOS Application

Created using Apple's SwiftUI framework, the local iOS application consists of:

### User Interface
- **SwiftUI Views**: Modern, declarative UI components
- **Map Integration**: MapKit for route visualization
- **Camera Access**: AVFoundation for hazard photo capture
- **Notification UI**: Local notification management

### Local Data Persistence
The app uses Core Data for offline-first functionality:
- Walking session caching
- Offline hazard report queueing
- User preferences and settings
- CloudKit integration for cross-device sync

### Location Services
Core Location framework provides:
- Continuous background GPS tracking
- Movement detection algorithms
- Distance and speed calculations
- Geofencing for route waypoints

## Google Firebase

Google Firebase is a cloud service that provides the backend infrastructure for SafeSteps.

### Authentication
When the app is first opened, users are prompted to sign in or create an account. Firebase Authentication securely handles:
- User sign-in and account creation
- Password reset via email
- Session management and security
- Anonymous authentication for testing

### Firestore Database
Firebase Firestore is a NoSQL cloud database that stores:

**Collections:**
- `users_gps`: User profiles and demographics
- `records_gps`: Walking session records and hazard reports
- `realtime_data_gps`: GPS coordinate arrays with timestamps
- `routes`: Community-shared walking routes
- `buildings`: Indoor building information for hazard reporting

**Data Structure:**
- Real-time synchronization across devices
- Offline persistence with automatic sync
- Composite indexes for efficient querying
- Security rules for data access control

### Cloud Storage
Firebase Storage handles file uploads:
- **Hazard photos**: Images captured during reports
- **Building floor plans**: Reference images for indoor navigation
- Automatic CDN distribution
- Secure authenticated access

### Cloud Messaging
Firebase Cloud Messaging (FCM) powers:
- Walking detection notifications
- Movement start/stop alerts
- Session reminder notifications
- App termination warnings

## Technology Stack Summary

| Component | Technology | Purpose |
|-----------|-----------|---------|
| **Frontend** | SwiftUI | User interface |
| **Local Storage** | Core Data | Offline persistence |
| **Cloud Sync** | CloudKit | Cross-device sync |
| **Location** | Core Location | GPS tracking |
| **Backend** | Firebase | Cloud infrastructure |
| **Database** | Firestore | NoSQL storage |
| **File Storage** | Firebase Storage | Image hosting |
| **Auth** | Firebase Auth | User management |
| **Notifications** | FCM + UNUserNotifications | Push & local notifications |
| **Maps** | MapKit | Route visualization |
| **Packages** | SPM | Dependency management |

## Dependencies

### Swift Package Manager
- **Firebase iOS SDK** (12.3.0)
  - FirebaseCore
  - FirebaseFirestore
  - FirebaseAuth
  - FirebaseStorage
  - FirebaseMessaging
- **Polyline** (5.1.0): Route encoding/decoding
- **SkeletonUI** (1.30.0): Loading animations

### System Requirements
- iOS 16.0 or later
- Location Services enabled
- Camera access (for hazard photos)
- Network connectivity (for cloud sync)

## See Also

- <doc:Installation>
- <doc:Architecture>
- ``FirebaseManager``
- ``LocationManager``
