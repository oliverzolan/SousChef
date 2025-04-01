import SwiftUI

struct FilteredRecipeListView: View {
    let filters: FiltersViewModel
    
    @StateObject private var viewModel = FilteredRecipeViewModel()
    @Environment(\.dismiss) private var dismiss
    
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
            
            // Active filters display
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    if let cuisine = filters.cuisineType {
                        FilterTag(text: cuisine.capitalized, onRemove: {})
                    }
                    
                    if let mealType = filters.mealType {
                        FilterTag(text: mealType.capitalized, onRemove: {})
                    }
                    
                    if let dietType = filters.dietType {
                        FilterTag(text: dietType.capitalized, onRemove: {})
                    }
                    
                    if let healthType = filters.healthType {
                        FilterTag(text: healthType.capitalized, onRemove: {})
                    }
                    
                    if let maxTime = filters.maxTime {
                        FilterTag(text: "≤\(maxTime) min", onRemove: {})
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical, 8)
            .background(Color.gray.opacity(0.1))
            
            if viewModel.isLoading && viewModel.recipes.isEmpty {
                Spacer()
                ProgressView()
                    .scaleEffect(1.5)
                Spacer()
            } else if let errorMessage = viewModel.errorMessage {
                Spacer()
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
                Spacer()
            } else if viewModel.recipes.isEmpty {
                Spacer()
                Text("No recipes found")
                    .foregroundColor(.gray)
                Spacer()
            } else {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        ForEach(viewModel.recipes, id: \.url) { recipe in
                            NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                                recipeCard(recipe: recipe)
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
        .navigationBarHidden(true)
        .onAppear {
            viewModel.fetchFilteredRecipes(
                cuisineType: filters.cuisineType,
                mealType: filters.mealType,
                dietType: filters.dietType,
                healthType: filters.healthType,
                maxTime: filters.maxTime
            )
        }
    }
    
    var title: String {
        if let cuisineType = filters.cuisineType {
            return "\(cuisineType.capitalized) Recipes"
        } else if let mealType = filters.mealType {
            return "\(mealType.capitalized) Recipes"
        } else {
            return "Filtered Recipes"
        }
    }
    
    private func recipeCard(recipe: EdamamRecipeModel) -> some View {
        VStack(alignment: .leading) {
            AsyncImage(url: URL(string: recipe.image)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Color.gray.opacity(0.3)
            }
            .frame(height: 150)
            .clipped()
            .cornerRadius(12)
            
            Text(recipe.label)
                .font(.system(size: 14, weight: .bold))
                .lineLimit(2)
                .padding(.top, 4)
            
            if let cuisineType = recipe.cuisineType?.first {
                Text(cuisineType.capitalized)
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
        .frame(height: 210)
        .padding(8)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
} 