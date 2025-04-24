//
//  PantryItem.swift
//  SousChef
//
//  Created by Sutter Reynolds on 3/4/25.
//

import Foundation

struct AWSIngredientModel: Codable {
    let edamamFoodId: String
    let foodCategory: String
    let name: String
    //let measure: String
    let quantityType: String //weight type
    let experiationDuration: Int
    let imageURL: String
    
    // Add coding keys to handle potential different naming in API responses
    enum CodingKeys: String, CodingKey {
        case edamamFoodId = "Edamam_Food_ID"
        case foodCategory = "Category"
        case name = "Name"
        case quantityType = "Quantity_Type"
        case experiationDuration = "Expiration_Duration"
        case imageURL = "Image_URL"
    }
    
    // Custom initializer to handle missing fields
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Required fields with fallbacks
        edamamFoodId = try container.decodeIfPresent(String.self, forKey: .edamamFoodId) ?? UUID().uuidString
        name = try container.decodeIfPresent(String.self, forKey: .name) ?? "Unknown Item"
        
        // Optional fields with defaults
        foodCategory = try container.decodeIfPresent(String.self, forKey: .foodCategory) ?? "Uncategorized"
        quantityType = try container.decodeIfPresent(String.self, forKey: .quantityType) ?? "Serving"
        
        // Handle null expiration duration
        if let expirationValue = try? container.decodeIfPresent(Int.self, forKey: .experiationDuration) {
            experiationDuration = expirationValue 
        } else {
            experiationDuration = 7 // Default to 7 days if null
        }
        
        imageURL = try container.decodeIfPresent(String.self, forKey: .imageURL) ?? ""
    }
    
    // Regular initializer for when we create ingredients in our app
    init(edamamFoodId: String, foodCategory: String, name: String, quantityType: String, experiationDuration: Int, imageURL: String) {
        self.edamamFoodId = edamamFoodId
        self.foodCategory = foodCategory
        self.name = name
        self.quantityType = quantityType
        self.experiationDuration = experiationDuration
        self.imageURL = imageURL
    }
}
