import Foundation

struct Ingredient: Codable, Identifiable {
    let food: String
    let foodCategory: String
    let foodId: String
    let measure: String
    let quantity: Double
    let text: String
    let weight: Double
    
    var id: String { foodId ?? UUID().uuidString }
}
