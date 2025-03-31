//
//  RecipeGridItem.swift
//  SousChef
//
//  Created by Bennet Rau on 2/1/25.
//

import SwiftUI

struct RecipeGridItem: View {
    var recipe: EdamamRecipeModel
    var width: CGFloat
    var height: CGFloat

    var body: some View {
        NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
            ZStack(alignment: .bottomLeading) {
                AsyncImage(url: URL(string: recipe.image)) { image in
                    image.resizable().aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color.gray.opacity(0.3)
                }
                .frame(width: width, height: height)
                .clipped()
                .cornerRadius(15)

                VStack(alignment: .leading, spacing: 4) {
                    Text(recipe.label)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(2)

                    Text("→")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                }
                .padding(8)
            }
            .frame(width: width, height: height)
            .shadow(color: Color.black.opacity(0.35), radius: 5, x: 0, y: 5)
        }
    }
}
