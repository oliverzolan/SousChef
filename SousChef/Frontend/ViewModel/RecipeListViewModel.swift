import Foundation
import SwiftUI

class RecipeListViewModel: ObservableObject {
    @Published var recipes: [EdamamRecipeModel] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    @Published var hasMoreRecipes = true
    
    private var currentPage = 0
    private var nextPageUrl: String? = nil
    private var currentQuery = ""
    private var currentCuisineType: String? = nil
    private var isFeaturedQuery = false
    
    private let allIngredients = [
        "chicken", "pasta", "rice", "tomato", "bell pepper", "beef", "tofu", "broccoli", 
        "potato", "salmon", "chocolate", "cheese", "mushroom", "spinach", "avocado", 
        "garlic", "onion", "lemon", "orange", "apple", "berries", "banana", "eggs", 
        "bacon", "quinoa", "kale", "bean", "chickpea", "lentil", "carrot", "cucumber"
    ]
    
    private var usedFeaturedIngredients: [String] = []
    
    func fetchRecipes(query: String, limit: Int = 20) {
        guard !query.isEmpty else {
            self.recipes = []
            return
        }
        
        currentQuery = query
        currentCuisineType = nil
        isFeaturedQuery = false
        currentPage = 0
        recipes = []
        
        isLoading = true
        errorMessage = nil
        
        let api = EdamamRecipeComponent()
        api.searchRecipes(query: query) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let response):
                    // Limit recipes to the specified count
                    let allRecipes = response.hits.map { $0.recipe }
                    self?.recipes = Array(allRecipes.prefix(limit))
                    self?.nextPageUrl = response._links?.next?.href
                    self?.hasMoreRecipes = (self?.nextPageUrl != nil) || (allRecipes.count > limit)
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func fetchRecipesByCuisine(cuisineType: String, limit: Int = 20) {
        currentQuery = ""
        currentCuisineType = cuisineType
        isFeaturedQuery = false
        currentPage = 0
        recipes = []
        
        isLoading = true
        errorMessage = nil
        
        let api = EdamamRecipeComponent()
        api.searchRecipes(query: "", cuisineType: cuisineType) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let response):
                    // Limit recipes to the specified count
                    let allRecipes = response.hits.map { $0.recipe }
                    self?.recipes = Array(allRecipes.prefix(limit))
                    self?.nextPageUrl = response._links?.next?.href
                    self?.hasMoreRecipes = (self?.nextPageUrl != nil) || (allRecipes.count > limit)
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func fetchFeaturedRecipes(limit: Int = 20) {
        currentQuery = ""
        currentCuisineType = nil
        isFeaturedQuery = true
        currentPage = 0
        recipes = []
        usedFeaturedIngredients = []
        
        // Use more ingredients for greater variety
        let ingredientsToUse = getRandomIngredients(count: 5)
        usedFeaturedIngredients.append(contentsOf: ingredientsToUse)
        
        fetchRecipesForIngredients(ingredientsToUse, limit: limit, shouldShuffle: true)
    }
    
    private func getRandomIngredients(count: Int) -> [String] {
        var available = allIngredients.filter { !usedFeaturedIngredients.contains($0) }
        if available.count < count {
            available = allIngredients.shuffled() // Reset and shuffle if we've used all or nearly all
        }
        
        var selectedIngredients: [String] = []
        while selectedIngredients.count < count && !available.isEmpty {
            if let randomIndex = available.indices.randomElement() {
                selectedIngredients.append(available[randomIndex])
                available.remove(at: randomIndex)
            }
        }
        
        return selectedIngredients
    }
    
    private func fetchRecipesForIngredients(_ ingredients: [String], limit: Int = 20, shouldShuffle: Bool = false) {
        isLoading = true
        errorMessage = nil
        
        let group = DispatchGroup()
        var fetchedRecipes: [EdamamRecipeModel] = []
        var hasError = false
        
        for ingredient in ingredients {
            group.enter()
            
            let api = EdamamRecipeComponent()
            api.searchRecipes(query: ingredient) { [weak self] result in
                defer { group.leave() }
                
                switch result {
                case .success(let response):
                    // Take recipes per ingredient but respect overall limit
                    let recipesPerIngredient = min(limit / ingredients.count + 1, 5)
                    
                    // Create array of recipes with valid images
                    let validRecipes = response.hits
                        .map { $0.recipe }
                        .filter { !$0.image.isEmpty }
                        .prefix(recipesPerIngredient)
                    
                    fetchedRecipes.append(contentsOf: validRecipes)
                    
                    if let self = self {
                        self.nextPageUrl = response._links?.next?.href
                    }
                case .failure:
                    hasError = true
                }
            }
        }
        
        group.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            
            self.isLoading = false
            
            if fetchedRecipes.isEmpty && hasError {
                self.errorMessage = "Failed to load recipes. Please try again."
            } else {
                // Shuffle recipes if requested for better randomization
                let finalRecipes = shouldShuffle ? fetchedRecipes.shuffled() : fetchedRecipes
                
                // Limit to specified count
                self.recipes = Array(finalRecipes.prefix(limit))
                
                // Set if there are more recipes available
                self.hasMoreRecipes = fetchedRecipes.count > self.recipes.count
            }
        }
    }
    
    func loadMoreRecipes() {
        guard !isLoading, hasMoreRecipes else { return }
        
        isLoading = true
        currentPage += 1
        
        if isFeaturedQuery {
            // For featured recipes, load more random ingredients
            let newIngredients = getRandomIngredients(count: 3)
            usedFeaturedIngredients.append(contentsOf: newIngredients)
            
            let group = DispatchGroup()
            var newRecipes: [EdamamRecipeModel] = []
            
            for ingredient in newIngredients {
                group.enter()
                
                let api = EdamamRecipeComponent()
                api.searchRecipes(query: ingredient) { result in
                    defer { group.leave() }
                    
                    if case .success(let response) = result {
                        // Filter to only include recipes with valid images
                        let recipes = response.hits
                            .map { $0.recipe }
                            .filter { !$0.image.isEmpty }
                            .prefix(4)
                        
                        newRecipes.append(contentsOf: recipes)
                    }
                }
            }
            
            group.notify(queue: .main) { [weak self] in
                if newRecipes.isEmpty {
                    // Instead of adding placeholders, just mark loading as complete
                    self?.isLoading = false
                    self?.hasMoreRecipes = false
                    // Optionally, set an error message 
                    self?.errorMessage = "No recipes found. Try different filters."
                } else {
                    // Shuffle for better randomization
                    self?.recipes.append(contentsOf: newRecipes.shuffled())
                }
                self?.isLoading = false
            }
        } else if let nextUrl = nextPageUrl, !nextUrl.isEmpty {
            // For pagination with Edamam API
            let api = EdamamRecipeComponent()
            api.continueSearch(url: nextUrl) { [weak self] result in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    
                    switch result {
                    case .success(let response):
                        // Filter out recipes with empty image URLs
                        let newRecipes = response.hits
                            .map { $0.recipe }
                            .filter { !$0.image.isEmpty }
                        
                        if newRecipes.isEmpty {
                            // Instead of adding placeholders, just update state
                            self?.hasMoreRecipes = false
                            self?.errorMessage = "No more recipes found."
                        } else {
                            self?.recipes.append(contentsOf: newRecipes)
                        }
                        
                        self?.nextPageUrl = response._links?.next?.href
                        self?.hasMoreRecipes = (self?.nextPageUrl != nil && !(self?.nextPageUrl?.isEmpty ?? true))
                    case .failure(let error):
                        self?.errorMessage = error.localizedDescription
                        self?.hasMoreRecipes = false
                    }
                }
            }
        } else {
            // Fallback to manual pagination if nextUrl is not available
            let api = EdamamRecipeComponent()
            let queryToUse = !currentQuery.isEmpty ? currentQuery : (currentCuisineType ?? "recipes")
            
            api.searchRecipes(
                query: queryToUse,
                cuisineType: currentCuisineType,
                page: currentPage
            ) { [weak self] result in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    
                    switch result {
                    case .success(let response):
                        if response.hits.isEmpty {
                            // No more results
                            self?.hasMoreRecipes = false
                        } else {
                            // Filter out recipes with empty image URLs
                            let newRecipes = response.hits
                                .map { $0.recipe }
                                .filter { !$0.image.isEmpty }
                            
                            if newRecipes.isEmpty {
                                // Instead of adding placeholders, update state
                                self?.hasMoreRecipes = false
                                self?.errorMessage = "No recipes found with images."
                            } else {
                                self?.recipes.append(contentsOf: newRecipes)
                            }
                            
                            self?.nextPageUrl = response._links?.next?.href
                            self?.hasMoreRecipes = (self?.nextPageUrl != nil && !(self?.nextPageUrl?.isEmpty ?? true))
                                || response.hits.count >= 20 // If we got a full page of results, assume there's more
                        }
                    case .failure(let error):
                        self?.errorMessage = error.localizedDescription
                        self?.hasMoreRecipes = false
                    }
                }
            }
        }
    }
} 