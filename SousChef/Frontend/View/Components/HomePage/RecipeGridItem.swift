//
//  RecipeGridItem.swift
//  SousChef
//
//  Created by Bennet Rau on 2/1/25.
//

import Foundation
import SwiftUI

struct RecipeGridItem: View {
    var title: String
    var color: Color
    var width: CGFloat
    var height: CGFloat

    var body: some View {
        Button(action: {
            print("Tapped \(title)")
        }) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
                .frame(width: width, height: height)
                .background(color)
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .shadow(color: Color.black.opacity(0.35), radius: 5, x: 0, y: 5)
        }
    }
}


