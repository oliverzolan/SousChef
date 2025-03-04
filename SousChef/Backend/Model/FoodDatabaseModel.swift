import Foundation

struct FoodSearchResponse: Decodable {
    let text: String?
    let hints: [Hint]
}

struct Hint: Decodable {
    let food: FoodModel
}

struct FoodModel: Decodable, Identifiable {
    var id: String { foodId }

    let foodId: String
    let label: String
    let category: String?
    let categoryLabel: String?
    let image: String?
    let nutrients: FoodNutrients?
}

struct FoodNutrients: Decodable {
    let ENERC_KCAL: Double? // Calories
    let PROCNT: Double?     // Protein
    let FAT: Double?        // Fat
    let CHOCDF: Double?     // Carbs
    let FIBTG: Double?      // Fiber
}
