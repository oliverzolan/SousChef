import SwiftUI

struct ReceiptScannerView: UIViewControllerRepresentable {
    @Binding var scannedItems: [String]
    var userSession: UserSession
    
    func makeUIViewController(context: Context) -> LiveReceiptScannerViewController {
        // Create and return the receipt scanner view controller
        return LiveReceiptScannerViewController(userSession: userSession)
    }

    func updateUIViewController(_ uiViewController: LiveReceiptScannerViewController, context: Context) {
        // No update needed
    }
}

