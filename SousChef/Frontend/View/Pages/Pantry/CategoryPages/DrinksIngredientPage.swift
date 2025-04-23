import SwiftUI

struct DrinksIngredientsPage: View {
    @EnvironmentObject var userSession: UserSession
    @StateObject private var pantryController = PantryController(userSession: UserSession())
    
    var body: some View {
        BaseIngredientsPage(
            title: "Drinks",
            ingredients: pantryController.pantryItems.isEmpty ? 
                ["Beer", "Cider", "Wine", "Soda", "Lemonade", "Mocktail"] : 
                pantryController.pantryItems
                    .filter { $0.foodCategory.lowercased() == "drink" }
                    .map { $0.text },
            category: .fruit // Using fruit color as a fallback
        )
        .onAppear {
            pantryController.fetchIngredients()
        }
    }
}
