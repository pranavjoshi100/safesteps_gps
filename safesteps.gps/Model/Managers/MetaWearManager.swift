import CoreLocation
import Foundation

/// Handles all GPS tracking and recording actions.
/// Previously handled MetaWear API-related actions, now GPS-only.
///
/// ### Author & Version
/// Seung-Gu Lee (seunggu@umich.edu), last modified Jun 21, 2023
/// Updated to remove IMU sensor dependencies and use GPS-only tracking
///
class MetaWearManager
{
    /// LocationManager object
    static var locationManager = LocationManager()
    
    /// Whether walking recording or not
    static var recording: Bool = false
    
    /// Start location of a session.
    static var startLocation: [Double] = []
    
    /// Start time of a session.
    static var startTime: Double = 0
    
    /// RealtimeWalkingData object
    static var realtimeData: RealtimeWalkingData = RealtimeWalkingData()
    
    /// List of document names of realtime (GPS) data
    static var realtimeDataDocNames: [String] = []

    /// Returns whether GPS tracking is available
    static func connected() -> Bool {
        return !LocationManager.locationDisabled()
    }
    
    /// Returns whether GPS tracking is available (for compatibility)
    static func wristConnected() -> Bool {
        return !LocationManager.locationDisabled()
    }
    
    /// Returns whether GPS tracking is available
    static func connected(_ cso: ConnectionStatusObject) {
        cso.conn1 = !LocationManager.locationDisabled()
        cso.conn2 = !LocationManager.locationDisabled()
    }

    static func wristConnected(_ cso: ConnectionStatusObject) {
        cso.conn2 = !LocationManager.locationDisabled()
    }
    
    /// Starts recording GPS data.
    /// Non-static function. Usage: `MetaWearManager().startRecording()`
    func startRecording() {
        // Reset
        MetaWearManager.realtimeData.resetData()
        MetaWearManager.locationManager.startRecording()
        MetaWearManager.realtimeDataDocNames = []
        MetaWearManager.recording = true
        
        FirebaseManager.connect()
        
        // Record start time and location
        MetaWearManager.startLocation = MetaWearManager.locationManager.getLocation()
        MetaWearManager.startTime = Date().timeIntervalSince1970
        
        // Start GPS tracking with timestamps
        MetaWearManager.locationManager.startContinuousTracking { location in
            let currentTime = Date().timeIntervalSince1970
            MetaWearManager.realtimeData.addData(RealtimeWalkingDataPoint(
                location: [location.coordinate.latitude, location.coordinate.longitude, location.altitude],
                timestamp: currentTime,
                dataType: "gps"
            ))
            
            // Split data by 3000 data points (30 sec @ 100 Hz)
            if MetaWearManager.realtimeData.size() > 3000 {
                let copiedObj = RealtimeWalkingData(copyFrom: MetaWearManager.realtimeData)
                let documentUuid = UUID().uuidString
                FirebaseManager.addRealtimeData(realtimeData: copiedObj, docNameUuid: documentUuid)
                MetaWearManager.realtimeDataDocNames.append(documentUuid)
                MetaWearManager.realtimeData.resetData()
            }
        }
    }

    /// Sends hazard report to Firebase.
    /// Called when user presses "No, close" or submits a hazard report.
    static func sendHazardReport(hazards: [String],
                                 intensity: [Int],
                                 imageId: String,
                                 buildingId: String = "",
                                 buildingFloor: String = "",
                                 buildingRemarks: String = "",
                                 buildingHazardLocation: String = "",
                                 singlePointReport: Bool = false // report hazard without recording
    ) {
        // Single point report (reporting without recording)
        if singlePointReport {
            let currentLocation = locationManager.getLocation()
            let currentTime = Date().timeIntervalSince1970
            
            // Upload realtime data with 1 data point
            let documentUuid = UUID().uuidString
            var rt = RealtimeWalkingData()
            rt.addData(RealtimeWalkingDataPoint(
                location: currentLocation,
                timestamp: currentTime,
                dataType: "gps"
            ))
            FirebaseManager.addRealtimeData(realtimeData: rt, docNameUuid: documentUuid)
            
            // Upload
            let currentLocationDict: [String: Double] = ["latitude": currentLocation[0],
                                                         "longitude": currentLocation[1],
                                                         "altitude": currentLocation[2]]
            FirebaseManager.connect()
            FirebaseManager.addRecord(rec: GeneralWalkingData.toRecord(type: hazards, intensity: intensity),
                                      realtimeDataDocNames: [documentUuid],
                                      imageId: imageId,
                                      lastLocation: currentLocationDict,
                                      startLocation: currentLocationDict,
                                      startTime: currentTime,
                                      buildingId: buildingId,
                                      buildingFloor: buildingFloor,
                                      buildingRemarks: buildingRemarks,
                                      buildingHazardLocation: buildingHazardLocation)
        }
        // Regular report
        else {
            // Upload remaining realtime data
            let copiedObj = RealtimeWalkingData(copyFrom: MetaWearManager.realtimeData)
            let documentUuid = UUID().uuidString
            FirebaseManager.addRealtimeData(realtimeData: copiedObj, docNameUuid: documentUuid)
            MetaWearManager.realtimeDataDocNames.append(documentUuid)
            
            // last location
            let lastLocation = MetaWearManager.realtimeData.data.last?.location ?? [0, 0, 0]
            let lastLocationDict: [String: Double] = ["latitude": lastLocation[0],
                                                      "longitude": lastLocation[1],
                                                      "altitude": lastLocation[2]]
            let startLocationDict: [String: Double] = ["latitude": startLocation[0],
                                                      "longitude": startLocation[1],
                                                      "altitude": startLocation[2]]
            MetaWearManager.realtimeData.resetData()
            
            // Upload general data
            FirebaseManager.connect()
            FirebaseManager.addRecord(rec: GeneralWalkingData.toRecord(type: hazards, intensity: intensity),
                                      realtimeDataDocNames: MetaWearManager.realtimeDataDocNames,
                                      imageId: imageId,
                                      lastLocation: lastLocationDict,
                                      startLocation: startLocationDict,
                                      startTime: startTime,
                                      buildingId: buildingId,
                                      buildingFloor: buildingFloor,
                                      buildingRemarks: buildingRemarks,
                                      buildingHazardLocation: buildingHazardLocation)
        }
    }
    
    /// Cancels current walking recording session.
    static func cancelSession() {
        // Upload remaining realtime data
        let copiedObj = RealtimeWalkingData(copyFrom: MetaWearManager.realtimeData)
        let documentUuid = UUID().uuidString
        FirebaseManager.addRealtimeData(realtimeData: copiedObj, docNameUuid: documentUuid)
        MetaWearManager.realtimeDataDocNames.append(documentUuid)
        MetaWearManager.realtimeData.resetData()
    }
    
    /// Stops recording GPS data. Called when user presses "Stop Recording".
    /// Note: This does not upload any data to the database; `sendHazardReport` must be called separately.
    ///
    /// Non-static function. Usage: `MetaWearManager().stopRecording()`
    ///
    func stopRecording() {
        MetaWearManager.locationManager.stopContinuousTracking()
        MetaWearManager.recording = false
    }
}



