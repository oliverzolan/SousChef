//
//  MoreTile.swift
//  SousChef
//
//  Created by Oliver Zolan on 3/30/25.
//

import SwiftUI

struct MoreTile: View {
    var width: CGFloat
    var height: CGFloat
    var title: String
    var searchQuery: String
    var cuisineType: String?
    
    @EnvironmentObject var homepageController: HomepageController
    
    init(width: CGFloat, height: CGFloat, title: String, searchQuery: String, cuisineType: String? = nil) {
        self.width = width
        self.height = height
        self.title = title
        self.searchQuery = searchQuery
        self.cuisineType = cuisineType
    }
    
    var body: some View {
        if title == "From Pantry" {
            // Use different navigation for pantry recipes
            NavigationLink(destination: RecipeListView(title: "\(title) Recipes", recipes: homepageController.allPantryRecipes)) {
                moreImage
            }
        } else {
            // Use standard navigation for other recipe types
            NavigationLink(destination: RecipeListView(title: "\(title) Recipes", searchQuery: searchQuery, cuisineType: cuisineType)) {
                moreImage
            }
        }
    }
    
    private var moreImage: some View {
        Image("redMore")
            .resizable()
            .scaledToFill()
            .frame(width: width, height: height)
            .clipShape(RoundedRectangle(cornerRadius: 15))
            .shadow(color: Color.black.opacity(0.35), radius: 5, x: 0, y: 5)
    }
}
