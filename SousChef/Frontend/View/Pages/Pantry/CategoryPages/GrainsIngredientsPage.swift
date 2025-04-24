import SwiftUI

struct GrainsIngredientsPage: View {
    @EnvironmentObject var userSession: UserSession
    @StateObject private var pantryController: PantryController
    
    init() {
        _pantryController = StateObject(wrappedValue: PantryController(userSession: UserSession()))
    }
    
    var body: some View {
        BaseIngredientsPage(
            title: "Grains",
            ingredients: pantryController.pantryItems
                .filter { $0.foodCategory.lowercased() == "grain" },
            category: .grain
        )
        .onAppear {
            pantryController.fetchIngredients()
        }
    }
}
