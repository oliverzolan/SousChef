import SwiftUICore

struct VegetablesIngredientsPage: View {
    @EnvironmentObject var userSession: UserSession
    @StateObject private var pantryController = PantryController(userSession: UserSession())
    
    var body: some View {
        BaseIngredientsPage(
            title: "Vegetables",
            ingredients: pantryController.pantryItems.map { $0.text }
        )
        .onAppear {
            pantryController.fetchIngredients()
        }
    }
}
