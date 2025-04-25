import Foundation
import SwiftUI

// Represents an item scanned via barcode
struct ScannedItem: Identifiable {
    var id = UUID()
    var ingredient: BarcodeModel
    
    // Convert to AWSIngredientModel for adding to database
    func toAWSIngredient() -> AWSIngredientModel {
        // Create basic AWS ingredient model from barcode data
        let awsIngredient = AWSIngredientModel(
            edamamFoodId: ingredient.foodId,
            foodCategory: ingredient.category ?? "Unknown",
            name: ingredient.label,
            quantityType: "Serving",
            experiationDuration: 7,
            imageURL: ingredient.image ?? ""
        )
        
        return awsIngredient
    }
} 