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
            super.init()
            
            // Add observer for navigation to ingredient search AFTER super.init()
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(handleNavigateToIngredientSearch),
                name: NSNotification.Name("NavigateToIngredientSearch"),
                object: nil
            )
        }
        
        deinit {
            NotificationCenter.default.removeObserver(self)
        }
        
        @objc private func handleNavigateToIngredientSearch() {
            navigateToIngredientSearch()
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
                let searchView = AddIngredientPopup()
                    .environmentObject(self.parent.userSession)
                let hostingController = UIHostingController(rootView: searchView)
                hostingController.modalPresentationStyle = .fullScreen

                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let window = windowScene.windows.first(where: { $0.isKeyWindow }),
                   let rootVC = window.rootViewController {
                    var topVC = rootVC
                    while let presentedVC = topVC.presentedViewController {
                        topVC = presentedVC
                    }
                    topVC.present(hostingController, animated: true, completion: {
                        // Restart scanner when the popup is dismissed
                        NotificationCenter.default.post(name: NSNotification.Name("RestartScanner"), object: nil)
                    })
                }
            }
        }
    }
}
