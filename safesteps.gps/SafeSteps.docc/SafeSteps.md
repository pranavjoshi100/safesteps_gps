# ``safesteps_gps``

SafeSteps GPS - Fall Detection & Hazard Reporting App

## Overview

SafeSteps GPS is an iOS application that tracks walking sessions using GPS technology, automatically detects movement patterns, and allows users to report environmental hazards they encounter during their walks.

The app provides real-time GPS tracking, automatic walking detection, hazard photo capture, and historical session review capabilities.

### Previous Implementation

SafeSteps version 2.0 transitioned from a MetaWear IMU sensor-based approach to GPS-only tracking due to critical compatibility issues. When Apple mandated updates to the latest iOS SDK for App Store submission, the MetaWear iOS API encountered blocking build failures. The third-party library relied on legacy C++ module instances that were incompatible with modern Xcode versions, and global C++ dependencies in the codebase could not be updated to work with current Swift/Objective-C interoperability requirements. With no active maintenance of the MetaWear SDK and no clear migration path, the app became completely unavailable for TestFlight distribution and usability testing.

The migration to GPS-only tracking eliminated these technical blockers while delivering significant improvements. Users no longer need to purchase, charge, or pair separate hardware sensors, reducing onboarding from 15 minutes to under 1 minute. The new implementation uses iOS's native Core Location framework for continuous background tracking increased reliability compared to the use of Bluetooth sensors. Ultimately, the frequent GPS-based movement detection samples provided sufficient granularity for walking activity while maintaining battery usage. 

## Topics

### Getting Started

- <doc:TechStack>
- <doc:Installation>
- <doc:Architecture>

### Core Features

SafeSteps provides comprehensive walking tracking and hazard reporting:
- Real-time GPS tracking during walking sessions
- Automatic movement detection with configurable sensitivity
- Hazard photo capture with location tagging
- Historical session review with map visualization
- Pre-defined walking routes
- Indoor building navigation

### Managers

- ``FirebaseManager``
- ``LocationManager``
- ``MetaWearManager``
- ``WalkingDetectionManager``
- ``NotificationManager``

### Data Models

- ``RealtimeWalkingData``
- ``GeneralWalkingData``
- ``Route``
- ``Building``
- ``User``

### Loaders

- ``WalkingRecordsLoader``
- ``RealtimeWalkingDataLoader``
- ``MultiWalkingLoader``
- ``BuildingsLoader``
- ``RoutesLoader``
- ``ImageLoader``

### Supporting Types

- ``ConnectionStatusObject``
- ``BatteryStatusObject``
