import SwiftUI

struct ReceiptScannerView: UIViewControllerRepresentable {
    @Binding var scannedItems: [String]

    func makeUIViewController(context: Context) -> ReceiptScannerViewController {
        let viewController = ReceiptScannerViewController()
        viewController.onItemsScanned = { items in
            scannedItems = items // Update the SwiftUI view with scanned items
        }
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: ReceiptScannerViewController, context: Context) {
        // No updates needed
    }
}
