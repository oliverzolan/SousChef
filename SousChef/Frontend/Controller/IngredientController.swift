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
    private var searchTerms: [String] = []
    private var searchCache: [String: [EdamamIngredientModel]] = [:]
    private var searchTask: DispatchWorkItem?
    private let searchDebounceTime: Double = 0.6

    init(userSession: UserSession) {
        self.userSession = userSession
    }

    // MARK: - Perform Search
    func performSearch() {
        guard !searchText.isEmpty else {
            searchResults = []
            return
        }
        
        // Cancel any previous search task
        searchTask?.cancel()
        
        // Create a new search task with debounce
        let task = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            self.executeSearch()
        }
        
        // Store the task
        searchTask = task
        
        // Schedule the task after debounce time
        DispatchQueue.main.asyncAfter(deadline: .now() + searchDebounceTime, execute: task)
    }
    
    // MARK: - Execute Search
    private func executeSearch() {
        // Make a local copy to ensure we're working with the correct value
        let currentSearchText = self.searchText
        
        // Normalize search text
        let normalizedSearchText = currentSearchText.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        print("Executing search for: '\(normalizedSearchText)'")
        
        // Don't search if the term is too short
        guard normalizedSearchText.count >= 2 else {
            self.searchResults = []
            return
        }
        
        // Use cached results if available
        if let cachedResults = searchCache[normalizedSearchText] {
            self.searchResults = cachedResults
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        // Break search into terms for better matching later
        searchTerms = normalizedSearchText.components(separatedBy: " ").filter { !$0.isEmpty }

        ingredientsAPI.searchIngredients(query: normalizedSearchText) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let response):
                    if response.hints.isEmpty {
                        // If no exact match found, try a broader search
                        if self.searchTerms.count > 1 {
                            // Try with just the first term (often the main ingredient)
                            let broadSearchTerm = self.searchTerms[0]
                            self.performBroadSearch(term: broadSearchTerm)
                        } else {
                            self.errorMessage = "No ingredients found."
                            self.searchResults = []
                        }
                        return
                    }
                    
                    // Get unique ingredients
                    let allIngredients = Array(Set(response.hints.map { $0.food }))
                    
                    // Sort results by relevance to the search query
                    let sortedIngredients = self.rankIngredientsByRelevance(allIngredients)
                    
                    // Cache results
                    self.searchCache[normalizedSearchText] = sortedIngredients
                    self.searchResults = sortedIngredients

                case .failure(let error):
                    print("API Error: \(error.localizedDescription)")
                    self.errorMessage = "Failed to fetch ingredients."
                }
            }
        }
    }
    
    // MARK: - Perform Broad Search
    private func performBroadSearch(term: String) {
        ingredientsAPI.searchIngredients(query: term) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let response):
                    if response.hints.isEmpty {
                        self.errorMessage = "No ingredients found."
                        self.searchResults = []
                        return
                    }
                    
                    // Get unique ingredients
                    let allIngredients = Array(Set(response.hints.map { $0.food }))
                    
                    // Filter and sort results to still prefer matches related to the original search
                    let sortedIngredients = self.rankIngredientsByRelevance(allIngredients)
                    
                    // Only show the most relevant results
                    self.searchResults = sortedIngredients
                    
                case .failure(let error):
                    print("API Error: \(error.localizedDescription)")
                    self.errorMessage = "Failed to fetch ingredients."
                }
            }
        }
    }
    
    // MARK: - Rank Ingredients by Relevance
    private func rankIngredientsByRelevance(_ ingredients: [EdamamIngredientModel]) -> [EdamamIngredientModel] {
        return ingredients.sorted { first, second in
            let firstLabel = first.label.lowercased()
            let secondLabel = second.label.lowercased()
            
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
        var score = 0
        let labelWords = label.lowercased().components(separatedBy: " ")
        
        // Higher score for matching more search terms
        for term in searchTerms {
            if label.contains(term) {
                score += 3
            }
            
            // Extra points if a word in the label exactly matches a search term
            if labelWords.contains(term) {
                score += 2
            }
        }
        
        // Award bonus points for terms appearing in the same order as search
        var lastFoundIndex = -1
        var orderBonus = 0
        
        for term in searchTerms {
            if let wordIndex = labelWords.firstIndex(where: { $0.contains(term) }) {
                if wordIndex > lastFoundIndex {
                    orderBonus += 1
                    lastFoundIndex = wordIndex
                }
            }
        }
        
        return score + orderBonus
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
