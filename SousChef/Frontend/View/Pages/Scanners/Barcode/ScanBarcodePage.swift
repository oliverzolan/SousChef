import SwiftUI
import AVFoundation

struct ScanBarcodePage: View {
    @EnvironmentObject var userSession: UserSession
    @State private var scannedIngredient: BarcodeModel?
    @State private var showAddIngredientPopup = false
    @State private var isFlashlightOn = false

    var body: some View {
        ZStack {
            // Barcode scanner with overlay
            BarcodeScannerWithOverlay(
                scannedIngredient: $scannedIngredient,
                isNavigating: $showAddIngredientPopup
            )
            .edgesIgnoringSafeArea(.all)

            // Flashlight button
            VStack {
                HStack {
                    flashlightButton()
                    Spacer()
                }
                .padding(.top, 20)
                .padding(.leading, 20)
                Spacer()
            }
        }
        .navigationDestination(isPresented: $showAddIngredientPopup) {
            popupContent()
        }
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                MainTabView()
            }
        }
    }

    // MARK: - Flashlight Button
    @ViewBuilder
    private func flashlightButton() -> some View {
        Button(action: toggleFlashlight) {
            Image(systemName: isFlashlightOn ? "flashlight.on.fill" : "flashlight.off.fill")
                .font(.title)
                .foregroundColor(.yellow)
                .padding()
                .background(Color.black.opacity(0.7))
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

    // MARK: - Popup Content
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
}
