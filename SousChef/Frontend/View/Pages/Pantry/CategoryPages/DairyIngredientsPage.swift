import SwiftUI

struct DairyIngredientsPage: View {
    @EnvironmentObject var userSession: UserSession
    @StateObject private var pantryController = PantryController(userSession: UserSession())
    
    var body: some View {
        BaseIngredientsPage(
            title: "Dairy",
            ingredients: pantryController.pantryItems.isEmpty ? 
                ["Milk", "Cheddar Cheese", "Greek Yogurt"] : 
                pantryController.pantryItems
                    .filter { $0.foodCategory.lowercased() == "dairy" }
                    .map { $0.text },
            category: .dairy
        )
        .onAppear {
            pantryController.fetchIngredients()
        }
    }
}

