import SwiftUI
import CoreLocation

/// View for GPS settings and status.
/// Previously used for MetaWear device connections, now GPS-focused.
///
/// ### Author & Version
/// Seung-Gu Lee (seunggu@umich.edu), last modified May 10, 2023
/// Updated to support GPS-only tracking
///
struct DeviceView: View {
    /// Connection status object
    @EnvironmentObject var connectionStatus: ConnectionStatusObject
    
    @ObservedObject var bso: BatteryStatusObject = BatteryStatusObject()
    @ObservedObject var wristbso: BatteryStatusObject = BatteryStatusObject()
    
    // refresh every second
    @State var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    @State var showLocationSettingsPopup: Bool = false
    
    var body: some View {
        ZStack {
            VStack {
                Text("GPS Settings")
                    .font(.system(size: 24, weight: .semibold))
                    .padding(.bottom, 4)
                    .foregroundColor(Utilities.isDarkMode() ? Color(white: 1) : Color(white: 0))
                
                VStack(spacing: 10) {
                    Text("GPS tracking is used for recording your walking sessions and detecting movement.")
                        .font(.system(size: 12))
                        .frame(width: 320)
                        .padding(.horizontal, 30)
                        .multilineTextAlignment(.center)
                        .foregroundColor(Utilities.isDarkMode() ? Color(white: 1) : Color(white: 0))
                }
                .padding(.bottom, 12)
                
                // GPS Status
                VStack(spacing: 20) {
                    // GPS Status Card
                    VStack {
                        Text("GPS Status")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(Utilities.isDarkMode() ? Color(white: 1) : Color(white: 0))
                        
                        // GPS Icon
                        Image(systemName: "location.circle.fill")
                            .resizable()
                            .frame(width: 80, height: 80)
                            .foregroundColor(LocationManager.locationDisabled() ? .red : .green)
                            .padding(.vertical, 10)
                        
                        // Status Text
                        Text(LocationManager.locationDisabled() ? "Location Disabled" : "Location Enabled")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(LocationManager.locationDisabled() ? .red : .green)
                        
                        // Current Location (if available)
                        if !LocationManager.locationDisabled() {
                            let location = MetaWearManager.locationManager.getLocation()
                            VStack(spacing: 5) {
                                Text("Current Location:")
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary)
                                Text("Lat: \(location[0], specifier: "%.6f")")
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                                Text("Lon: \(location[1], specifier: "%.6f")")
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                            }
                            .padding(.top, 5)
                        }
                        
                        // Action Button
                        Button(action: {
                            if LocationManager.locationDisabled() {
                                showLocationSettingsPopup = true
                            } else {
                                // Test GPS functionality
                                let location = MetaWearManager.locationManager.getLocation()
                                print("GPS Test - Lat: \(location[0]), Lon: \(location[1])")
                                Toast.showToast("GPS working!")
                            }
                        }) {
                            IconButtonInner(
                                iconName: LocationManager.locationDisabled() ? "location.slash" : "location",
                                buttonText: LocationManager.locationDisabled() ? "Enable Location" : "Test GPS"
                            )
                        }
                        .buttonStyle(IconButtonStyle(
                            width: 200,
                            backgroundColor: LocationManager.locationDisabled() ? .red : .green,
                            foregroundColor: .white
                        ))
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                    
                    // Recording Status
                    VStack {
                        Text("Recording Status")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(Utilities.isDarkMode() ? Color(white: 1) : Color(white: 0))
                        
                        Text(MetaWearManager.recording ? "Currently Recording" : "Not Recording")
                            .font(.system(size: 16))
                            .foregroundColor(MetaWearManager.recording ? .green : .secondary)
                            .padding(.vertical, 5)
                        
                        if MetaWearManager.recording {
                            Text("GPS tracking is active")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                }
                
                // Help Link
                Link(destination: URL(string: "https://support.apple.com/en-us/HT207092")!) {
                    HStack {
                        Image(systemName: "questionmark.circle.fill")
                            .imageScale(.medium)
                        Text("Location Services Help")
                    }
                }
                .padding(.top, 16)
            } // VStack
            .onAppear {
                MetaWearManager.connected(connectionStatus)
            }
        } // ZStack
        // Refresh every 1 sec
        .onReceive(timer) { _ in
            MetaWearManager.connected(connectionStatus)
        }
        .alert("Location Services Required", isPresented: $showLocationSettingsPopup, actions: {
            Button("Open Settings", role: nil, action: {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
                showLocationSettingsPopup = false
            })
            Button("Cancel", role: .cancel, action: {
                showLocationSettingsPopup = false
            })
        }, message: {
            Text("Please enable location services in Settings to use GPS tracking features.")
        })
    } // body
}

struct DeviceView_Previews: PreviewProvider {
    static var previews: some View {
        DeviceView()
    }
}

