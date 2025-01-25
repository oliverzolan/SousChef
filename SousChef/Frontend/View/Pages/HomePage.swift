//
//  HomePage.swift
//  SousChef
//
//  Created by Garry Gomes on 12/31/24.
//

import SwiftUI

struct RecipePage: View {
    @State private var searchText: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Location Component
            LocationComponent(location: "2950 Cityview Terrace v")

            // Search Component
            SearchComponent(searchText: $searchText)

            // Recipe Type Scroll View
            RecipeTypeScrollView(recipeTypes: ["American", "Chinese", "Indian", "Korean", "Italian", "Mexican"])
        }
        .padding(.top)
    }
}

struct RecipePage_Previews: PreviewProvider {
    static var previews: some View {
        RecipePage()
    }
}

