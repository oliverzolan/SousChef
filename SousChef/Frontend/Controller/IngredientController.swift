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

    // MARK: - Perform Search
    func performSearch() {
        guard !searchText.isEmpty else {
            searchResults = []
            return
        }
        
        searchTask?.cancel()
        
        let task = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            self.executeSearch()
        }
        
        // Store the task
        searchTask = task
        
        DispatchQueue.main.asyncAfter(deadline: .now() + searchDebounceTime, execute: task)
    }
    
    // MARK: - Mock Data
    
    // Provide mock data for testing or when the API fails
    private func getMockIngredients(for query: String) -> [AWSIngredientModel] {
        // Common ingredients as fallback
        let mockIngredientsBase = [
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
        
        // Add proper image URLs to mock ingredients
        let mockIngredients = mockIngredientsBase.map { ensureProperImageURL(ingredient: $0) }
        
        // Filter mock data based on query
        let normalizedQuery = query.lowercased()
        return mockIngredients.filter { $0.name.lowercased().contains(normalizedQuery) }
    }

    // MARK: - Execute Search
    private func executeSearch() {
        let currentSearchText = self.searchText
        let normalizedSearchText = currentSearchText.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard normalizedSearchText.count >= 2 else {
            self.searchResults = []
            return
        }
        if let cachedResults = searchCache[normalizedSearchText] {
            self.searchResults = cachedResults
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
                if mockResults.isEmpty {
                    self.errorMessage = "No ingredients found (using offline data)."
                } else {
                    self.searchResults = mockResults
                    self.searchCache[normalizedSearchText] = mockResults
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
                    
                    let sortedIngredients = self.rankIngredientsByRelevance(ingredients)
                    
                    // Map ingredients to ensure they have proper image URLs
                    let ingredientsWithImages = sortedIngredients.map { self.ensureProperImageURL(ingredient: $0) }
                    
                    // Reset retry count on success
                    self.retryCount = 0
                    self.shouldUseMockData = false
                    
                    // Cache results
                    self.searchCache[normalizedSearchText] = ingredientsWithImages
                    self.searchResults = ingredientsWithImages

                case .failure(let error):
                    if self.retryCount < self.maxRetries {
                        self.retryCount += 1
                        self.executeSearch()
                        return
                    }
                    
                    self.shouldUseMockData = true
                    let mockResults = self.getMockIngredients(for: normalizedSearchText)
                    
                    if mockResults.isEmpty {
                        self.errorMessage = "Could not connect to server. No offline results found."
                    } else {
                        self.errorMessage = "Using offline data. Some ingredients may not be available."
                        self.searchResults = mockResults
                        self.searchCache[normalizedSearchText] = mockResults
                    }
                }
            }
        }
    }
    
    // MARK: - Ensure Proper Image URL
    private func ensureProperImageURL(ingredient: AWSIngredientModel) -> AWSIngredientModel {
        // Check if the ingredient needs an updated image URL
        if ingredient.imageURL.isEmpty || 
           ingredient.imageURL.contains("amazonaws.com") || 
           (!ingredient.imageURL.contains(".webp") && !ingredient.imageURL.contains("cloudfront.net")) {
            
            // Use the image service to get the proper URL
            let imageURL = IngredientImageService.shared.getImageURL(
                for: ingredient.name,
                category: ingredient.foodCategory,
                existingURL: ingredient.imageURL
            )
            
            // Create updated ingredient with proper URL
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
        return ingredients.sorted { first, second in
            let firstLabel = first.name.lowercased()
            let secondLabel = second.name.lowercased()
            
            // Check for exact match with full search string
            let fullSearchText = searchText.lowercased()
            let firstExactMatch = firstLabel == fullSearchText
            let secondExactMatch = secondLabel == fullSearchText
            
            if firstExactMatch && !secondExactMatch {
                return true
            } else if !firstExactMatch && secondExactMatch {
                return false
            }
            
            // Check if label starts with search term
            let firstStartsWithSearch = firstLabel.hasPrefix(fullSearchText)
            let secondStartsWithSearch = secondLabel.hasPrefix(fullSearchText)
            
            if firstStartsWithSearch && !secondStartsWithSearch {
                return true
            } else if !firstStartsWithSearch && secondStartsWithSearch {
                return false
            }
            
            // Score based on how many terms match and their order
            let firstMatchScore = getMatchScore(label: firstLabel)
            let secondMatchScore = getMatchScore(label: secondLabel)
            
            if firstMatchScore != secondMatchScore {
                return firstMatchScore > secondMatchScore
            }
            
            // As a final tiebreaker, use alphabetical order
            return firstLabel < secondLabel
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

    // MARK: - Add Searched Ingredient
    func addIngredientToDatabase(_ ingredient: Any, completion: @escaping () -> Void) {
        let awsIngredient: AWSIngredientModel

        if let internalIngredient = ingredient as? AWSIngredientModel {
            awsIngredient = internalIngredient
        } else if let barcodeIngredient = ingredient as? BarcodeModel {
            awsIngredient = AWSIngredientModel(
                edamamFoodId: barcodeIngredient.foodId,
                foodCategory: barcodeIngredient.category ?? "Unknown",
                name: barcodeIngredient.label,
                quantityType: "Serving",
                experiationDuration: 7,
                imageURL: ""
            )
        } else {
            print("Error: Unsupported ingredient type.")
            return
        }

        let ingredientsAPI = AWSUserIngredientsComponent(userSession: userSession)

        ingredientsAPI.addIngredients(ingredients: [awsIngredient]) { result in
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

    // MARK: - Add Scanned Ingredient
    func addScannedIngredientToDatabase(_ ingredient: BarcodeModel, completion: @escaping () -> Void) {
        // Check if this is a generic ingredient already (from our helper)
        let ingredientName = ingredient.label.lowercased()
        
        // Create AWS ingredient from the barcode data
        let awsIngredient = AWSIngredientModel(
            edamamFoodId: ingredient.foodId,
            foodCategory: ingredient.category ?? "Unknown",
            name: ingredient.label,
            quantityType: "Serving",
            experiationDuration: 7,
            imageURL: ""
        )
        
        // Ensure we have a proper image URL for the ingredient
        let formattedIngredient = ensureProperImageURL(ingredient: awsIngredient)

        let ingredientsAPI = AWSUserIngredientsComponent(userSession: userSession)

        ingredientsAPI.addIngredients(ingredients: [formattedIngredient]) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    print("Scanned Ingredient added successfully: \(formattedIngredient.name)")
                    completion()
                case .failure(let error):
                    print("Failed to add scanned ingredient: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - Get Basic Ingredients List
    func getBasicIngredientsList() -> [String] {
        return [
            "apple", "banana", "carrot", "onion", "garlic", "potato", "tomato", "chicken", "beef", "pork",
            "fish", "rice", "pasta", "cheese", "milk", "butter", "salt", "sugar", "flour", "egg",
            "pepper", "olive oil", "lemon", "lime", "bread", "spinach", "broccoli", "cucumber", "lettuce",
            "mushroom", "corn", "peanut butter", "honey", "chocolate", "cream", "yogurt", "beans",
            "peas", "lentils", "avocado", "chili", "soy sauce", "vinegar", "basil", "parsley", "cilantro",
            "mint", "rosemary", "thyme", "oregano", "paprika", "cinnamon", "cumin", "turmeric",
            "ginger", "watermelon", "strawberry", "blueberry", "raspberry", "orange", "peach",
            "pear", "grape", "pineapple", "coconut", "almond", "walnut", "cashew", "hazelnut",
            "shrimp", "crab", "lobster", "salmon", "tuna", "cod", "bread crumbs", "zucchini",
            "eggplant", "bell pepper", "cauliflower", "cabbage", "celery", "kale", "chard",
            "beet", "radish", "asparagus", "artichoke", "leek", "scallion", "bok choy",
            "tofu", "tempeh", "seitan", "quinoa", "bulgur", "oats", "barley", "chia", "flaxseed"
        ]
    }
}
