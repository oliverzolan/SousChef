import SwiftUI

struct ReceiptScannerView: UIViewControllerRepresentable {
    @Binding var scannedItems: [String] // The SwiftUI state that receives the scanned items

    func makeUIViewController(context: Context) -> LiveReceiptScannerViewController {
        let viewController = LiveReceiptScannerViewController()
        return viewController
    }

    func updateUIViewController(_ uiViewController: LiveReceiptScannerViewController, context: Context) {
        // No updates are needed; the ViewController handles live updates
    }
}

