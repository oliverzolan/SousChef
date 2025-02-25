//
//  RecipeGrid.swift
//  SousChef
//
//  Created by Sutter Reynolds on 2/25/25.
//

import SwiftUI

struct RecipeGrid: View {
    var title: String
    
    var body: some View {
        VStack(spacing: 5) { // Reduce spacing between HStacks
            HStack {
                Text(title + " Recipes")
                    .font(.title3)
                    .fontWeight(.bold)
                Spacer()
            }
            .padding(.horizontal)
            
            HStack {
                RecipeGridItem(title: "Button 1", color: .gray, width: 150, height: 160)
                
                VStack(spacing: 10) {
                    RecipeGridItem(title: "Button 2", color: .gray, width: 200, height: 75)
                    
                    HStack(spacing: 10) {
                        RecipeGridItem(title: "Button 3", color: .gray, width: 95, height: 75)
                        RecipeGridItem(title: "Button 4", color: .gray, width: 95, height: 75)
                    }
                }
            }
            
        }
    .padding(.bottom, 10)
    }
}

