//
//  HomepageController.swift
//  SousChef
//
//  Created by Oliver Zolan on 3/30/25.
//

import Foundation
import SwiftUI

class HomepageController: ObservableObject {
    @Published var featuredRecipes: [EdamamRecipeModel] = []

    private let allIngredients = [
        "chicken", "pasta", "rice", "onion", "garlic", "tomato", "cheese",
        "eggs", "bell pepper", "beef", "tofu", "broccoli", "mushroom",
        "potato", "coconut milk"
    ]

    func fetchFeaturedRecipes() {
        var selectedIngredients = Set<String>()
        while selectedIngredients.count < 3 {
            if let random = allIngredients.randomElement() {
                selectedIngredients.insert(random)
            }
        }

        let api = EdamamRecipeComponent()
        let group = DispatchGroup()
        var fetched: [EdamamRecipeModel] = []

        for ingredient in selectedIngredients {
            group.enter()
            api.searchRecipes(query: ingredient) { result in
                if case .success(let response) = result,
                   let recipe = response.hits.first?.recipe {
                    fetched.append(recipe)
                }
                group.leave()
            }
        }

        group.notify(queue: .main) {
            self.featuredRecipes = fetched
        }
    }
}
