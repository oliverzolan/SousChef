import SwiftUI

struct BarcodeScannerView: UIViewControllerRepresentable {
    @EnvironmentObject var userSession: UserSession
    @Binding var scannedItems: [ScannedItem]
    @Binding var showToast: Bool
    @Binding var toastMessage: String
    
    func makeUIViewController(context: Context) -> BarcodeScannerController {
        let scanner = BarcodeScannerController(userSession: userSession)
        scanner.delegate = context.coordinator
        return scanner
    }

    func updateUIViewController(_ uiViewController: BarcodeScannerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }

    class Coordinator: NSObject, BarcodeScannerControllerDelegate {
        var parent: BarcodeScannerView
        private var recentlyScannedCodes = Set<String>()
        private let scanCooldown: TimeInterval = 3.0 // Cooldown between same item scans

        init(parent: BarcodeScannerView) {
            self.parent = parent
        }

        func didScanBarcode(_ barcode: String) {
            // Prevent duplicate scans in quick succession
            if recentlyScannedCodes.contains(barcode) {
                return
            }
            
            // Add to recently scanned list
            recentlyScannedCodes.insert(barcode)
            
            // Clear from recently scanned after cooldown period
            DispatchQueue.main.asyncAfter(deadline: .now() + scanCooldown) {
                self.recentlyScannedCodes.remove(barcode)
            }
            
            BarcodeScannerHelper.shared.fetchIngredient(by: barcode) { ingredient in
                guard let ingredient = ingredient else {
                    BarcodeScannerHelper.shared.showBarcodeNotRecognizedAlert(
                        retryHandler: { self.tryAgain() },
                        searchHandler: { self.navigateToIngredientSearch() }
                    )
                    return
                }

                DispatchQueue.main.async {
                    // Add to scanned items list
                    self.parent.scannedItems.append(ScannedItem(ingredient: ingredient))
                    
                    // Show toast notification
                    self.parent.toastMessage = "\(ingredient.label) Added!"
                    self.parent.showToast = true
                    
                    // Restart scanner to continue scanning
                    NotificationCenter.default.post(name: NSNotification.Name("RestartScanner"), object: nil)
                }
            }
        }

        private func tryAgain() {
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: NSNotification.Name("RestartScanner"), object: nil)
            }
        }

        private func navigateToIngredientSearch() {
            DispatchQueue.main.async {
                let searchView = AddIngredientBarcodePage(
                    scannedIngredient: nil, 
                    userSession: self.parent.userSession,
                    preloadedIngredients: self.parent.scannedItems.map { $0.ingredient }
                )
                let hostingController = UIHostingController(rootView: searchView)
                
                if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let window = scene.windows.first(where: { $0.isKeyWindow }) {
                    window.rootViewController?.present(hostingController, animated: true, completion: nil)
                }
            }
        }
    }
}
