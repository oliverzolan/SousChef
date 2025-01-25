import SwiftUI

struct ReceiptScannerView: UIViewControllerRepresentable {
    @Binding var scannedItems: [String]

    func makeUIViewController(context: Context) -> LiveReceiptScannerViewController {
        let viewController = LiveReceiptScannerViewController()
        return viewController
    }

    func updateUIViewController(_ uiViewController: LiveReceiptScannerViewController, context: Context) {
    }
}

