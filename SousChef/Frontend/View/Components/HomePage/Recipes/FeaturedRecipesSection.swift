//
//  FeaturedRecipesSection.swift
//  SousChef
//
//  Created by Oliver Zolan on 3/31/25.
//

import SwiftUI

struct FeaturedRecipesSection: View {
    @StateObject private var viewModel = FeaturedRecipesViewModel()
    @EnvironmentObject var homepageController: HomepageController
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Featured Recipes")
                    .font(.title3)
                    .fontWeight(.bold)
                
                Spacer()
                
                NavigationLink(destination: RecipeListView(title: "Featured Recipes", searchQuery: "popular", cuisineType: nil)) {
                    Text("More")
                        .font(.subheadline)
                        .foregroundColor(AppColors.secondary3)
                }
            }
            .padding(.horizontal)
            
            if viewModel.isLoading && viewModel.recipes.isEmpty {
                loadingState
            } else if let errorMessage = viewModel.errorMessage {
                errorState(message: errorMessage)
            } else if viewModel.recipes.isEmpty {
                emptyState
            } else {
                recipesScrollView
            }
        }
        .padding(.vertical, 8)
        .onAppear {
            viewModel.fetchFeaturedRecipes()
        }
    }
    
    private var loadingState: some View {
        HStack {
            Spacer()
            ProgressView()
                .padding()
            Spacer()
        }
        .frame(height: 200)
    }
    
    private var emptyState: some View {
        HStack {
            Spacer()
            Text("No featured recipes available")
                .foregroundColor(.gray)
            Spacer()
        }
        .frame(height: 200)
    }
    
    private func errorState(message: String) -> some View {
        HStack {
            Spacer()
            VStack {
                Image(systemName: "exclamationmark.triangle")
                    .font(.title)
                    .foregroundColor(.red)
                    .padding(.bottom, 4)
                
                Text("Failed to load recipes")
                    .foregroundColor(.red)
            }
            Spacer()
        }
        .frame(height: 200)
    }
    
    private var recipesScrollView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(viewModel.recipes.prefix(10), id: \.url) { recipe in
                    NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                        featuredRecipeCard(recipe: recipe)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    private func featuredRecipeCard(recipe: EdamamRecipeModel) -> some View {
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
                .frame(width: 240, height: 160)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .frame(width: 240, height: 160)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(recipe.label)
                    .font(.system(size: 16, weight: .bold))
                    .lineLimit(1)
                    .foregroundColor(.black)
                
                if let cuisineType = recipe.cuisineType?.first {
                    Text(cuisineType.capitalized)
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
                
                HStack {
                    Image(systemName: "clock")
                        .font(.system(size: 12))
                    
                    Text("30 min")
                        .font(.system(size: 12))
                    
                    Spacer()
                    
                    Image(systemName: "bookmark")
                        .foregroundColor(.gray)
                        .font(.system(size: 14))
                        .onTapGesture {
                            // Bookmark functionality to be implemented
                        }
                }
                .foregroundColor(.gray)
            }
            .padding(.vertical, 8)
            .frame(width: 240)
        }
        .frame(width: 240)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

class FeaturedRecipesViewModel: ObservableObject {
    @Published var recipes: [EdamamRecipeModel] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    
    func fetchFeaturedRecipes() {
        guard recipes.isEmpty else { return }
        
        isLoading = true
        errorMessage = nil
        
        let api = EdamamRecipeComponent()
        api.searchRecipes(query: "popular", page: 0) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                
                switch result {
                case .success(let response):
                    self.recipes = response.hits.map { $0.recipe }
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
} 
