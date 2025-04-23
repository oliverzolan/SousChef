import SwiftUI

struct SpicesIngredientsPage: View {
    @EnvironmentObject var userSession: UserSession
    @StateObject private var pantryController = PantryController(userSession: UserSession())
    
    var body: some View {
        BaseIngredientsPage(
            title: "Spices",
            ingredients: pantryController.pantryItems.isEmpty ? 
                ["Salt", "Pepper", "Star Anise"] : 
                pantryController.pantryItems
                    .filter { $0.foodCategory.lowercased() == "spice" }
                    .map { $0.text },
            category: .condiment
        )
        .onAppear {
            pantryController.fetchIngredients()
        }
    }
}

