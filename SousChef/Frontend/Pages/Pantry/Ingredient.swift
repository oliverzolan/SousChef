//
//  Ingredients.swift
//  SousChef
//
//  Created by Zachary Waiksnoris on 12/10/24.
//


struct Ingredient: Codable, Identifiable {
    let id: Int
    let name: String
    let category: String
    let description: String

    enum CodingKeys: String, CodingKey {
        case id = "ingredient_id"
        case name
        case category
        case description
    }
}
