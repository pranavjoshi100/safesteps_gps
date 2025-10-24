import Foundation
import CoreLocation
import MapKit
import Polyline

/// A struct that stores GPS location and timestamp.
/// Updated to support GPS-only tracking without IMU sensors.
///
/// ### Author & Version
/// Seung-Gu Lee (seunggu@umich.edu), last modified May 10, 2023
/// Updated to support GPS-only tracking
///
struct RealtimeWalkingDataPoint {
    
    /// GPS Location of the data: (latitude, longitude, altitude)
    var location: [Double]
    
    /// Type of data (gps, etc)
    var dataType: String
    
    /// Current timestamp in seconds from Jan. 1, 1970
    var timestamp = NSDate().timeIntervalSince1970
    
    var sensorId: Int = 0
    
    /// Convenience initializer for GPS-only data points
    init(location: [Double], timestamp: Double = NSDate().timeIntervalSince1970, dataType: String = "gps") {
        self.location = location
        self.dataType = dataType
        self.timestamp = timestamp
        self.sensorId = 0
    }
    
    /// Full initializer for compatibility
    init(data: [Double], dataType: String, location: [Double], timestamp: Double = NSDate().timeIntervalSince1970, sensorId: Int = 0) {
        self.location = location
        self.dataType = dataType
        self.timestamp = timestamp
        self.sensorId = sensorId
    }
}
