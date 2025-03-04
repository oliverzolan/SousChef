//
//  RecipeBoxPage.swift
//  SousChef
//
//  Created by Zachary Waiksnoris on 3/3/25.
//

import SwiftUI

struct RecipeBoxView: View {
    let recipe: RecipeModel

    var body: some View {
        VStack(alignment: .leading) {
            if let imageUrl = URL(string: recipe.image) {
                AsyncImage(url: imageUrl) { image in
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(height: 120)
                        .clipped()
                } placeholder: {
                    ProgressView()
                }
            }
            Text(recipe.label)
                .font(.headline)
                .foregroundColor(.black)
                .padding([.horizontal, .bottom])
        }
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 4)
    }
}
