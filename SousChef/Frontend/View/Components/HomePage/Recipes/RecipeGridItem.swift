//
//  RecipeGridItem.swift
//  SousChef
//
//  Created by Bennet Rau on 2/1/25.
//

import SwiftUI

// Extend EdamamRecipeModel to conform to Identifiable
extension EdamamRecipeModel: Identifiable {
    public var id: String { url }
}

struct RecipeGridItem: View {
    var recipe: EdamamRecipeModel
    var width: CGFloat
    var height: CGFloat

    var body: some View {
        NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
            ZStack(alignment: .bottomLeading) {
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
                    .frame(width: width, height: height)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                }
                .frame(width: width, height: height)

                Rectangle()
                    .fill(Color.black.opacity(0.35))
                    .cornerRadius(15)
                    .frame(width: width, height: height)

                VStack(alignment: .leading, spacing: 4) {
                    Text(recipe.label)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(2)
                        .frame(maxWidth: width - 16, alignment: .leading)

                    Text("→")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                }
                .padding(8)
                .frame(width: width, alignment: .leading)
            }
            .frame(width: width, height: height)
            .shadow(color: Color.black.opacity(0.35), radius: 5, x: 0, y: 5)
        }
    }
}
