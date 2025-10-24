import Foundation
import CoreLocation

/// An interface for location data. Handles all location-related actions.
///
/// Note: In this project, an instance of this class is stored in the `MetaWearManager` class.
/// To call any functions here, use `MetaWearManager.locationManager`
///
/// ### Author & Version
/// Seung-Gu Lee (seunggu@umich.edu), last modified May 10, 2023
/// Updated to add continuous GPS tracking with timestamps
///
class LocationManager: NSObject, CLLocationManagerDelegate {
    
    /// `CLLocationManager` object
    let clm = CLLocationManager()
    
    /// Callback for continuous tracking
    private var continuousTrackingCallback: ((CLLocation) -> Void)?
    
    /// Whether continuous tracking is active
    private var isContinuousTracking = false
    
    /// Periodic sampling timer to emit points even when stationary
    private var samplingTimer: Timer?
    private let samplingIntervalSeconds: TimeInterval = 1.0
    
    /// Start recording device location. Required before `getLocation()`.
    func startRecording() {
        clm.delegate = self
        clm.startUpdatingLocation()
        clm.allowsBackgroundLocationUpdates = true
    }
    
    /// Stop recording device location. Required after `getLocation()`.
    func stopRecording() {
        clm.stopUpdatingLocation()
    }
    
    /// Start continuous GPS tracking with timestamps
    /// - Parameter callback: Closure called with each location update
    func startContinuousTracking(callback: @escaping (CLLocation) -> Void) {
        continuousTrackingCallback = callback
        isContinuousTracking = true
        
        clm.delegate = self
        clm.desiredAccuracy = kCLLocationAccuracyBest
        clm.distanceFilter = kCLDistanceFilterNone // emit even if not moving
        clm.pausesLocationUpdatesAutomatically = false
        clm.allowsBackgroundLocationUpdates = true
        clm.startUpdatingLocation()
        
        // Also emit on a fixed cadence so we log timestamps even when stationary
        samplingTimer?.invalidate()
        samplingTimer = Timer.scheduledTimer(withTimeInterval: samplingIntervalSeconds, repeats: true) { [weak self] _ in
            guard let self = self, self.isContinuousTracking else { return }
            if let loc = self.clm.location {
                self.continuousTrackingCallback?(loc)
            }
        }
    }
    
    /// Stop continuous GPS tracking
    func stopContinuousTracking() {
        isContinuousTracking = false
        continuousTrackingCallback = nil
        samplingTimer?.invalidate()
        samplingTimer = nil
        clm.stopUpdatingLocation()
    }
    
    /// Get the current location of the device as an array of doubles: (latitude, longitude, altitude)
    ///`startRecording()` must be called before calling this function.
    /// It is recommended to call `stopRecording()` after all `getLocation()` calls.
    func getLocation() -> [Double] {
        var coord: [Double] = [0, 0, 0]
        
        coord[0] = clm.location?.coordinate.latitude ?? 0
        coord[1] = clm.location?.coordinate.longitude ?? 0
        coord[2] = clm.location?.altitude ?? 0
            
        return coord
    }
    
    func getLocationCoord() -> CLLocationCoordinate2D {
        return clm.location?.coordinate ?? CLLocationCoordinate2D(latitude: 0, longitude: 0)
    }
    
    /// Check if app has location permissions, and ask for permissions as needed
    func requestPermissions() {
        // Handle permissions
        let permStatus = CLLocationManager.authorizationStatus()
        if(permStatus == .denied || permStatus == .restricted) {
            print("Location access denied")
            clm.requestAlwaysAuthorization()
        }
        else if(permStatus == .notDetermined) {
            print("Location access not determined")
            clm.requestAlwaysAuthorization()
        }
    }
    
    /// Determines if user allowed location permissions
    static func locationDisabled() -> Bool {
        let permStatus = CLLocationManager.authorizationStatus()
        return permStatus != .authorizedAlways && permStatus != .authorizedWhenInUse
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        // Call the continuous tracking callback if active
        if isContinuousTracking {
            continuousTrackingCallback?(location)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager failed with error: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            print("Location access granted")
        case .denied, .restricted:
            print("Location access denied")
        case .notDetermined:
            print("Location access not determined")
        @unknown default:
            print("Unknown location authorization status")
        }
    }
}
