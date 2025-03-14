import SwiftUI

struct BarcodeScannerView: UIViewControllerRepresentable {
    @EnvironmentObject var userSession: UserSession
    @Binding var scannedIngredient: BarcodeModel?
    @Binding var isNavigating: Bool

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

        init(parent: BarcodeScannerView) {
            self.parent = parent
        }

        func didScanBarcode(_ barcode: String) {
            BarcodeScannerHelper.shared.fetchIngredient(by: barcode) { ingredient in
                guard let ingredient = ingredient else {
                    BarcodeScannerHelper.shared.showBarcodeNotRecognizedAlert(
                        retryHandler: { self.tryAgain() },
                        searchHandler: { self.navigateToIngredientSearch() }
                    )
                    return
                }

                self.parent.scannedIngredient = ingredient
                self.parent.isNavigating = true
            }
        }

        private func tryAgain() {
            DispatchQueue.main.async {
                self.parent.scannedIngredient = nil
                self.parent.isNavigating = false
                NotificationCenter.default.post(name: NSNotification.Name("RestartScanner"), object: nil)
            }
        }

        private func navigateToIngredientSearch() {
            DispatchQueue.main.async {
                let searchView = AddIngredientBarcodePage(scannedIngredient: nil, userSession: self.parent.userSession)
                let hostingController = UIHostingController(rootView: searchView)
                if let rootVC = UIApplication.shared.windows.first?.rootViewController {
                    rootVC.present(hostingController, animated: true, completion: nil)
                }
            }
        }
    }
}
