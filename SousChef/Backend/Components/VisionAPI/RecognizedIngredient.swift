import Foundation

struct RecognizedIngredient: Identifiable, Hashable {
    let id = UUID()
    let name: String
    var selected: Bool = true
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: RecognizedIngredient, rhs: RecognizedIngredient) -> Bool {
        return lhs.id == rhs.id
    }
} 