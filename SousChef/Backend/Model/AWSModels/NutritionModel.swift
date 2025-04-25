import Foundation

struct AWSIngredientNutritionModel: Codable {
    let edamamFoodId: String
    let name: String
    let foodCategory: String
    let quantityType: String
    let experiationDuration: Int?
    let fat: Double
    let cholesterol: Double
    let sodium: Double
    let potassium: Double
    let carbohydrate: Double
    let protein: Double
    let calorie: Double
    let quantity: Double
    
    enum CodingKeys: String, CodingKey {
        case edamamFoodId = "Edamam_Food_ID"
        case name = "Name"
        case foodCategory = "Category"
        case quantityType = "Quantity_Type"
        case experiationDuration = "Expiration_Duration"
        case fat = "Fat"
        case cholesterol = "Cholesterol"
        case sodium = "Sodium"
        case potassium = "Potassium"
        case carbohydrate = "Carbohydrate"
        case protein = "Protein"
        case calorie = "Calorie"
        case quantity = "Quantity"
    }
    
    init(
        edamamFoodId: String,
        name: String,
        foodCategory: String,
        quantityType: String,
        experiationDuration: Int?,
        fat: Double,
        cholesterol: Double,
        sodium: Double,
        potassium: Double,
        carbohydrate: Double,
        protein: Double,
        calorie: Double,
        quantity: Double
    ) {
        self.edamamFoodId = edamamFoodId
        self.name = name
        self.foodCategory = foodCategory
        self.quantityType = quantityType
        self.experiationDuration = experiationDuration
        self.fat = fat
        self.cholesterol = cholesterol
        self.sodium = sodium
        self.potassium = potassium
        self.carbohydrate = carbohydrate
        self.protein = protein
        self.calorie = calorie
        self.quantity = quantity
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        edamamFoodId = try container.decode(String.self, forKey: .edamamFoodId)
        name = try container.decode(String.self, forKey: .name)
        foodCategory = try container.decode(String.self, forKey: .foodCategory)
        quantityType = try container.decode(String.self, forKey: .quantityType)
        
        experiationDuration = try container.decodeIfPresent(Int.self, forKey: .experiationDuration)
        
        // Handle values
        fat = try Self.decodeNumeric(from: container, forKey: .fat)
        cholesterol = try Self.decodeNumeric(from: container, forKey: .cholesterol)
        sodium = try Self.decodeNumeric(from: container, forKey: .sodium)
        potassium = try Self.decodeNumeric(from: container, forKey: .potassium)
        carbohydrate = try Self.decodeNumeric(from: container, forKey: .carbohydrate)
        protein = try Self.decodeNumeric(from: container, forKey: .protein)
        calorie = try Self.decodeNumeric(from: container, forKey: .calorie)
        quantity = try Self.decodeNumeric(from: container, forKey: .quantity)
    }
    
    // Helper function to decode values
    private static func decodeNumeric(from container: KeyedDecodingContainer<CodingKeys>, forKey key: CodingKeys) throws -> Double {
        if let value = try? container.decode(Double.self, forKey: key) {
            return value
        }
        
        if let stringValue = try? container.decode(String.self, forKey: key),
           let doubleValue = Double(stringValue) {
            return doubleValue
        }
        
        throw DecodingError.dataCorruptedError(
            forKey: key,
            in: container,
            debugDescription: "Expected a number or string with numeric value"
        )
    }
}
