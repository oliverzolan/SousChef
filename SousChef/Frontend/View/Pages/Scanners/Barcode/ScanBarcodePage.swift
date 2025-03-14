//
//  BarcodePage.swift
//  SousChef
//
//  Created by Oliver Zolan on 3/7/25.
//

import SwiftUI

struct ScanBarcodePage: View {
    @EnvironmentObject var userSession: UserSession
    @State private var scannedIngredient: BarcodeModel?
    @State private var showAddIngredientPopup = false
    @State private var addedIngredients: [String] = []

    var body: some View {
        NavigationStack {
            VStack {
                BarcodeScannerWithOverlay(
                    scannedIngredient: $scannedIngredient,
                    isNavigating: $showAddIngredientPopup
                )
                .edgesIgnoringSafeArea(.all)
            }
            .navigationTitle("Scan a Barcode")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                resetScannerState()
                setupNavigationBarAppearance()
            }
            .navigationDestination(isPresented: $showAddIngredientPopup) {
                popupContent()
            }
        }
    }
    
    // Sheet content closure - Only renders if `scannedIngredient` exists
    @ViewBuilder
    private func popupContent() -> some View {
        if let ingredient = scannedIngredient {
            AddIngredientBarcodePage(scannedIngredient: ingredient, userSession: self.userSession)
        } else {
            VStack {
                Text("No ingredient found")
                    .font(.headline)
                    .foregroundColor(.red)
                    .padding()
                Button("Dismiss", action: { showAddIngredientPopup = false })
                    .padding()
            }
        }
    }

    // Handles the dismiss action
    private func resetScannerState() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            scannedIngredient = nil
            showAddIngredientPopup = false
            NotificationCenter.default.post(name: NSNotification.Name("RestartScanner"), object: nil)
        }
    }
    // Configures the navigation bar appearance
    private func setupNavigationBarAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        appearance.titleTextAttributes = [.foregroundColor: UIColor.black]

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
}
