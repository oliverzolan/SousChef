import SwiftUI

struct VegetablesIngredientsPage: View {
    @EnvironmentObject var userSession: UserSession
    @StateObject private var pantryController = PantryController(userSession: UserSession())
    
    var body: some View {
        BaseIngredientsPage(
            title: "Vegetables",
            ingredients: pantryController.pantryItems.isEmpty ? 
                ["Carrot", "Eggplant", "Broccoli"] : 
                pantryController.pantryItems
                    .filter { $0.foodCategory.lowercased() == "vegetable" }
                    .map { $0.text },
            category: .vegetable
        )
        .onAppear {
            pantryController.fetchIngredients()
        }
    }
}
