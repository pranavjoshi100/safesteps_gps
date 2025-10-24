# Architecture

System design and component relationships

## Overview

SafeSteps follows a manager-based architecture pattern where specialized manager classes handle specific responsibilities.

## Core Architecture

### Manager Layer

**FirebaseManager**
- Handles all Firebase operations
- Database reads/writes
- Storage uploads/downloads
- Authentication (future)

**LocationManager**
- GPS coordinate tracking
- Location permission management
- Continuous tracking with callbacks
- Background location updates

**MetaWearManager**
- Walking session coordination
- Start/stop recording
- Data segmentation for Firebase
- Hazard report submission

**WalkingDetectionManager**
- Automatic movement detection
- GPS-based activity recognition
- Session start/stop triggers
- Movement notifications

**NotificationManager**
- Local notification delivery
- Rate limiting
- Permission management

### Data Layer

**RealtimeWalkingData**
- GPS coordinates array
- Timestamp tracking
- Data point aggregation
- Firebase serialization

**GeneralWalkingData**
- Hazard report metadata
- Session summary information
- User demographics
- Survey responses

### View Layer

Built with SwiftUI:
- ContentView: Main navigation
- RecordingView: Active session tracking
- HistoryView: Past session review
- MapView: Route visualization
- SettingsView: User preferences

## See Also

- <doc:TechStack>
- ``FirebaseManager``
- ``MetaWearManager``
