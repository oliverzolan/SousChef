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

            NavigationView {
                if !userSession.isAuthResolved {
                    LoadingView() // ⏳ While Firebase is checking
                } else if userSession.isSignedIn {
                    HomePage()
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
}


//struct SousChefApp: App {
//    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
//    @StateObject private var userSession = UserSession() // Initialize UserSession
//
//    var body: some Scene {
//        WindowGroup {
//            if let _ = userSession.token, !userSession.isGuest {
//                // Navigate to the homepage if authenticated
//                HomePage()
//            } else {
//                // Show login options
//                LoginPage()
//            }
//            .environmentObject(userSession)
//        }
//    }
//}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        FirebaseApp.configure()

        // Ensure GIDClientID is set for Google Sign-In
        if let clientID = FirebaseApp.app()?.options.clientID {
            GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)
        }

        return true
    }

    // Handles Google Sign-In callback
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
