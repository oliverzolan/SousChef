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

    var body: some Scene {
        WindowGroup {
            homepage_activity()
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
