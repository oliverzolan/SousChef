//
//  IngredientController.swift
//  SousChef
//
//  Created by Oliver Zolan on 3/8/25.
//
import SwiftUI

class IngredientController: ObservableObject {
    @Published var searchText: String = ""
    @Published var searchResults: [AWSIngredientModel] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    

    private let ingredientsAPI: AWSInternalIngredientsComponent
    private let userSession: UserSession
    private var searchTerms: [String] = []
    private var searchCache: [String: [AWSIngredientModel]] = [:]
    private var searchTask: DispatchWorkItem?
    private let searchDebounceTime: Double = 0.6
    private var shouldUseMockData: Bool = false
    private var retryCount: Int = 0
    private let maxRetries: Int = 1

    init(userSession: UserSession) {
        self.userSession = userSession
        self.ingredientsAPI = AWSInternalIngredientsComponent(userSession: userSession)
    }
    
    @MainActor
    // MARK: - Perform Search
    func performSearch() {
        guard !searchText.isEmpty else {
            searchResults = []
            return
        }

        searchTask?.cancel()

        let task = DispatchWorkItem { [weak self] in
            self?.executeSearch()
        }

        searchTask = task
        DispatchQueue.main.asyncAfter(deadline: .now() + searchDebounceTime, execute: task)
    }

    // MARK: - Execute Search
    @MainActor
    private func executeSearch() {
        let normalizedSearchText = searchText.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)

        guard normalizedSearchText.count >= 2 else {
            self.searchResults = []
            return
        }

        if let cached = searchCache[normalizedSearchText] {
            self.searchResults = cached
            return
        }

        isLoading = true
        errorMessage = nil
        searchTerms = normalizedSearchText.components(separatedBy: " ").filter { !$0.isEmpty }

        if shouldUseMockData {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                guard let self = self else { return }
                self.isLoading = false
                let mockResults = self.getMockIngredients(for: normalizedSearchText)
                self.searchResults = mockResults
                self.searchCache[normalizedSearchText] = mockResults
                if mockResults.isEmpty {
                    self.errorMessage = "No ingredients found (using offline data)."
                }
            }
            return
        }

        ingredientsAPI.searchIngredients(query: normalizedSearchText) { [weak self] result in
            guard let self = self else { return }

            DispatchQueue.main.async {
                self.isLoading = false

                switch result {
                case .success(let ingredients):
                    if ingredients.isEmpty {
                        self.errorMessage = "No ingredients found."
                        self.searchResults = []
                        return
                    }

                    let sorted = self.rankIngredientsByRelevance(ingredients)
                    let enriched = sorted.map { self.ensureProperImageURL(ingredient: $0) }

                    self.retryCount = 0
                    self.shouldUseMockData = false
                    self.searchResults = enriched
                    self.searchCache[normalizedSearchText] = enriched

                case .failure:
                    if self.retryCount < self.maxRetries {
                        self.retryCount += 1
                        self.executeSearch()
                        return
                    }

                    self.shouldUseMockData = true
                    let mockResults = self.getMockIngredients(for: normalizedSearchText)
                    self.searchResults = mockResults
                    self.searchCache[normalizedSearchText] = mockResults

                    self.errorMessage = mockResults.isEmpty
                        ? "Could not connect to server. No offline results found."
                        : "Using offline data. Some ingredients may not be available."
                }
            }
        }
    }

    // MARK: - Ensure Proper Image URL
    private func ensureProperImageURL(ingredient: AWSIngredientModel) -> AWSIngredientModel {
        if ingredient.imageURL.isEmpty ||
            ingredient.imageURL.contains("amazonaws.com") ||
            (!ingredient.imageURL.contains(".webp") && !ingredient.imageURL.contains("cloudfront.net")) {

            let imageURL = IngredientImageService.shared.getImageURL(
                for: ingredient.name,
                category: ingredient.foodCategory,
                existingURL: ingredient.imageURL
            )

            return AWSIngredientModel(
                edamamFoodId: ingredient.edamamFoodId,
                foodCategory: ingredient.foodCategory,
                name: ingredient.name,
                quantityType: ingredient.quantityType,
                experiationDuration: ingredient.experiationDuration,
                imageURL: imageURL
            )
        }

        return ingredient
    }

    // MARK: - Rank Ingredients by Relevance
    private func rankIngredientsByRelevance(_ ingredients: [AWSIngredientModel]) -> [AWSIngredientModel] {
        let fullSearchText = searchText.lowercased()

        return ingredients.sorted { a, b in
            let aName = a.name.lowercased()
            let bName = b.name.lowercased()

            if aName == fullSearchText { return true }
            if bName == fullSearchText { return false }

            if aName.hasPrefix(fullSearchText) { return true }
            if bName.hasPrefix(fullSearchText) { return false }

            let aScore = getMatchScore(label: aName)
            let bScore = getMatchScore(label: bName)

            return aScore == bScore ? aName < bName : aScore > bScore
        }
    }

    // MARK: - Calculate Match Score
    private func getMatchScore(label: String) -> Int {
        let searchTerms = searchText.lowercased().components(separatedBy: .whitespaces)
        let labelTerms = label.components(separatedBy: .whitespaces)

        var score = 0
        for (index, term) in searchTerms.enumerated() {
            if index < labelTerms.count && labelTerms[index].hasPrefix(term) {
                score += 1
            }
        }
        return score
    }

    // MARK: - Add Recognized Food
    func addRecognizedFood(_ food: AWSIngredientModel) {
        DispatchQueue.main.async {
            if !self.searchResults.contains(where: { $0.edamamFoodId == food.edamamFoodId }) {
                self.searchResults.append(food)
            }
        }
    }

    // MARK: - Add Ingredient to Database
    @MainActor
    func addIngredientToDatabase(_ ingredient: Any, completion: @escaping () -> Void) {
        let awsIngredient: AWSIngredientModel

        if let internalIngredient = ingredient as? AWSIngredientModel {
            awsIngredient = internalIngredient
        } else if let barcode = ingredient as? BarcodeModel {
            awsIngredient = AWSIngredientModel(
                edamamFoodId: barcode.foodId,
                foodCategory: barcode.category ?? "Unknown",
                name: barcode.label,
                quantityType: "Serving",
                experiationDuration: 7,
                imageURL: ""
            )
        } else {
            print("Error: Unsupported ingredient type.")
            return
        }

        let api = AWSUserIngredientsComponent(userSession: userSession)

        api.addIngredients(ingredients: [awsIngredient]) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    print("Ingredient added successfully: \(awsIngredient.name)")
                    completion()
                case .failure(let error):
                    print("Failed to add ingredient: \(error.localizedDescription)")
                }
            }
        }
    }

    // MARK: - Add Scanned Ingredient to Database
    @MainActor
    func addScannedIngredientToDatabase(_ ingredient: BarcodeModel, completion: @escaping () -> Void) {
        let awsIngredient = AWSIngredientModel(
            edamamFoodId: ingredient.foodId,
            foodCategory: ingredient.category ?? "Unknown",
            name: ingredient.label,
            quantityType: "Serving",
            experiationDuration: 7,
            imageURL: ""
        )

        let api = AWSUserIngredientsComponent(userSession: userSession)

        api.addIngredients(ingredients: [awsIngredient]) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    print("Scanned Ingredient added successfully: \(awsIngredient.name)")
                    completion()
                case .failure(let error):
                    print("Failed to add scanned ingredient: \(error.localizedDescription)")
                }
            }
        }
    }

    // MARK: - Mock Data for Offline Support
    private func getMockIngredients(for query: String) -> [AWSIngredientModel] {
        let mockBase = [
            AWSIngredientModel(edamamFoodId: "food_a1gb9ubb72c7snbuxr3weagwv0dd", foodCategory: "Meat", name: "Chicken breast", quantityType: "Serving", experiationDuration: 3, imageURL: ""),
            AWSIngredientModel(edamamFoodId: "food_b0mywndg6pe8jxb2x8nopa8gj60q", foodCategory: "Meat", name: "Chicken thigh", quantityType: "Serving", experiationDuration: 3, imageURL: ""),
            AWSIngredientModel(edamamFoodId: "food_bdrxu94aj3x2djbpur8dhagfhkcn", foodCategory: "Meat", name: "Chicken wings", quantityType: "Serving", experiationDuration: 3, imageURL: ""),
            AWSIngredientModel(edamamFoodId: "food_bpbsh0aab089s4bnzjgfrbpc3301", foodCategory: "Dairy", name: "Cheese", quantityType: "Serving", experiationDuration: 14, imageURL: ""),
            AWSIngredientModel(edamamFoodId: "food_bhppgmha1u27voagb8eptbp9g376", foodCategory: "Dairy", name: "Milk", quantityType: "Cup", experiationDuration: 7, imageURL: ""),
            AWSIngredientModel(edamamFoodId: "food_a6201h8buzt40ebrr6lo7bkgj8g4", foodCategory: "Vegetable", name: "Onion", quantityType: "Whole", experiationDuration: 30, imageURL: ""),
            AWSIngredientModel(edamamFoodId: "food_b0759vvai2ugfcbzr9hp6avcwqth", foodCategory: "Vegetable", name: "Garlic", quantityType: "Clove", experiationDuration: 60, imageURL: ""),
            AWSIngredientModel(edamamFoodId: "food_a7hgthbbhj1qm6bnx79mybkgxcvq", foodCategory: "Vegetable", name: "Tomato", quantityType: "Whole", experiationDuration: 7, imageURL: ""),
            AWSIngredientModel(edamamFoodId: "food_bnbh4ycaqj9as0ay861deatgd0dd", foodCategory: "Grain", name: "Rice", quantityType: "Cup", experiationDuration: 365, imageURL: ""),
            AWSIngredientModel(edamamFoodId: "food_blrpqo2bs9n22xaugiv2panns3w9", foodCategory: "Grain", name: "Pasta", quantityType: "Serving", experiationDuration: 365, imageURL: "")
        ]

        let normalizedQuery = query.lowercased()
        return mockBase.map { ensureProperImageURL(ingredient: $0) }
                       .filter { $0.name.lowercased().contains(normalizedQuery) }
    }
}
