import SwiftUI
import Combine

class FilterController: ObservableObject {
    @Published var filters = FilterModel()
    @Published var filteredRecipes: [EdamamRecipeModel] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    @Published var hasMoreRecipes = false
    
    private var currentPage = 0
    private var nextPageUrl: String? = nil
    
    // Apply filter and fetch recipes
    func applyFilters() {
        guard !filters.isEmpty else {
            filteredRecipes = []
            return
        }
        
        fetchFilteredRecipes()
    }
    
    // Reset all filters
    func resetFilters() {
        filters.reset()
        filteredRecipes = []
        errorMessage = nil
    }
    
    // Main function to fetch filtered recipes
    func fetchFilteredRecipes() {
        isLoading = true
        errorMessage = nil
        filteredRecipes = []
        currentPage = 0
        
        // Default query that is used if there are no filters
        let defaultQuery = filters.cuisineType?.lowercased() ?? "recipes"
        
        let api = EdamamRecipeComponent()
        api.searchRecipes(
            query: defaultQuery,
            cuisineType: filters.cuisineType?.lowercased(),
            mealType: filters.mealType?.lowercased(),
            dietType: filters.dietType?.lowercased(),
            healthType: filters.healthType?.lowercased(),
            maxTime: filters.maxTime
        ) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                
                switch result {
                case .success(let response):
                    self.filteredRecipes = response.hits.map { $0.recipe }
                    self.nextPageUrl = response._links?.next?.href
                    self.hasMoreRecipes = self.nextPageUrl != nil && 
                                       !(self.nextPageUrl?.isEmpty ?? true)
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    // Load more recipes (pagination)
    func loadMoreFilteredRecipes() {
        guard !isLoading, hasMoreRecipes else { return }
        
        isLoading = true
        currentPage += 1
        
        if let nextUrl = nextPageUrl, !nextUrl.isEmpty {
            // Use pagination URL if available
            let api = EdamamRecipeComponent()
            api.continueSearch(url: nextUrl) { [weak self] result in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    self.isLoading = false
                    
                    switch result {
                    case .success(let response):
                        let newRecipes = response.hits.map { $0.recipe }
                        self.filteredRecipes.append(contentsOf: newRecipes)
                        self.nextPageUrl = response._links?.next?.href
                        self.hasMoreRecipes = self.nextPageUrl != nil && 
                                           !(self.nextPageUrl?.isEmpty ?? true)
                    case .failure(let error):
                        self.errorMessage = error.localizedDescription
                        self.hasMoreRecipes = false
                    }
                }
            }
        } else {
            // Fallback to manual pagination
            let defaultQuery = filters.cuisineType?.lowercased() ?? "recipes"
            
            let api = EdamamRecipeComponent()
            api.searchRecipes(
                query: defaultQuery,
                cuisineType: filters.cuisineType?.lowercased(),
                mealType: filters.mealType?.lowercased(),
                dietType: filters.dietType?.lowercased(),
                healthType: filters.healthType?.lowercased(),
                maxTime: filters.maxTime,
                page: currentPage
            ) { [weak self] result in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    self.isLoading = false
                    
                    switch result {
                    case .success(let response):
                        if response.hits.isEmpty {
                            // No more results
                            self.hasMoreRecipes = false
                        } else {
                            let newRecipes = response.hits.map { $0.recipe }
                            self.filteredRecipes.append(contentsOf: newRecipes)
                            self.nextPageUrl = response._links?.next?.href
                            self.hasMoreRecipes = (self.nextPageUrl != nil && 
                                                 !(self.nextPageUrl?.isEmpty ?? true)) ||
                                                 response.hits.count >= 20
                        }
                    case .failure(let error):
                        self.errorMessage = error.localizedDescription
                        self.hasMoreRecipes = false
                    }
                }
            }
        }
    }
} 
