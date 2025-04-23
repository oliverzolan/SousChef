import SwiftUI

struct CondimentsIngredientsPage: View {
    @EnvironmentObject var userSession: UserSession
    @StateObject private var pantryController = PantryController(userSession: UserSession())
    
    var body: some View {
        BaseIngredientsPage(
            title: "Condiments",
            ingredients: pantryController.pantryItems.isEmpty ? 
                ["Ketchup", "Mustard", "Mayonnaise"] : 
                pantryController.pantryItems
                    .filter { $0.foodCategory.lowercased() == "condiment" }
                    .map { $0.text },
            category: .condiment
        )
        .onAppear {
            pantryController.fetchIngredients()
        }
    }
}

