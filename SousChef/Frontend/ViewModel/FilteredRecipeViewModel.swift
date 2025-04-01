import Foundation
import SwiftUI

class FilteredRecipeViewModel: ObservableObject {
    @Published var recipes: [EdamamRecipeModel] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    @Published var hasMoreRecipes = true
    
    private var currentPage = 0
    private var nextPageUrl: String? = nil
    
    // Store current filters for pagination
    private var currentCuisineType: String? = nil
    private var currentMealType: String? = nil
    private var currentDietType: String? = nil
    private var currentHealthType: String? = nil
    private var currentMaxTime: Int? = nil
    
    func fetchFilteredRecipes(
        cuisineType: String? = nil,
        mealType: String? = nil,
        dietType: String? = nil,
        healthType: String? = nil,
        maxTime: Int? = nil
    ) {
        // Store filters for pagination
        currentCuisineType = cuisineType
        currentMealType = mealType
        currentDietType = dietType
        currentHealthType = healthType
        currentMaxTime = maxTime
        
        currentPage = 0
        recipes = []
        
        isLoading = true
        errorMessage = nil
        
        // Default query to be used if no specific filters are applied
        let defaultQuery = cuisineType ?? "recipes"
        
        let api = EdamamRecipeComponent()
        api.searchRecipes(
            query: defaultQuery,
            cuisineType: cuisineType,
            mealType: mealType,
            dietType: dietType,
            healthType: healthType,
            maxTime: maxTime
        ) { [weak self] result in
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
    
    func loadMoreRecipes() {
        guard !isLoading else { return }
        
        isLoading = true
        currentPage += 1
        
        if let nextUrl = nextPageUrl, !nextUrl.isEmpty {
            // Use pagination URL if available
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
            // Fallback to refetching with pagination parameters
            let defaultQuery = currentCuisineType ?? "recipes"
            
            let api = EdamamRecipeComponent()
            api.searchRecipes(
                query: defaultQuery,
                cuisineType: currentCuisineType,
                mealType: currentMealType,
                dietType: currentDietType,
                healthType: currentHealthType,
                maxTime: currentMaxTime,
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