//
//  SimpleRecipeGrid.swift
//  SousChef
//
//  Created by Oliver Zolan on 3/31/25.
//

import SwiftUI

struct SimpleRecipeGrid: View {
    var title: String
    var recipes: [EdamamRecipeModel]

    var body: some View {
        VStack(spacing: 5) {
            HStack {
                Text(title + " Recipes")
                    .font(.title3)
                    .fontWeight(.bold)
                Spacer()
            }
            .padding(.horizontal)

            if recipes.count >= 3 {
                HStack(spacing: 10) {
                    RecipeGridItem(recipe: recipes[0], width: 150, height: 160)

                    VStack(spacing: 10) {
                        RecipeGridItem(recipe: recipes[1], width: 200, height: 75)

                        HStack(spacing: 10) {
                            if recipes.count > 2 {
                                RecipeGridItem(recipe: recipes[2], width: 95, height: 75)
                            } else {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.1))
                                    .frame(width: 95, height: 75)
                                    .cornerRadius(15)
                            }
                            
                            if title == "Featured" {
                                MoreTile(width: 95, height: 75, title: title, searchQuery: title)
                            } else {
                                MoreTile(width: 95, height: 75, title: title, searchQuery: title, cuisineType: title.lowercased())
                            }
                        }
                        .frame(width: 200, height: 75)
                    }
                }
                .padding(.horizontal)
            } else if !recipes.isEmpty {
                HStack(spacing: 10) {
                    ForEach(recipes.indices, id: \.self) { index in
                        RecipeGridItem(recipe: recipes[index], width: 110, height: 140)
                    }
                    
                    if title == "Featured" {
                        MoreTile(width: 110, height: 140, title: title, searchQuery: title)
                    } else {
                        MoreTile(width: 110, height: 140, title: title, searchQuery: title, cuisineType: title.lowercased())
                    }
                }
                .padding(.horizontal)
            } else {
                ProgressView()
                    .padding()
            }
        }
        .padding(.bottom, 10)
    }
} 
