//
//  FoodScannerModel.swift
//  SousChef
//
//  Created by Oliver Zolan on 3/8/25.
//

import Foundation

struct FoodScannerResponse: Codable {
    let food_response: [FoodScannerFood]
}

struct FoodScannerFood: Codable {
    let food_id: Int
    let food_entry_name: String
    let eaten: FoodEaten?
    let suggested_serving: SuggestedServing?
}

struct FoodEaten: Codable {
    let units: Double?
    let metric_description: String?
    let total_metric_amount: Double?
    let per_unit_metric_amount: Double?
    let total_nutritional_content: FoodNutrients?
}

struct SuggestedServing: Codable {
    let serving_id: Int?
    let serving_description: String?
    let metric_serving_description: String?
    let metric_measure_amount: Double?
    let number_of_units: String?
}

struct FoodNutrients: Codable {
    let calories: String?
    let carbohydrate: String?
    let protein: String?
    let fat: String?
    let saturated_fat: String?
    let polyunsaturated_fat: String?
    let monounsaturated_fat: String?
    let cholesterol: String?
    let sodium: String?
    let potassium: String?
    let fiber: String?
    let sugar: String?
    let vitamin_a: String?
    let vitamin_c: String?
    let calcium: String?
    let iron: String?
}
