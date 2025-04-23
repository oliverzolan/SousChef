import SwiftUI

struct MeatsIngredientsPage: View {
    @EnvironmentObject var userSession: UserSession
    @StateObject private var pantryController = PantryController(userSession: UserSession())
    
    var body: some View {
        BaseIngredientsPage(
            title: "Meats",
            ingredients: pantryController.pantryItems.isEmpty ? 
                ["Chicken", "Beef", "Turkey"] : 
                pantryController.pantryItems
                    .filter { $0.foodCategory.lowercased() == "protein" }
                    .map { $0.text },
            category: .protein
        )
        .onAppear {
            pantryController.fetchIngredients()
        }
    }
}
