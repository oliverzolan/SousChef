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
    
    func fetchRecipes(query: String) {
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
                    self?.recipes = response.hits.map { $0.recipe }
                    self?.nextPageUrl = response._links?.next?.href
                    self?.hasMoreRecipes = self?.nextPageUrl != nil
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func fetchRecipesByCuisine(cuisineType: String) {
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
                    self?.recipes = response.hits.map { $0.recipe }
                    self?.nextPageUrl = response._links?.next?.href
                    self?.hasMoreRecipes = self?.nextPageUrl != nil
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func fetchFeaturedRecipes() {
        currentQuery = ""
        currentCuisineType = nil
        isFeaturedQuery = true
        currentPage = 0
        recipes = []
        usedFeaturedIngredients = []
        
        let ingredientsToUse = getRandomIngredients(count: 3)
        usedFeaturedIngredients.append(contentsOf: ingredientsToUse)
        
        fetchRecipesForIngredients(ingredientsToUse)
    }
    
    private func getRandomIngredients(count: Int) -> [String] {
        var available = allIngredients.filter { !usedFeaturedIngredients.contains($0) }
        if available.count < count {
            available = allIngredients // Reset if we've used all or nearly all
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
    
    private func fetchRecipesForIngredients(_ ingredients: [String]) {
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
                    // Take 3-4 recipes per ingredient for variety
                    let recipes = response.hits.prefix(4).map { $0.recipe }
                    fetchedRecipes.append(contentsOf: recipes)
                    
                    if let self = self {
                        self.nextPageUrl = response._links?.next?.href
                    }
                case .failure:
                    hasError = true
                }
            }
        }
        
        group.notify(queue: .main) { [weak self] in
            self?.isLoading = false
            
            if hasError && fetchedRecipes.isEmpty {
                self?.errorMessage = "Failed to load featured recipes."
            } else {
                self?.recipes = fetchedRecipes
                self?.hasMoreRecipes = true // Always allow loading more featured recipes
            }
        }
    }
    
    func loadMoreRecipes() {
        guard !isLoading else { return }
        
        isLoading = true
        currentPage += 1
        
        if isFeaturedQuery {
            // For featured recipes, load more random ingredients
            let newIngredients = getRandomIngredients(count: 2)
            usedFeaturedIngredients.append(contentsOf: newIngredients)
            
            let group = DispatchGroup()
            var newRecipes: [EdamamRecipeModel] = []
            
            for ingredient in newIngredients {
                group.enter()
                
                let api = EdamamRecipeComponent()
                api.searchRecipes(query: ingredient) { result in
                    defer { group.leave() }
                    
                    if case .success(let response) = result {
                        let recipes = response.hits.prefix(4).map { $0.recipe }
                        newRecipes.append(contentsOf: recipes)
                    }
                }
            }
            
            group.notify(queue: .main) { [weak self] in
                self?.recipes.append(contentsOf: newRecipes)
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
                        let newRecipes = response.hits.map { $0.recipe }
                        self?.recipes.append(contentsOf: newRecipes)
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
                            let newRecipes = response.hits.map { $0.recipe }
                            self?.recipes.append(contentsOf: newRecipes)
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