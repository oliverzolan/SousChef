import Foundation

struct RecognizedIngredientWithDetails: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let edamamFoodId: String
    let category: String
    let imageURL: String
    let quantityType: String
    let expirationDays: Int
    var selected: Bool = true
    
    var asAWSIngredientModel: AWSIngredientModel {
        return AWSIngredientModel(
            edamamFoodId: edamamFoodId,
            foodCategory: category,
            name: name.capitalized,
            quantityType: quantityType,
            experiationDuration: expirationDays,
            imageURL: imageURL
        )
    }
    
    static func fromBasic(_ basic: RecognizedIngredient, 
                         edamamFoodId: String = UUID().uuidString, 
                         category: String = "Generic",
                         imageURL: String = "",
                         quantityType: String = "Serving",
                         expirationDays: Int = 7) -> RecognizedIngredientWithDetails {
        
        return RecognizedIngredientWithDetails(
            name: basic.name,
            edamamFoodId: edamamFoodId,
            category: category,
            imageURL: imageURL,
            quantityType: quantityType,
            expirationDays: expirationDays,
            selected: basic.selected
        )
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: RecognizedIngredientWithDetails, rhs: RecognizedIngredientWithDetails) -> Bool {
        return lhs.id == rhs.id
    }
} 