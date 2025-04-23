import SwiftUI

struct RecipeListView: View {
    let title: String
    let searchQuery: String
    let cuisineType: String?
    
    // Direct recipe list (for From Pantry)
    let recipes: [EdamamRecipeModel]?
    
    @StateObject private var viewModel = RecipeListViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var displayedDirectRecipes: [EdamamRecipeModel] = []
    @State private var hasMoreDirectRecipes: Bool = false
    @State private var currentPage: Int = 0
    
    // Constructor for search-based recipes
    init(title: String, searchQuery: String, cuisineType: String? = nil) {
        self.title = title
        self.searchQuery = searchQuery
        self.cuisineType = cuisineType
        self.recipes = nil
    }
    
    // Constructor for direct recipe list from Pantry
    init(title: String, recipes: [EdamamRecipeModel]) {
        self.title = title
        self.searchQuery = ""
        self.cuisineType = nil
        self.recipes = recipes
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "arrow.left")
                        .font(.title3)
                        .foregroundColor(.black)
                }
                
                Text(title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.leading, 8)
                
                Spacer()
            }
            .padding()
            .background(Color.white)
            
            if let directRecipes = recipes {
                // Direct recipe list mode
                if directRecipes.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            ForEach(displayedDirectRecipes, id: \.url) { recipe in
                                NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                                    updatedRecipeCard(recipe: recipe)
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        if hasMoreDirectRecipes {
                            Button(action: {
                                loadMoreDirectRecipes(from: directRecipes)
                            }) {
                                Text("Load More")
                                    .foregroundColor(.white)
                                    .padding(.vertical, 12)
                                    .padding(.horizontal, 24)
                                    .background(AppColors.secondary3)
                                    .cornerRadius(8)
                            }
                            .padding()
                        }
                    }
                }
            } else {
                // Search-based mode
                if viewModel.isLoading && viewModel.recipes.isEmpty {
                    loadingState
                } else if let errorMessage = viewModel.errorMessage {
                    errorState(message: errorMessage)
                } else if viewModel.recipes.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            ForEach(viewModel.recipes, id: \.url) { recipe in
                                NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                                    updatedRecipeCard(recipe: recipe)
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        if viewModel.isLoading {
                            ProgressView()
                                .padding()
                        } else if viewModel.hasMoreRecipes {
                            Button(action: {
                                viewModel.loadMoreRecipes()
                            }) {
                                Text("Load More")
                                    .foregroundColor(.white)
                                    .padding(.vertical, 12)
                                    .padding(.horizontal, 24)
                                    .background(AppColors.secondary3)
                                    .cornerRadius(8)
                            }
                            .padding()
                        }
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            // Only fetch if we're not using direct recipes
            if let directRecipes = recipes {
                // Initialize displayed recipes with first 20
                loadMoreDirectRecipes(from: directRecipes, isInitial: true)
            } else {
                if title.contains("Featured") {
                    viewModel.fetchFeaturedRecipes(limit: 20)
                } else if let cuisineType = cuisineType {
                    viewModel.fetchRecipesByCuisine(cuisineType: cuisineType, limit: 20)
                } else {
                    viewModel.fetchRecipes(query: searchQuery, limit: 20)
                }
            }
        }
    }
    
    private func loadMoreDirectRecipes(from allRecipes: [EdamamRecipeModel], isInitial: Bool = false) {
        if isInitial {
            currentPage = 0
            displayedDirectRecipes = []
        }
        
        let startIndex = currentPage * 20
        let endIndex = min(startIndex + 20, allRecipes.count)
        
        if startIndex < endIndex {
            let newBatch = allRecipes[startIndex..<endIndex]
            displayedDirectRecipes.append(contentsOf: newBatch)
            currentPage += 1
            hasMoreDirectRecipes = endIndex < allRecipes.count
        } else {
            hasMoreDirectRecipes = false
        }
    }
    
    // MARK: - View Components
    
    private var loadingState: some View {
        VStack {
            Spacer()
            ProgressView()
                .scaleEffect(1.5)
            Spacer()
        }
    }
    
    private var emptyState: some View {
        VStack {
            Spacer()
            Text("No recipes found")
                .foregroundColor(.gray)
            Spacer()
        }
    }
    
    private func errorState(message: String) -> some View {
        VStack {
            Spacer()
            Text(message)
                .foregroundColor(.red)
                .padding()
            Spacer()
        }
    }
    
    private func updatedRecipeCard(recipe: EdamamRecipeModel) -> some View {
        ZStack(alignment: .bottomLeading) {
            // Recipe image with clipping to prevent overflow
            CachedAsyncImage(
                url: URL(string: recipe.image),
                content: { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                },
                placeholder: {
                    // More visible placeholder
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .overlay(
                            Image(systemName: "photo")
                                .font(.system(size: 30))
                                .foregroundColor(.gray)
                        )
                }
            )
            .frame(height: 180)
            .clipped() // Ensure image doesn't overflow its container
            .clipShape(RoundedRectangle(cornerRadius: 15))
            
            // Dark overlay for better text visibility
            Rectangle()
                .fill(Color.black.opacity(0.25))
                .cornerRadius(15)
                .frame(height: 180)
            
            // Recipe name and arrow
            VStack(alignment: .leading, spacing: 4) {
                Text(recipe.label)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(2)
                
                Text("→")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
            }
            .padding(12)
        }
        .frame(height: 180)
        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 5)
    }
} 
