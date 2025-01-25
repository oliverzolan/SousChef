//
//  PantryPage.swift
//  SousChef
//
//  Created by Garry Gomes on 12/31/24.
//

import SwiftUI

struct PantryPage: View {
    @State private var searchText: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Title
            Text("Pantry")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.horizontal)

            // Search Bar
            SearchComponent(searchText: $searchText)

            // Scan Features
            ScanFeaturesComponent()

            // Categories with Dropdown
            ScrollView {
                VStack(spacing: 8) {
                    IngredientCategoryView(category: "Vegetables", items: ["Carrot", "Broccoli", "Lettuce"])
                    IngredientCategoryView(category: "Meats", items: ["Chicken", "Beef"])
                    IngredientCategoryView(category: "Poultry", items: ["Eggs"])
                    IngredientCategoryView(category: "Fruits", items: ["Apple", "Banana"])
                    IngredientCategoryView(category: "Grains", items: ["Rice", "Pasta"])
                    IngredientCategoryView(category: "Drinks", items: ["Milk", "Wine"])
                }
                .padding(.horizontal)
            }
        }
        .padding(.top)
    }
}

struct PantryPage_Previews: PreviewProvider {
    static var previews: some View {
        PantryPage()
    }
}
