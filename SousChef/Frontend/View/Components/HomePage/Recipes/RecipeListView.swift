import SwiftUI

struct RecipeListView: View {
    let title: String
    let searchQuery: String
    let cuisineType: String?
    
    // Direct recipe list (for From Pantry)
    let recipes: [EdamamRecipeModel]?
    
    @StateObject private var viewModel = RecipeListViewModel()
    @Environment(\.dismiss) private var dismiss
    
    // Constructor for search-based recipes (Featured, cuisines, etc.)
    init(title: String, searchQuery: String, cuisineType: String? = nil) {
        self.title = title
        self.searchQuery = searchQuery
        self.cuisineType = cuisineType
        self.recipes = nil
    }
    
    // Constructor for direct recipe list (From Pantry)
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
                // Direct recipe list mode (From Pantry)
                if directRecipes.isEmpty {
                    emptyState
                } else {
                    recipesGridView(recipes: directRecipes)
                }
            } else {
                // Search-based mode (Featured, cuisines, etc.)
                if viewModel.isLoading && viewModel.recipes.isEmpty {
                    loadingState
                } else if let errorMessage = viewModel.errorMessage {
                    errorState(message: errorMessage)
                } else if viewModel.recipes.isEmpty {
                    emptyState
                } else {
                    recipesGridView(recipes: viewModel.recipes)
                    
                    if viewModel.isLoading {
                        ProgressView()
                            .padding()
                    } else if viewModel.hasMoreRecipes {
                        loadMoreButton
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            // Only fetch if we're not using direct recipes
            if recipes == nil {
                if title.contains("Featured") {
                    viewModel.fetchFeaturedRecipes()
                } else if let cuisineType = cuisineType {
                    viewModel.fetchRecipesByCuisine(cuisineType: cuisineType)
                } else {
                    viewModel.fetchRecipes(query: searchQuery)
                }
            }
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
    
    private var loadMoreButton: some View {
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
    
    private func recipesGridView(recipes: [EdamamRecipeModel]) -> some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ForEach(recipes, id: \.url) { recipe in
                    NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                        recipeCard(recipe: recipe)
                    }
                }
            }
            .padding()
        }
    }
    
    private func recipeCard(recipe: EdamamRecipeModel) -> some View {
        VStack(alignment: .leading) {
            ZStack {
                CachedAsyncImage(
                    url: URL(string: recipe.image),
                    content: { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    },
                    placeholder: {
                        Color.gray.opacity(0.3)
                    }
                )
                .frame(height: 150)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .frame(height: 150)
            
            Text(recipe.label)
                .font(.system(size: 14, weight: .bold))
                .lineLimit(2)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 4)
            
            if let cuisineType = recipe.cuisineType?.first {
                Text(cuisineType.capitalized)
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
            
            Spacer(minLength: 0)
        }
        .frame(height: 210)
        .padding(8)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
} 