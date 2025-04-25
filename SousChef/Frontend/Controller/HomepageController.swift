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

        // ✅ Wrap MainActor-isolated calls in Task
        Task { @MainActor in
            await fetchPantryRecipesIfNeeded()
        }

        // ✅ Wrap pantry change handler in Task
        pantryController.onPantryItemsChanged = { [weak self] in
            Task { @MainActor in
                await self?.refreshPantryRecipes()
            }
        }
    }

    func fetchFeaturedRecipes() {
        refreshIfExpired()
    }
    
    private func loadCachedPantryRecipes() {
        if let data = UserDefaults.standard.data(forKey: pantryRecipesCacheKey),
           let decoded = try? JSONDecoder().decode([EdamamRecipeModel].self, from: data) {
            self.pantryRecipes = decoded
        } else {
            self.pantryRecipes = []
        }

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
        return Date().timeIntervalSince(timestamp) > 86400
    }

    @MainActor func fetchPantryRecipesIfNeeded() {
        if pantryRecipes.isEmpty || allPantryRecipes.isEmpty || isPantryRecipesCacheExpired() {
            fetchPantryRecipes()
        }
    }

    @MainActor func refreshPantryRecipes() {
        fetchPantryRecipes()
    }

    @MainActor func fetchPantryRecipes() {
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

        let ingredientNames = pantryItems.map { $0.name }

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

        for ingredient in ingredientsToQuery {
            group.enter()
            api.searchRecipes(query: ingredient) { result in
                defer { group.leave() }
                if case .success(let response) = result {
                    let recipes = response.hits.prefix(2).map { $0.recipe }
                    fetchedForGrid.append(contentsOf: recipes)
                }
            }
        }

        let allGroup = DispatchGroup()
        for ingredient in ingredientNames {
            allGroup.enter()
            api.searchRecipes(query: ingredient) { result in
                defer { allGroup.leave() }
                if case .success(let response) = result {
                    let recipes = response.hits.prefix(5).map { $0.recipe }
                    fetchedAll.append(contentsOf: recipes)
                }
            }
        }

        group.notify(queue: .main) {
            if fetchedForGrid.isEmpty {
                print("No pantry recipes found for grid, using default recipes")
                self.fetchDefaultPantryRecipes()
            } else {
                self.pantryRecipes = fetchedForGrid
                if let encoded = try? JSONEncoder().encode(fetchedForGrid) {
                    UserDefaults.standard.set(encoded, forKey: self.pantryRecipesCacheKey)
                }
            }
        }

        allGroup.notify(queue: .main) {
            if fetchedAll.isEmpty {
                self.allPantryRecipes = self.pantryRecipes
            } else {
                self.allPantryRecipes = fetchedAll
                self.cachePantryRecipes()
            }
        }
    }

    private func fetchDefaultPantryRecipes() {
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
                   let recipe = response.hits.first?.recipe {
                    fetchedForGrid.append(recipe)
                }
            }
        }

        let allGroup = DispatchGroup()
        var fetchedAll: [EdamamRecipeModel] = []

        for ingredient in defaultIngredients {
            allGroup.enter()
            api.searchRecipes(query: ingredient) { result in
                defer { allGroup.leave() }
                if case .success(let response) = result {
                    let recipes = response.hits.prefix(3).map { $0.recipe }
                    fetchedAll.append(contentsOf: recipes)
                }
            }
        }

        gridGroup.notify(queue: .main) {
            self.pantryRecipes = fetchedForGrid
            if let encoded = try? JSONEncoder().encode(fetchedForGrid) {
                UserDefaults.standard.set(encoded, forKey: self.pantryRecipesCacheKey)
            }
        }

        allGroup.notify(queue: .main) {
            self.allPantryRecipes = fetchedAll.isEmpty ? fetchedForGrid : fetchedAll
            if let encoded = try? JSONEncoder().encode(self.allPantryRecipes) {
                UserDefaults.standard.set(encoded, forKey: self.allPantryRecipesCacheKey)
            }
            UserDefaults.standard.set(Date(), forKey: self.pantryTimestampKey)
        }
    }

    private func loadCachedFeaturedRecipes() {
        if let data = UserDefaults.standard.data(forKey: featuredCacheKey),
           let decoded = try? JSONDecoder().decode([EdamamRecipeModel].self, from: data) {
            self.featuredRecipes = decoded
        } else {
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
                defer { group.leave() }
                if case .success(let response) = result,
                   let recipe = response.hits.first?.recipe {
                    fetched.append(recipe)
                }
            }
        }

        group.notify(queue: .main) {
            self.featuredRecipes = fetched
            if let encoded = try? JSONEncoder().encode(fetched) {
                UserDefaults.standard.set(encoded, forKey: self.featuredCacheKey)
                UserDefaults.standard.set(Date(), forKey: self.timestampKey)
            }
        }
    }
}
