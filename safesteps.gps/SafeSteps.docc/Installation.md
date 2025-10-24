# Installation and Setup

Getting started with SafeSteps GPS

## Prerequisites

Before building the app, ensure you have:
- Xcode 15.0 or later
- iOS 16.0 SDK
- Firebase account
- Apple Developer account (for device testing)

## Firebase Setup

1. **Create Firebase Project**
   - Go to [Firebase Console](https://console.firebase.google.com)
   - Create a new project named "SafeSteps GPS"
   - Enable Google Analytics (optional)

2. **Add iOS App to Firebase**
   - Register bundle identifier: `com.yourdomain.safesteps-gps`
   - Download `GoogleService-Info.plist`
   - Add to Xcode project root

3. **Enable Firebase Services**
   - **Authentication**: Enable Email/Password
   - **Firestore**: Create database in production mode
   - **Storage**: Enable Cloud Storage
   - **Cloud Messaging**: No additional setup needed

4. **Configure Firestore Security Rules**
```javascript
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /users_gps/{userId} {
         allow read, write: if true;
         
         match /records_gps/{recordId} {
           allow read, write: if true;
         }
         
         match /realtime_data_gps/{dataId} {
           allow read, write: if true;
         }
       }
       
       match /routes/{routeId} {
         allow read: if true;
       }
       
       match /buildings/{buildingId} {
         allow read: if true;
       }
     }
   }
```

5. **Create Firestore Indexes**
   Navigate to the provided link in console errors to create required composite indexes.

## Xcode Setup

1. **Clone Repository**
```bash
   git clone https://github.com/yourusername/safesteps-gps.git
   cd safesteps-gps
```

2. **Open Project**
```bash
   open safesteps.gps.xcodeproj
```

3. **Add GoogleService-Info.plist**
   - Drag `GoogleService-Info.plist` into Xcode
   - Ensure "Copy items if needed" is checked
   - Add to target: safesteps.gps

4. **Configure Signing**
   - Select project → Target → Signing & Capabilities
   - Choose your development team
   - Bundle identifier must match Firebase registration

5. **Add Capabilities**
   - **Background Modes**: Location updates
   - **Push Notifications**: Enable
   - **CloudKit**: Enable (optional for sync)

## Info.plist Configuration

Add required privacy descriptions:
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>We need your location to track your walking routes</string>

<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>We need your location to track walking routes and detect movement</string>

<key>NSCameraUsageDescription</key>
<string>We need camera access to capture hazard photos</string>

<key>NSPhotoLibraryUsageDescription</key>
<string>We need photo library access to save hazard images</string>

<key>UIBackgroundModes</key>
<array>
    <string>location</string>
    <string>remote-notification</string>
</array>
```

## Building the App

1. **Select Target Device**
   - Choose iPhone simulator or connected device
   - Minimum: iPhone running iOS 16.0

2. **Build and Run**
   - Press ⌘R or click Run button
   - First launch will request permissions

3. **Grant Permissions**
   - Location: Allow "Always" for full functionality
   - Notifications: Allow for walking detection alerts
   - Camera: Allow for hazard photo capture

## Testing

### Test Walking Detection
1. Run app on physical device
2. Enable walking detection in Settings
3. Walk for 45+ seconds to trigger detection

### Test Hazard Reporting
1. Start walking session
2. Press camera button
3. Capture photo and select hazards
4. Submit report
5. Check Firebase Console for data

## Troubleshooting

### Firebase Connection Issues
- Verify `GoogleService-Info.plist` is in project
- Check bundle identifier matches Firebase
- Ensure Firebase services are enabled

### Location Not Working
- Check Info.plist has location descriptions
- Verify Background Modes capability enabled
- Grant "Always" location permission

### Build Errors
- Clean build folder: ⇧⌘K
- Delete derived data
- Restart Xcode

## See Also

- <doc:TechStack>
- <doc:Architecture>
- ``FirebaseManager``
