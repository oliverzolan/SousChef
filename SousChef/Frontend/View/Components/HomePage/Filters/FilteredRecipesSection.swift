//
//  FilteredRecipesSection.swift
//  SousChef
//
//  Created by Oliver Zolan on 3/31/25.
//

import SwiftUI

struct FilteredRecipesSection: View {
    @ObservedObject var filterController: FilterController
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if filterController.isLoading && filterController.filteredRecipes.isEmpty {
                loadingState
            } else if let errorMessage = filterController.errorMessage {
                errorState(message: errorMessage)
            } else if filterController.filteredRecipes.isEmpty {
                emptyState
            } else {
                recipesGridView
                
                if filterController.isLoading {
                    ProgressView()
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .center)
                } else if filterController.hasMoreRecipes {
                    loadMoreButton
                }
            }
        }
    }
    
    private var loadingState: some View {
        VStack {
            Spacer()
            ProgressView()
                .scaleEffect(1.5)
                .padding()
            Text("Loading recipes...")
                .foregroundColor(.gray)
                .padding(.top, 8)
            Spacer()
        }
        .frame(maxWidth: .infinity, minHeight: 200)
    }
    
    private var emptyState: some View {
        VStack {
            Spacer()
            Image(systemName: "magnifyingglass")
                .font(.system(size: 40))
                .foregroundColor(.gray.opacity(0.5))
                .padding()
            Text("No recipes found")
                .font(.headline)
                .foregroundColor(.gray)
            Text("Try adjusting your filters")
                .font(.subheadline)
                .foregroundColor(.gray.opacity(0.7))
                .padding(.top, 4)
            Spacer()
        }
        .frame(maxWidth: .infinity, minHeight: 200)
    }
    
    private func errorState(message: String) -> some View {
        VStack {
            Spacer()
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 40))
                .foregroundColor(.red.opacity(0.7))
                .padding()
            Text("Error loading recipes")
                .font(.headline)
                .foregroundColor(.red)
            Text(message)
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.top, 4)
                .padding(.horizontal)
            Spacer()
        }
        .frame(maxWidth: .infinity, minHeight: 200)
    }
    
    private var recipesGridView: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            ForEach(filterController.filteredRecipes, id: \.url) { recipe in
                RecipeGridItem(
                    recipe: recipe,
                    width: (UIScreen.main.bounds.width - 48) / 2,
                    height: 180
                )
            }
        }
        .padding(.horizontal)
    }
    
    private var loadMoreButton: some View {
        Button(action: {
            filterController.loadMoreFilteredRecipes()
        }) {
            Text("Load More")
                .foregroundColor(.white)
                .padding(.vertical, 12)
                .padding(.horizontal, 24)
                .background(AppColors.secondary3)
                .cornerRadius(8)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.vertical)
    }
} 
