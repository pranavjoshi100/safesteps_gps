import Foundation
import SwiftUI
import FirebaseCore
import FirebaseFirestore
import FirebaseStorage
import FirebaseMessaging
import FirebaseInAppMessaging

/// Connects to Firebase on app launch
///
/// ### Usage
/// ```
/// struct YourApp: App {
///     @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
///     // stuff...
/// }
/// ```
///
/// ### Author & Version
/// Provided by Firebase, as of Apr. 14, 2023.
/// Modified by Seung-Gu Lee, last modified Feb 5, 2024
///
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions:
                     [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        // Suppress Firebase In‑App Messaging UI for this build to avoid network fetch/display
        InAppMessaging.inAppMessaging().messageDisplaySuppressed = true
        
        // Register for remote notifications
        Messaging.messaging().delegate = self
        Messaging.messaging().token { token, error in
          if let error = error {
            print("Error fetching FCM registration token: \(error)")
          } else if let token = token {
            print("FCM registration token: \(token)")
            print("Remote FCM registration token: \(token)")
          }
        }
        UNUserNotificationCenter.current().delegate = self
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: { _, _ in }
        )
        application.registerForRemoteNotifications()

        
        
        
        
        return true
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        print("App terminating")
        if UserDefaults.standard.bool(forKey: "receiveAppTerminationNotifications") {
            NotificationManager.sendNotificationNow(title: "App Terminated",
                                                    body: "If this wasn't intentional, please reopen the app to continue using the app's features.")
        }
        
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    /// Called on notification received
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler:
        @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([[.banner, .sound]])
    }
    
    /// Called on notification received
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        completionHandler()
    }

    
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        Messaging.messaging().apnsToken = deviceToken
    }

}


extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging,
                   didReceiveRegistrationToken fcmToken: String?) {
        let tokenDict = ["token": fcmToken ?? ""]
        NotificationCenter.default.post(
          name: Notification.Name("FCMToken"),
          object: nil,
          userInfo: tokenDict)
      }
}
