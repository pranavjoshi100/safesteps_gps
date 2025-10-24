import Foundation
import CoreLocation

/// Handles all actions related to walking detection using GPS.
/// All functions are static.
///
/// ### Author & Version
/// Seung-Gu Lee (seunggu@umich.edu), last modified May 31, 2023
/// Updated to use GPS-based movement detection instead of IMU sensors
///
class WalkingDetectionManager {
    /// Location manager for GPS-based movement detection
    static var locationManager = CLLocationManager()
    
    /// Indicates whether walking detection has been initialized or not
    static var initialized: Bool = false // MUST BE FALSE!!
    
    static var enabled: Bool = true
    
    static var lastMovementDetected: Double = -1 // Unix timestamp
    static var lastStationaryDetected: Double = -1
    
    /// Time of continuous motion required (lower bound) to turn walking detection on/off
    /// e.g. if 10, device must be moving for 10 seconds to start automatic recording (same thing other way around)
    static var timeToTrigger: Int = 45; // seconds
    
    /// Distance threshold for movement detection (in meters)
    static var movementThreshold: Double = 10.0 // meters
    
    /// Last known location for movement detection
    static var lastKnownLocation: CLLocation?
    
    /// Timer for periodic GPS checks
    static var movementCheckTimer: Timer?

    /// Initializes manager
    /// Must be called at least once to start listening to movement.
    /// Can be called multiple times; subsequent calls will be ignored.
    ///
    /// ### Usage
    /// `WalkingDetectionManager.initialize()`
    /// Called in `MainView.swift`
    ///
    static func initialize() {
        // already initialized
        if initialized {
            return
        }
        
        lastMovementDetected = Date().timeIntervalSince1970
        lastStationaryDetected = Date().timeIntervalSince1970
        
        // If walking detection is active
        if UserDefaults.standard.bool(forKey: "receiveWalkingDetectionNotifications") {
            MetaWearManager.locationManager.startRecording()
            startMovementDetection()
        }
        
        initialized = true
    }
    
    /// Start GPS-based movement detection
    static func startMovementDetection() {
        // Set up location manager
        locationManager.delegate = nil // We'll use MetaWearManager's location manager
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 5.0 // Update every 5 meters
        
        // Start periodic movement checks
        movementCheckTimer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { _ in
            checkMovement()
        }
    }
    
    /// Check if user is moving based on GPS location changes
    static func checkMovement() {
        guard let currentLocation = MetaWearManager.locationManager.clm.location else { return }
        
        if let lastLocation = lastKnownLocation {
            let distance = currentLocation.distance(from: lastLocation)
            
            if distance > movementThreshold {
                // User is moving
                lastMovementDetected = Date().timeIntervalSince1970
                print("Movement detected: \(distance)m")
            } else {
                // User is stationary
                lastStationaryDetected = Date().timeIntervalSince1970
                print("Stationary detected")
            }
        }
        
        lastKnownLocation = currentLocation
        
        // Check if we should start/stop recording
        checkRecordingStatus()
    }
    
    /// Check if we should start or stop recording based on movement
    static func checkRecordingStatus() {
        // Retrieve detection sensitivity settings
        timeToTrigger = UserDefaults.standard.integer(forKey: "walkingDetectionSensitivity")
        
        if MetaWearManager.recording { // recording
            if lastStationaryDetected - lastMovementDetected >= CGFloat(timeToTrigger) {
                
                if (UserDefaults.standard.bool(forKey: "receiveWalkingDetectionNotifications") && (UserDefaults.standard.bool(forKey: "receiveWalkingDetectionNotificationsAllDay") || (Utilities.getHour() >= 8 && Utilities.getHour() < 18))) {
                    let title = "Movement Stopped Detected"
                    let body = "Don't forget to stop the walking session!"
                    NotificationManager.sendNotificationNow(title: title,
                                                            body: body)
                }
                print("Movement stopped detected")
                
                reset()
            }
        }
        else { // not recording
            if lastMovementDetected - lastStationaryDetected >= CGFloat(timeToTrigger) {
                // Error - location disabled
                if(LocationManager.locationDisabled()) {
                    if (UserDefaults.standard.bool(forKey: "receiveWalkingDetectionNotifications") && (UserDefaults.standard.bool(forKey: "receiveWalkingDetectionNotificationsAllDay") || (Utilities.getHour() >= 8 && Utilities.getHour() < 18))) {
                        let title = "Cannot Start Recording"
                        let body = "Movement detected, but location services are disabled. "
                            + "Please enable location services to record your walking sessions."
                        NotificationManager.sendNotificationNow(title: title,
                                                                body: body,
                                                                rateLimit: 300, rateLimitId: "cannotStartSessionLocationDisabled")
                    }
                    
                    print("Cannot start session: location disabled")
                    return
                }
                
                // start walking session
                MetaWearManager().startRecording()
                print("Movement start detected")
                
                // notification
                if (UserDefaults.standard.bool(forKey: "receiveWalkingDetectionNotifications") && (UserDefaults.standard.bool(forKey: "receiveWalkingDetectionNotificationsAllDay") || (Utilities.getHour() >= 8 && Utilities.getHour() < 18))) {
                    let title = "Movement Detected"
                    let body = "Don't forget to start the walking session!"
                    NotificationManager.sendNotificationNow(title: title, body: body)
                }
                reset()
            }
        }
    }
    
    /// Resets timestamp data of the manager.
    static func reset() {
        lastMovementDetected = Date().timeIntervalSince1970
        lastStationaryDetected = Date().timeIntervalSince1970
    }
    
    /// Sets whether walking detection is enabled or not.
    static func enableDetection(_ enable: Bool) {
        enabled = enable
        
        if enable {
            startMovementDetection()
        } else {
            stopMovementDetection()
        }
    }
    
    /// Stop movement detection
    static func stopMovementDetection() {
        movementCheckTimer?.invalidate()
        movementCheckTimer = nil
        lastKnownLocation = nil
    }
}
