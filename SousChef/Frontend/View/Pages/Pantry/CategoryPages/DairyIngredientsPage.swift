import SwiftUI

struct DairyIngredientsPage: View {
    @EnvironmentObject var userSession: UserSession
    @StateObject private var pantryController: PantryController
    
    init() {
        _pantryController = StateObject(wrappedValue: PantryController(userSession: UserSession()))
    }
    
    var body: some View {
        BaseIngredientsPage(
            title: "Dairy",
            ingredients: pantryController.pantryItems
                .filter { $0.foodCategory.lowercased() == "dairy" },
            category: .dairy
        )
        .onAppear {
            pantryController.fetchIngredients()
        }
    }
}

