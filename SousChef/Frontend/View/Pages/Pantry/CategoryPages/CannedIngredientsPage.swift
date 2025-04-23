import SwiftUI

struct CannedIngredientsPage: View {
    @EnvironmentObject var userSession: UserSession
    @StateObject private var pantryController = PantryController(userSession: UserSession())
    
    var body: some View {
        BaseIngredientsPage(
            title: "Canned",
            ingredients: pantryController.pantryItems.isEmpty ? 
                ["Beans", "Tuna", "Chicken"] : 
                pantryController.pantryItems
                    .filter { $0.foodCategory.lowercased() == "canned" }
                    .map { $0.text },
            category: .condiment // Using condiment color as a fallback
        )
        .onAppear {
            pantryController.fetchIngredients()
        }
    }
}

