//
//  BarcodeScannerHelper.swift
//  SousChef
//
//  Created by Oliver Zolan on 3/13/25.
//

import UIKit
import SwiftUI

class BarcodeScannerHelper {
    static let shared = BarcodeScannerHelper()
    private let barcodeAPI = BarcodeAPIComponent()

    private init() {}

    func fetchIngredient(by upc: String, completion: @escaping (BarcodeModel?) -> Void) {
        barcodeAPI.fetchFoodByBarcode(upc: upc) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let barcodeModel):
                    completion(barcodeModel)
                case .failure(let error):
                    print("Error fetching ingredient: \(error)")
                    completion(nil)
                }
            }
        }
    }

    func showBarcodeNotRecognizedAlert(retryHandler: @escaping () -> Void, searchHandler: @escaping () -> Void) {
        DispatchQueue.main.async {
            let alert = UIAlertController(
                title: "Barcode Not Recognized",
                message: "The barcode you scanned could not be recognized. Would you like to try again or search manually?",
                preferredStyle: .alert
            )

            alert.addAction(UIAlertAction(title: "Try Again", style: .default, handler: { _ in retryHandler() }))
            alert.addAction(UIAlertAction(title: "Search Manually", style: .default, handler: { _ in searchHandler() }))

            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first(where: { $0.isKeyWindow }),
               let rootVC = window.rootViewController {
                
                var topVC = rootVC
                while let presentedVC = topVC.presentedViewController {
                    topVC = presentedVC
                }
                
                topVC.present(alert, animated: true, completion: nil)
            }
        }
    }
}
