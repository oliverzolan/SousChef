import SwiftUI
import AVFoundation

struct ScanBarcodePage: View {
    @EnvironmentObject var userSession: UserSession
    @State private var scannedIngredient: BarcodeModel?
    @State private var showAddIngredientPopup = false
    @State private var isFlashlightOn = false
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
            }
            .zIndex(1)
            
            // Barcode scanner with overlay
            BarcodeScannerWithOverlay(
                scannedIngredient: $scannedIngredient,
                isNavigating: $showAddIngredientPopup
            )
            .edgesIgnoringSafeArea(.all)
        }
        .navigationBarHidden(true)
        .fullScreenCover(isPresented: $showAddIngredientPopup) {
            if let ingredient = scannedIngredient {
                AddIngredientBarcodePage(scannedIngredient: ingredient, userSession: userSession)
            }
        }
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
