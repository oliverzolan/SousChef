//
//  ContentView.swift
//  SousChef
//
//  Created by Oliver Zolan, Sutter Reynolds, Bennet Rau on 10/26/24.
//

import SwiftUI
import Firebase

@main
struct SousChefApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State private var scannedItems: [String] = [] // State for scanned items

    var body: some Scene {
        WindowGroup {
            NavigationView {
                VStack {
                    ReceiptScannerView(scannedItems: $scannedItems) // Pass scanned items
                        .navigationBarTitle("Scan Ingredients", displayMode: .inline)

                    if !scannedItems.isEmpty {
                        Text("Scanned Items:")
                            .font(.headline)
                            .padding(.top)

                        List(scannedItems, id: \.self) { item in
                            Text(item)
                        }
                    } else {
                        Text("No items scanned yet.")
                            .foregroundColor(.gray)
                            .padding()
                    }
                }
            }
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure() // Initialize Firebase
        return true
    }
}
