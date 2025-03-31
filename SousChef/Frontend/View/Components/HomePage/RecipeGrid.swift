//
//  RecipeGrid.swift
//  SousChef
//
//  Created by Sutter Reynolds on 2/25/25.
//

import SwiftUI

struct RecipeGrid: View {
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
                            RecipeGridItem(recipe: recipes[2], width: 95, height: 75)
                            MoreTile(width: 95, height: 75)
                        }
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
