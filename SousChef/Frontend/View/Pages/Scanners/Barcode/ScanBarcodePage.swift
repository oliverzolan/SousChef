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
    @State private var isNavigating = false
    @State private var addedIngredients: [String] = []

    var body: some View {
        NavigationStack {
            VStack {
                BarcodeScannerWithOverlay(scannedIngredient: $scannedIngredient, isNavigating: $isNavigating)
                    .edgesIgnoringSafeArea(.all)
            }
            .navigationTitle("Scan a Barcode")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                let appearance = UINavigationBarAppearance()
                appearance.configureWithOpaqueBackground()
                appearance.backgroundColor = .white
                appearance.titleTextAttributes = [.foregroundColor: UIColor.black]

                UINavigationBar.appearance().standardAppearance = appearance
                UINavigationBar.appearance().scrollEdgeAppearance = appearance
            }
            .navigationDestination(isPresented: $isNavigating) {
                if let ingredient = scannedIngredient {
                    AddIngredientPopup(ingredients: $addedIngredients, scannedIngredient: ingredient, userSession: userSession)
                }
            }
        }
    }
}

