//
//  HomepageController.swift
//  SousChef
//
//  Created by Oliver Zolan on 3/30/25.
//

import Foundation
import SwiftUI

class HomepageController: ObservableObject {
    @Published var featuredRecipes: [EdamamRecipeModel] = []
    @Published var pantryRecipes: [EdamamRecipeModel] = []
    @Published var allPantryRecipes: [EdamamRecipeModel] = []

    private let pantryController: PantryController

    private let featuredCacheKey = "cachedFeaturedRecipes"
    private let pantryRecipesCacheKey = "cachedPantryRecipes"
    private let allPantryRecipesCacheKey = "cachedAllPantryRecipes"
    private let timestampKey = "cachedFeaturedTimestamp"
    private let pantryTimestampKey = "cachedPantryTimestamp"
    
    private let allIngredients = [
        "chicken", "pasta", "rice", "tomato", "bell pepper", "beef", "tofu", "broccoli", "potato", 
        "egg", "cheese", "spinach", "onion", "garlic", "carrot", "salmon", "bacon"
    ]

    init(pantryController: PantryController) {
        self.pantryController = pantryController
        loadCachedFeaturedRecipes()
        loadCachedPantryRecipes()
        refreshIfExpired()
        fetchPantryRecipesIfNeeded()
        
        // Register for pantry changes
        pantryController.onPantryItemsChanged = { [weak self] in
            self?.refreshPantryRecipes()
        }
    }

    func fetchFeaturedRecipes() {
        refreshIfExpired()
    }
    
    private func loadCachedPantryRecipes() {
        // Load pantry recipes
        if let data = UserDefaults.standard.data(forKey: pantryRecipesCacheKey),
           let decoded = try? JSONDecoder().decode([EdamamRecipeModel].self, from: data) {
            self.pantryRecipes = decoded
        } else {
            self.pantryRecipes = []
        }
        
        // Load all pantry recipes
        if let data = UserDefaults.standard.data(forKey: allPantryRecipesCacheKey),
           let decoded = try? JSONDecoder().decode([EdamamRecipeModel].self, from: data) {
            self.allPantryRecipes = decoded
        } else {
            self.allPantryRecipes = []
        }
    }
    
    private func cachePantryRecipes() {
        if let encoded = try? JSONEncoder().encode(pantryRecipes) {
            UserDefaults.standard.set(encoded, forKey: pantryRecipesCacheKey)
        }
        
        if let encoded = try? JSONEncoder().encode(allPantryRecipes) {
            UserDefaults.standard.set(encoded, forKey: allPantryRecipesCacheKey)
        }
        
        UserDefaults.standard.set(Date(), forKey: pantryTimestampKey)
    }
    
    private func isPantryRecipesCacheExpired() -> Bool {
        guard let timestamp = UserDefaults.standard.object(forKey: pantryTimestampKey) as? Date else {
            return true
        }
        // Cache expires after 24 hours
        return Date().timeIntervalSince(timestamp) > 86400
    }

    func fetchPantryRecipesIfNeeded() {
        // Fetch if cache is empty or expired
        if pantryRecipes.isEmpty || allPantryRecipes.isEmpty || isPantryRecipesCacheExpired() {
            fetchPantryRecipes()
        }
    }
    
    // Called when a new ingredient is added to pantry
    func refreshPantryRecipes() {
        fetchPantryRecipes()
    }

    func fetchPantryRecipes() {
        // Makes sure pantry ingredients are fetched
        if pantryController.pantryItems.isEmpty {
            pantryController.fetchIngredients()

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.queryPantryBasedRecipes()
            }
        } else {
            queryPantryBasedRecipes()
        }
    }

    private func queryPantryBasedRecipes() {
        let pantryItems = pantryController.pantryItems
        guard !pantryItems.isEmpty else { 
            print("No pantry items found, using default ingredients")
            fetchDefaultPantryRecipes()
            return 
        }

        let ingredientNames = pantryItems.map { $0.food }

        // For display grid (3 recipes)
        var selectedIngredients = Set<String>()
        var attempts = 0
        while selectedIngredients.count < min(3, ingredientNames.count) && attempts < 20 {
            if let random = ingredientNames.randomElement() {
                selectedIngredients.insert(random)
            }
            attempts += 1
        }

        let ingredientsToQuery = ingredientNames.count < 3
            ? Array(ingredientNames)
            : Array(selectedIngredients)
        
        let api = EdamamRecipeComponent()
        let group = DispatchGroup()
        var fetchedForGrid: [EdamamRecipeModel] = []
        var fetchedAll: [EdamamRecipeModel] = []

        // First fetch for the grid display (3 recipes)
        for ingredient in ingredientsToQuery {
            group.enter()
            api.searchRecipes(query: ingredient) { result in
                defer { group.leave() }
                
                switch result {
                case .success(let response):
                    if !response.hits.isEmpty {
                        // Get recipes for the main grid display
                        let recipes = response.hits.prefix(2).map { $0.recipe }
                        fetchedForGrid.append(contentsOf: recipes)
                    }
                case .failure(let error):
                    print("Error fetching recipes for \(ingredient): \(error.localizedDescription)")
                }
            }
        }
        
        // Fetch all pantry ingredients for the "More" view
        let allGroup = DispatchGroup()
        for ingredient in ingredientNames {
            allGroup.enter()
            api.searchRecipes(query: ingredient) { result in
                defer { allGroup.leave() }
                
                switch result {
                case .success(let response):
                    if !response.hits.isEmpty {
                        // Grabs up to 5 recipes per ingredient for the "More" view
                        let recipes = response.hits.prefix(5).map { $0.recipe }
                        fetchedAll.append(contentsOf: recipes)
                    }
                case .failure(let error):
                    print("Error fetching all pantry recipes: \(error.localizedDescription)")
                }
            }
        }
        
        group.notify(queue: .main) {
            if fetchedForGrid.isEmpty {
                print("No pantry recipes found for grid, using default recipes")
                self.fetchDefaultPantryRecipes()
            } else {
                print("Found \(fetchedForGrid.count) pantry recipes for grid")
                self.pantryRecipes = fetchedForGrid
                
                // Cache immediately to ensure we have something
                if let encoded = try? JSONEncoder().encode(fetchedForGrid) {
                    UserDefaults.standard.set(encoded, forKey: self.pantryRecipesCacheKey)
                }
            }
        }
        
        allGroup.notify(queue: .main) {
            if fetchedAll.isEmpty {
                print("No pantry recipes found for 'More' view, using defaults")
                // Use the grid recipes if "More" recipes failed to load
                self.allPantryRecipes = self.pantryRecipes
            } else {
                print("Found \(fetchedAll.count) pantry recipes for 'More' view")
                self.allPantryRecipes = fetchedAll
                
                // Cache all recipes
                self.cachePantryRecipes()
            }
        }
    }

    private func fetchDefaultPantryRecipes() {
        // Use some popular ingredients as fallback
        let defaultIngredients = ["chicken", "pasta", "rice", "potato", "tomato"]
        let selectedDefaults = defaultIngredients.shuffled().prefix(3)
        
        let api = EdamamRecipeComponent()
        let gridGroup = DispatchGroup()
        var fetchedForGrid: [EdamamRecipeModel] = []
        
        for ingredient in selectedDefaults {
            gridGroup.enter()
            api.searchRecipes(query: ingredient) { result in
                defer { gridGroup.leave() }
                
                if case .success(let response) = result, 
                   !response.hits.isEmpty {
                    // Get a single recipe per default ingredient
                    if let recipe = response.hits.first?.recipe {
                        fetchedForGrid.append(recipe)
                    }
                }
            }
        }
        
        // Fetch more recipes for the "More" view
        let allGroup = DispatchGroup()
        var fetchedAll: [EdamamRecipeModel] = []
        
        for ingredient in defaultIngredients {
            allGroup.enter()
            api.searchRecipes(query: ingredient) { result in
                defer { allGroup.leave() }
                
                if case .success(let response) = result, 
                   !response.hits.isEmpty {
                    let recipes = response.hits.prefix(3).map { $0.recipe }
                    fetchedAll.append(contentsOf: recipes)
                }
            }
        }
        
        gridGroup.notify(queue: .main) {
            if !fetchedForGrid.isEmpty {
                self.pantryRecipes = fetchedForGrid
                
                // Cache immediately
                if let encoded = try? JSONEncoder().encode(fetchedForGrid) {
                    UserDefaults.standard.set(encoded, forKey: self.pantryRecipesCacheKey)
                }
            } else {
                // Use empty array
                self.pantryRecipes = []
            }
        }
        
        allGroup.notify(queue: .main) {
            if !fetchedAll.isEmpty {
                self.allPantryRecipes = fetchedAll
                
                // Cache all recipes
                if let encoded = try? JSONEncoder().encode(fetchedAll) {
                    UserDefaults.standard.set(encoded, forKey: self.allPantryRecipesCacheKey)
                }
                
                UserDefaults.standard.set(Date(), forKey: self.pantryTimestampKey)
            } else {
                // Use grid recipes as last resort
                self.allPantryRecipes = self.pantryRecipes
            }
        }
    }

    private func loadCachedFeaturedRecipes() {
        if let data = UserDefaults.standard.data(forKey: featuredCacheKey),
           let decoded = try? JSONDecoder().decode([EdamamRecipeModel].self, from: data) {
            self.featuredRecipes = decoded
        } else {
            // Use empty array instead of placeholders
            self.featuredRecipes = []
        }
    }

    private func refreshIfExpired() {
        if let timestamp = UserDefaults.standard.object(forKey: timestampKey) as? Date,
           Date().timeIntervalSince(timestamp) < 86400 {
            return
        }

        generateNewFeaturedRecipes()
    }

    func generateNewFeaturedRecipes() {
        var selectedIngredients = Set<String>()
        while selectedIngredients.count < 3 {
            if let random = allIngredients.randomElement() {
                selectedIngredients.insert(random)
            }
        }

        let api = EdamamRecipeComponent()
        let group = DispatchGroup()
        var fetched: [EdamamRecipeModel] = []

        for ingredient in selectedIngredients {
            group.enter()
            api.searchRecipes(query: ingredient) { result in
                if case .success(let response) = result,
                   let recipe = response.hits.first?.recipe {
                    fetched.append(recipe)
                }
                group.leave()
            }
        }

        group.notify(queue: .main) {
            if !fetched.isEmpty {
                self.featuredRecipes = fetched

                if let encoded = try? JSONEncoder().encode(fetched) {
                    UserDefaults.standard.set(encoded, forKey: self.featuredCacheKey)
                    UserDefaults.standard.set(Date(), forKey: self.timestampKey)
                }
            }
        }
    }
}
