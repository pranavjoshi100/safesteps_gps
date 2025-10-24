import SwiftUI
import CoreLocation

/// A dummy view for testing and development purposes.
/// This view can be used to test various functionality without affecting the main app.
///
/// ### Author & Version
/// Updated to remove MetaWear dependencies
///
struct DummyView: View {
    @State private var testLocation: [Double] = [0, 0, 0]
    @State private var isRecording: Bool = false
    
    // Monitoring state
    @State private var pointsCount: Int = 0
    @State private var lastPointDisplay: String = "-"
    @State private var startTimeDisplay: String = "-"
    @State private var stopTimeDisplay: String = "-"
    @State private var durationDisplay: String = "-"
    @State private var liveLog: [String] = []
    @State private var lastSeenTimestamp: Double = 0
    @State private var monitorTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Dummy View")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("This is a test view for development purposes")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                // Session Info
                VStack(alignment: .leading, spacing: 8) {
                    Text("Session Info:")
                        .font(.headline)
                    HStack {
                        Text("Start:")
                            .fontWeight(.semibold)
                        Text(startTimeDisplay)
                    }
                    HStack {
                        Text("Stop:")
                            .fontWeight(.semibold)
                        Text(stopTimeDisplay)
                    }
                    HStack {
                        Text("Duration:")
                            .fontWeight(.semibold)
                        Text(durationDisplay)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                
                // Live tracking info
                VStack(alignment: .leading, spacing: 10) {
                    Text("Live GPS / Time Tracking:")
                        .font(.headline)
                    
                    HStack {
                        Text("Points Collected:")
                            .fontWeight(.semibold)
                        Text(String(pointsCount))
                    }
                    HStack {
                        Text("Last Sample:")
                            .fontWeight(.semibold)
                        Text(lastPointDisplay)
                    }
                    
                    // Recent samples log
                    if !liveLog.isEmpty {
                        Text("Recent Samples:")
                            .font(.subheadline)
                            .padding(.top, 4)
                        VStack(alignment: .leading, spacing: 4) {
                            ForEach(liveLog.indices, id: \.self) { idx in
                                Text(liveLog[idx])
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                
                // Test GPS functionality
                VStack(alignment: .leading, spacing: 10) {
                    Text("GPS Test:")
                        .font(.headline)
                    
                    Text("Latitude: \(testLocation[0], specifier: "%.6f")")
                    Text("Longitude: \(testLocation[1], specifier: "%.6f")")
                    Text("Altitude: \(testLocation[2], specifier: "%.2f")")
                    
                    Button("Get Current Location") {
                        testLocation = MetaWearManager.locationManager.getLocation()
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                
                // Test recording functionality
                VStack(alignment: .leading, spacing: 10) {
                    Text("Recording Test:")
                        .font(.headline)
                    
                    Text("Status: \(isRecording ? "Recording" : "Not Recording")")
                        .foregroundColor(isRecording ? .green : .red)
                    
                    HStack {
                        Button("Start Recording") {
                            MetaWearManager().startRecording()
                            isRecording = true
                            // reset display fields
                            stopTimeDisplay = "-"
                            durationDisplay = "-"
                            startTimeDisplay = formatTime(MetaWearManager.startTime)
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(isRecording)
                        
                        Button("Stop Recording") {
                            MetaWearManager().stopRecording()
                            isRecording = false
                            let end = Date().timeIntervalSince1970
                            stopTimeDisplay = formatTime(end)
                            if MetaWearManager.startTime > 0 {
                                durationDisplay = formatDuration(seconds: Int(end - MetaWearManager.startTime))
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(!isRecording)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                
                // Test hazard reporting
                VStack(alignment: .leading, spacing: 10) {
                    Text("Hazard Reporting Test:")
                        .font(.headline)
                    
                    Button("Report Single Point Hazard") {
                        MetaWearManager.sendHazardReport(
                            hazards: ["slippery"],
                            intensity: [3],
                            imageId: "",
                            singlePointReport: true
                        )
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                
                Spacer()
            }
            .padding()
        }
        .onAppear {
            // Request location permissions when view appears
            MetaWearManager.locationManager.requestPermissions()
        }
        .onReceive(monitorTimer) { _ in
            // live updates from the in-memory buffer
            pointsCount = MetaWearManager.realtimeData.size()
            if let last = MetaWearManager.realtimeData.data.last {
                if last.timestamp != lastSeenTimestamp {
                    lastSeenTimestamp = last.timestamp
                    let latStr = String(format: "%.5f", last.location[0])
                    let lonStr = String(format: "%.5f", last.location[1])
                    let entry = "\(formatTime(last.timestamp))  lat: \(latStr), lon: \(lonStr)"
                    liveLog.insert(entry, at: 0)
                    if liveLog.count > 10 { liveLog.removeLast() }
                    lastPointDisplay = entry
                }
            }
            // keep start time up to date if a new session started elsewhere
            if MetaWearManager.startTime > 0 {
                startTimeDisplay = formatTime(MetaWearManager.startTime)
            }
        }
    }
    
    // Helpers
    private func formatTime(_ timestamp: Double) -> String {
        if timestamp <= 0 { return "-" }
        let date = Date(timeIntervalSince1970: timestamp)
        let df = DateFormatter()
        df.dateFormat = "h:mm:ss a"
        return df.string(from: date)
    }
    
    private func formatDuration(seconds: Int) -> String {
        let hr = seconds / 3600
        let min = (seconds % 3600) / 60
        let sec = seconds % 60
        return String(format: "%d:%02d:%02d", hr, min, sec)
    }
}

struct DummyView_Previews: PreviewProvider {
    static var previews: some View {
        DummyView()
    }
}
