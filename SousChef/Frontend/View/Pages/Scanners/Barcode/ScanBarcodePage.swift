import SwiftUI
import AVFoundation

struct ScannedItem: Identifiable {
    var id = UUID()
    var ingredient: BarcodeModel
}

struct ScanBarcodePage: View {
    @EnvironmentObject var userSession: UserSession
    @State private var scannedItems: [ScannedItem] = []
    @State private var showAddIngredientPopup = false
    @State private var isFlashlightOn = false
    @State private var showToast: Bool = false
    @State private var toastMessage: String = ""
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                    .padding(.top, 40)
                    .padding(.leading, 20)
                    
                    Spacer()
                    
                    flashlightButton()
                        .padding(.top, 40)
                        .padding(.trailing, 20)
                }
                
                Spacer()
                
                // Only show finish button if items have been scanned
                if !scannedItems.isEmpty {
                    Button(action: {
                        showAddIngredientPopup = true
                    }) {
                        Text("Finish Scanning (\(scannedItems.count))")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(10)
                            .padding(.bottom, 30)
                    }
                }
            }
            .zIndex(1)
            
            // Barcode scanner with overlay
            BarcodeScannerWithOverlay(
                scannedItems: $scannedItems,
                showToast: $showToast,
                toastMessage: $toastMessage
            )
            .edgesIgnoringSafeArea(.all)
        }
        .navigationBarHidden(true)
        .fullScreenCover(isPresented: $showAddIngredientPopup) {
            AddIngredientBarcodePage(
                scannedIngredient: nil,
                userSession: userSession,
                preloadedIngredients: scannedItems.map { $0.ingredient }
            )
        }
        .toast(isPresented: $showToast, message: toastMessage)
    }

    // MARK: - Flashlight Button
    @ViewBuilder
    private func flashlightButton() -> some View {
        Button(action: toggleFlashlight) {
            Image(systemName: isFlashlightOn ? "flashlight.on.fill" : "flashlight.off.fill")
                .font(.title2)
                .foregroundColor(.yellow)
                .padding()
                .background(Color.black.opacity(0.5))
                .clipShape(Circle())
        }
    }

    private func toggleFlashlight() {
        guard let device = AVCaptureDevice.default(for: .video), device.hasTorch else { return }
        do {
            try device.lockForConfiguration()
            device.torchMode = isFlashlightOn ? .off : .on
            isFlashlightOn.toggle()
            device.unlockForConfiguration()
        } catch {
            print("Flashlight could not be toggled: \(error)")
        }
    }
}
