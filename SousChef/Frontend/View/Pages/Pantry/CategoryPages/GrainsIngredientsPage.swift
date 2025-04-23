import SwiftUI

struct GrainsIngredientsPage: View {
    @EnvironmentObject var userSession: UserSession
    @StateObject private var pantryController = PantryController(userSession: UserSession())
    
    var body: some View {
        BaseIngredientsPage(
            title: "Grains",
            ingredients: pantryController.pantryItems.isEmpty ? 
                ["Rice", "Quinoa", "Oats"] : 
                pantryController.pantryItems
                    .filter { $0.foodCategory.lowercased() == "grain" }
                    .map { $0.text },
            category: .grain
        )
        .onAppear {
            pantryController.fetchIngredients()
        }
    }
}
