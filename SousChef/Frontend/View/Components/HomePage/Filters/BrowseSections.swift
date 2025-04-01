//
//  BrowseSections.swift
//  SousChef
//
//  Created by Oliver Zolan on 3/31/25.
//

import SwiftUI

struct CuisineSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Browse by Cuisine")
                .font(.title3)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(["Italian", "Mexican", "Indian", "Chinese", "Japanese", "Mediterranean", "French", "Thai"], id: \.self) { cuisine in
                        cuisineCard(cuisine)
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical, 8)
    }
    
    private func cuisineCard(_ cuisine: String) -> some View {
        NavigationLink(destination: RecipeListView(title: "\(cuisine) Cuisine", searchQuery: cuisine, cuisineType: cuisine)) {
            VStack {
                Image(cuisine.lowercased())
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
                    .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                
                Text(cuisine)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.black)
                    .padding(.top, 4)
            }
            .frame(width: 100)
        }
    }
}

struct MealTypeSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Browse by Meal")
                .font(.title3)
                .fontWeight(.bold)
                .padding(.horizontal)
                
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ForEach(["Breakfast", "Lunch", "Dinner", "Dessert"], id: \.self) { mealType in
                    NavigationLink(destination: RecipeListView(title: mealType, searchQuery: mealType)) {
                        ZStack(alignment: .bottomLeading) {
                            Image(mealType.lowercased())
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 140)
                                .clipShape(RoundedRectangle(cornerRadius: 15))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(LinearGradient(
                                            gradient: Gradient(colors: [.black.opacity(0.6), .clear]),
                                            startPoint: .bottom,
                                            endPoint: .top
                                        ))
                                )
                            
                            Text(mealType)
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(12)
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
    }
} 
