//
//  SousChefApp.swift
//  SousChef
//
//  Created by Oliver Zolan, Sutter Reynolds on 10/26/24.
//

import SwiftUI

@main
struct SousChefApp: App {
    @State private var scannedItems: [String] = [] // Add a state variable for scanned items

    var body: some Scene {
        WindowGroup {
            VStack {
                ReceiptScannerView(scannedItems: $scannedItems) // Pass scannedItems as a binding
                if !scannedItems.isEmpty {
                    Text("Scanned Items:")
                        .font(.headline)
                    List(scannedItems, id: \.self) { item in
                        Text(item)
                    }
                } else {
                    Text("No items scanned yet.")
                        .padding()
                }
            }
        }
    }
}
