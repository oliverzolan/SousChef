//
//  BarcodeScannerOverlay.swift
//  SousChef
//
//  Created by Oliver Zolan on 3/9/25.
//

import SwiftUI

struct BarcodeScannerOverlay: View {
    @State private var isFlashing = false
    var scannedItems: [ScannedItem]
    
    init(scannedItems: [ScannedItem]) {
        self.scannedItems = scannedItems
    }
    
    var body: some View {
        VStack {
            // Scanned items list at the top
            ScrollView {
                VStack(spacing: 8) {
                    ForEach(scannedItems) { item in
                        HStack {
                            Text(item.ingredient.label)
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(8)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 20)
            }
            .frame(maxHeight: 200)
            
            Spacer()
            
            // Scanner overlay at the bottom
            ZStack {
                Color.black.opacity(0.6)
                    .edgesIgnoringSafeArea(.all)
                    .mask(
                        Rectangle()
                            .frame(width: 300, height: 100)
                            .cornerRadius(10)
                            .blendMode(.destinationOut)
                    )
                    .compositingGroup()

                RoundedRectangle(cornerRadius: 10)
                    .stroke(isFlashing ? Color.green : Color.white, lineWidth: 4)
                    .frame(width: 300, height: 100)
                    .animation(Animation.easeInOut(duration: 0.7).repeatForever(), value: isFlashing)

                VStack {
                    Spacer()
                    Text("Align the barcode within the frame")
                        .foregroundColor(.white)
                        .font(.headline)
                        .padding(.bottom, 100)
                }
            }
            .padding(.bottom, 100)
        }
        .onAppear {
            isFlashing.toggle()
        }
    }
}

struct BarcodeScannerWithOverlay: View {
    @Binding var scannedItems: [ScannedItem]
    @Binding var showToast: Bool
    @Binding var toastMessage: String

    var body: some View {
        ZStack {
            BarcodeScannerView(
                scannedItems: $scannedItems,
                showToast: $showToast,
                toastMessage: $toastMessage
            )
            .edgesIgnoringSafeArea(.all)
            
            BarcodeScannerOverlay(scannedItems: scannedItems)
        }
    }
}
