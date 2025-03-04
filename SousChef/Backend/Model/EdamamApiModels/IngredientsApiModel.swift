//
//  IngredientsApiModel.swift
//  SousChef
//
//  Created by Oliver Zolan on 3/3/25.
//
import Foundation

struct IngredientResponse: Decodable {
    let hints: [Hint]
}

struct Hint: Decodable {
    let food: IngredientModel
}

struct IngredientModel: Decodable, Identifiable, Hashable {
    var id: String { foodId }
    let foodId: String
    let label: String
    let category: String?
    let categoryLabel: String?
    let image: String?
    let nutrients: IngredientNutrients?
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(foodId)
    }

    static func == (lhs: IngredientModel, rhs: IngredientModel) -> Bool {
        return lhs.foodId == rhs.foodId
    }
}

struct IngredientNutrients: Decodable {
    let energy: Double?
    let protein: Double?
    let fat: Double?
    let carbs: Double?
    let fiber: Double?

    private enum CodingKeys: String, CodingKey {
        case energy = "ENERC_KCAL"
        case protein = "PROCNT"
        case fat = "FAT"
        case carbs = "CHOCDF"
        case fiber = "FIBTG"         
    }
}

