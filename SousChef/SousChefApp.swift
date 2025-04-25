//
//  SousChefApp.swift
//  SousChef
//
//  Created by ZeroWave on 10/26/24.
//

import SwiftUI
import Firebase
import GoogleSignIn

import SwiftUI
import FirebaseAuth

@main
struct SousChefApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var userSession = UserSession()

    var body: some Scene {
        WindowGroup {
            let pantryController = PantryController(userSession: userSession)
            let homepageController = HomepageController(pantryController: pantryController)

            if !userSession.isAuthResolved {
                LoadingView()
            } else if userSession.isSignedIn {
                MainTabView()
                    .environmentObject(userSession)
                    .environmentObject(pantryController)
                    .environmentObject(homepageController)
            } else {
                LoginPage()
                    .environmentObject(userSession)
                    .environmentObject(pantryController)
                    .environmentObject(homepageController)
            }
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        FirebaseApp.configure()

        if let clientID = FirebaseApp.app()?.options.clientID {
            GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)
        }

        registerForPushNotifications()

        return true
    }

    private func registerForPushNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            } else {
                print("Push permission denied: \(error?.localizedDescription ?? "No error")")
            }
        }
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { String(format: "%02.2hhx", $0) }
        let tokenString = tokenParts.joined()
        print("APNs device token: \(tokenString)")

        Task { @MainActor in
            UserSession.shared?.deviceToken = tokenString
        }
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for notifications: \(error.localizedDescription)")
    }

    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
}

struct LoadingView: View {
    var body: some View {
        VStack {
            ProgressView()
            Text("Checking login...")
        }
        .padding()
    }
}
