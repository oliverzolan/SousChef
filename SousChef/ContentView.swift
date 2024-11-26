//
//  ContentView.swift
//  SousChef
//
//  Created by Oliver Zolan, Sutter Reynolds, Bennet Rau on 10/26/24.
//

import SwiftUI

struct ContentView: View {
    @State private var scannedItems: [String] = []

    var body: some View {
        NavigationView {
            ReceiptScannerView(scannedItems: $scannedItems)
                .navigationBarTitle("Scan Ingredients", displayMode: .inline)
        }
    }
}


#Preview {
    ContentView()
}
