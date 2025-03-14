//
//  BarcodeScannerOverlay.swift
//  SousChef
//
//  Created by Oliver Zolan on 3/9/25.
//

import SwiftUI

struct BarcodeScannerOverlay: View {
    @State private var isFlashing = false

    var body: some View {
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
        .onAppear {
            isFlashing.toggle()
        }
    }
}

struct BarcodeScannerWithOverlay: View {
    @Binding var scannedIngredient: BarcodeModel?
    @Binding var isNavigating: Bool

    var body: some View {
        ZStack {
            BarcodeScannerView(scannedIngredient: $scannedIngredient, isNavigating: $isNavigating)
                .edgesIgnoringSafeArea(.all)
            
            BarcodeScannerOverlay()
        }
    }
}
