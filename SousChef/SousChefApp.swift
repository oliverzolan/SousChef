//
//  SousChefApp.swift
//  SousChef
//
//  Created by Oliver Zolan, Sutter Reynolds on 10/26/24.
//

import SwiftUI
import Firebase

@main
struct SousChefApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var userSession = UserSession() // Initialize UserSession

    var body: some Scene {
        WindowGroup {
            if userSession.token != nil {
                // If the user is authenticated, navigate to the homepage
                homepage_activity()
                    .environmentObject(userSession) // Inject UserSession into the environment
            } else {
                // If not authenticated, navigate to the LoginView
                LoginView()
                    .environmentObject(userSession) // Inject UserSession into the environment
            }
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        return true
    }
}
