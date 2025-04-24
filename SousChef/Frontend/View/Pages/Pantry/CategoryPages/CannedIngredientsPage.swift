import SwiftUI

struct CannedIngredientsPage: View {
    @EnvironmentObject var userSession: UserSession
    @StateObject private var pantryController: PantryController

    init() {
        _pantryController = StateObject(wrappedValue: PantryController(userSession: UserSession()))
    }

    var body: some View {
        BaseIngredientsPage(
            title: "Canned Goods",
            ingredients: pantryController.pantryItems
                .filter { 
                    let category = $0.foodCategory.lowercased()
                    return category == "canned" || 
                           category == "canned goods" || 
                           category == "canned_goods"
                },
            category: .canned
        )
        .onAppear {
            pantryController.fetchIngredients()
        }
    }
}
