import SwiftUI

struct FruitsIngredientsPage: View {
    @EnvironmentObject var userSession: UserSession
    @StateObject private var pantryController = PantryController(userSession: UserSession())
    
    var body: some View {
        BaseIngredientsPage(
            title: "Fruits",
            ingredients: pantryController.pantryItems.isEmpty ? 
                ["Apple", "Banana", "Orange", "Pineapple", "Strawberry"] : 
                pantryController.pantryItems
                    .filter { $0.foodCategory.lowercased() == "fruit" }
                    .map { $0.text },
            category: .fruit
        )
        .onAppear {
            pantryController.fetchIngredients()
        }
    }
}

