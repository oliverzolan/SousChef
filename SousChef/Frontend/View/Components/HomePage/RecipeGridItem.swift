//
//  RecipeGridItem.swift
//  SousChef
//
//  Created by Bennet Rau on 2/1/25.
//

import Foundation
import SwiftUI

struct RecipeGridItem: View {
    var recipeName: String
    var imageName: String
    var size: CGSize // Allows different sizes for items
    var isHighlighted: Bool = false

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Image(imageName)
                .resizable()
                .scaledToFill()
                .frame(width: size.width, height: size.height)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isHighlighted ? Color.blue : Color.clear, lineWidth: 3) // Highlight effect
                )

            // Text overlay
            HStack {
                Text(recipeName)
                    .font(.custom("Inter-Bold", size: 14))
                    .foregroundColor(.white)
                Spacer()
                Image(systemName: "arrow.right")
                    .foregroundColor(.white)
            }
            .padding(8)
            .background(Color.black.opacity(0.5))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(4)
        }
        .frame(width: size.width, height: size.height)
    }
}


