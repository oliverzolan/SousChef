//
//  IngredientController.swift
//  SousChef
//
//  Created by Oliver Zolan on 3/8/25.
//

import SwiftUI

class IngredientController: ObservableObject {
    @Published var searchText: String = ""
    @Published var searchResults: [EdamamIngredientModel] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let ingredientsAPI = EdamamIngredientsComponent()
    private let userSession: UserSession

    init(userSession: UserSession) {
        self.userSession = userSession
    }

    // MARK: - Perform Search
    func performSearch() {
        guard !searchText.isEmpty else {
            searchResults = []
            return
        }
        isLoading = true
        errorMessage = nil

        ingredientsAPI.searchIngredients(query: searchText) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let response):
                    print("API Response: \(response)")
                    if response.hints.isEmpty {
                        self.errorMessage = "No ingredients found."
                        self.searchResults = []
                        return
                    }
                    let uniqueIngredients = Array(Set(response.hints.map { $0.food })).sorted { $0.label < $1.label }
                    self.searchResults = uniqueIngredients

                case .failure(let error):
                    print("API Error: \(error.localizedDescription)")
                    self.errorMessage = "Failed to fetch ingredients."
                }
            }
        }
    }
    
    // MARK: - Add Recognized Food from FatSecret
    func addRecognizedFood(_ food: EdamamIngredientModel) {
        DispatchQueue.main.async {
            if !self.searchResults.contains(food) {
                self.searchResults.append(food)
            }
        }
    }

    // MARK: - Add Searched Ingredient
    func addIngredientToDatabase(_ ingredient: Any, completion: @escaping () -> Void) {
        let awsIngredient: AWSIngredientModel

        if let edamamIngredient = ingredient as? EdamamIngredientModel {
            awsIngredient = AWSIngredientModel(
                food: edamamIngredient.label,
                foodCategory: edamamIngredient.category ?? "Unknown",
                foodId: edamamIngredient.foodId,
                measure: "Serving",
                quantity: 1,
                text: edamamIngredient.label,
                weight: edamamIngredient.nutrients?.energy ?? 0.0
            )
        } else if let barcodeIngredient = ingredient as? BarcodeModel {
            awsIngredient = AWSIngredientModel(
                food: barcodeIngredient.label,
                foodCategory: barcodeIngredient.category ?? "Unknown",
                foodId: barcodeIngredient.foodId,
                measure: "Serving",
                quantity: 1,
                text: barcodeIngredient.label,
                weight: barcodeIngredient.nutrients?.energy ?? 0.0
            )
        } else {
            print("Error: Unsupported ingredient type.")
            return
        }

        let ingredientsAPI = AWSIngredientsComponent(userSession: userSession)

        ingredientsAPI.addIngredients(ingredients: [awsIngredient]) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    print("Ingredient added successfully: \(awsIngredient.text)")
                    completion()
                case .failure(let error):
                    print("Failed to add ingredient: \(error.localizedDescription)")
                }
            }
        }
    }

    // MARK: - Add Scanned Ingredient
    func addScannedIngredientToDatabase(_ ingredient: BarcodeModel, completion: @escaping () -> Void) {
        let awsIngredient = AWSIngredientModel(
            food: ingredient.label,
            foodCategory: ingredient.category ?? "Unknown",
            foodId: ingredient.foodId,
            measure: "Serving",
            quantity: 1,
            text: ingredient.label,
            weight: ingredient.nutrients?.energy ?? 0.0
        )

        let ingredientsAPI = AWSIngredientsComponent(userSession: userSession)

        ingredientsAPI.addIngredients(ingredients: [awsIngredient]) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    print("Scanned Ingredient added successfully: \(awsIngredient.text)")
                    completion()
                case .failure(let error):
                    print("Failed to add scanned ingredient: \(error.localizedDescription)")
                }
            }
        }
    }
}
