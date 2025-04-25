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
    private var knownIngredients: [String] = []

    private init() {
        knownIngredients = []
        loadIngredientsFromJson()
        Task { await loadIngredientsList() }
    }
    
    private func loadIngredientsFromJson() {
        if let path = Bundle.main.path(forResource: "ingredients", ofType: "json", inDirectory: "Backend/Components/ReceiptScanner") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path))
                let decoder = JSONDecoder()
                knownIngredients = try decoder.decode([String].self, from: data)
            } catch {
                print("Error loading ingredients from JSON: \(error)")
                // Fallback to basic ingredients if json loading fails
                knownIngredients = [
                    "apple", "banana", "carrot", "onion", "garlic", "potato", "tomato", "chicken", "beef", "pork",
                    "fish", "rice", "pasta", "cheese", "milk", "butter", "salt", "sugar", "flour", "egg", "lettuce"
                ]
            }
        }
    }
    
    @MainActor
    private func loadIngredientsList() async {
        if let userSession = await getUserSession() {
            let ingredientController = IngredientController(userSession: userSession)
            knownIngredients = ingredientController.getBasicIngredientsList()
        }
    }
    
    @MainActor
    private func getUserSession() async -> UserSession? {
        return UserSession()
    }

    func fetchIngredient(by upc: String, completion: @escaping (BarcodeModel?) -> Void) {
        if knownIngredients.isEmpty {
            Task { await loadIngredientsList() }
        }
        
        barcodeAPI.fetchFoodByBarcode(upc: upc) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let barcodeModel):
                    // If we found a barcode, try to match it to our ingredient database
                    if let barcodeModel = barcodeModel {
                        if let matchedIngredient = self.matchToKnownIngredient(barcodeModel) {
                            completion(matchedIngredient)
                        } else {
                            // No match found in our database: fallback to nil so only one alert is shown
                            completion(nil)
                        }
                    } else {
                        completion(nil)
                    }
                case .failure(let error):
                    print("Error fetching ingredient: \(error)")
                    completion(nil)
                }
            }
        }
    }
    
    private func matchToKnownIngredient(_ scannedItem: BarcodeModel) -> BarcodeModel? {
        // Convert product name to lowercase for comparison
        let scannedName = scannedItem.label.lowercased()
                
        // 1. Direct match
        if knownIngredients.contains(scannedName) {
            return createGenericIngredient(from: scannedItem, with: scannedName)
        }
        
        // 2. Check if the scanned item contains any of our known ingredients
        for ingredient in knownIngredients {
            if scannedName.contains(ingredient) {
                return createGenericIngredient(from: scannedItem, with: ingredient)
            }
        }
        
        // 3. Word-by-word matching
        let scannedWords = scannedName.split(separator: " ").map { String($0) }
        for word in scannedWords {
            if knownIngredients.contains(word) {
                return createGenericIngredient(from: scannedItem, with: word)
            }
        }
        
        // No match found in our ingredient database
        return nil
    }
    
    private func createGenericIngredient(from scannedItem: BarcodeModel, with ingredientName: String) -> BarcodeModel {
        return BarcodeModel(
            foodId: scannedItem.foodId,
            label: ingredientName.capitalized,
            brand: nil,
            category: scannedItem.category,
            image: scannedItem.image,
            nutrients: scannedItem.nutrients
        )
    }

    func showBarcodeNotRecognizedAlert(retryHandler: @escaping () -> Void, searchHandler: @escaping () -> Void) {
        DispatchQueue.main.async {
            let alert = UIAlertController(
                title: "Barcode Not Found",
                message: "The barcode is not found in our food database. Would you like to try again or search manually?",
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
    
    func showIngredientNotInDatabaseAlert(ingredient: String, retryHandler: @escaping () -> Void) {
        DispatchQueue.main.async {
            let alert = UIAlertController(
                title: "Ingredient Not Found",
                message: "'\(ingredient)' is not in our ingredient database. Scan another item or search manually.",
                preferredStyle: .alert
            )

            alert.addAction(UIAlertAction(title: "Try Another", style: .default, handler: { _ in
                NotificationCenter.default.post(name: NSNotification.Name("RestartScanner"), object: nil)
                retryHandler()
            }))
            
            alert.addAction(UIAlertAction(title: "Search Manually", style: .default, handler: { _ in
                // Navigate to search
                NotificationCenter.default.post(name: NSNotification.Name("NavigateToIngredientSearch"), object: nil)
            }))

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
