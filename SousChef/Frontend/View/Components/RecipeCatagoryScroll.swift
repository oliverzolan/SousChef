//
//  RecipeCatagoryScroll.swift
//  SousChef
//
//  Created by Sutter Reynolds on 12/31/24.
//

import SwiftUI

struct RecipeTypeScrollView: View {
    let recipeTypes: [String]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(recipeTypes, id: \.self) { type in
                    VStack {
                        // Icon Placeholder (you can replace with appropriate icons)
                        Image(systemName: "fork.knife")
                            .resizable()
                            .frame(width: 40, height: 40)

                        Text(type)
                            .font(.footnote)
                            .fontWeight(.medium)
                            .multilineTextAlignment(.center)
                    }
                }
            }
            .padding()
        }
    }
}
