import SwiftUI

struct AllIngredientsPage: View {
    @EnvironmentObject var userSession: UserSession
    @StateObject private var pantryController: PantryController

    init(userSession: UserSession) {
        _pantryController = StateObject(wrappedValue: PantryController(userSession: userSession))
    }
    
    var body: some View {
        BaseIngredientsPage(
            title: "All Ingredients",
            ingredients: pantryController.pantryItems.map { $0.text },
            category: .vegetable // Default color, could be changed based on UI preference
        )
        .onAppear {
            pantryController.fetchIngredients()
        }
        .alert(isPresented: Binding<Bool>(
            get: { pantryController.errorMessage != nil },
            set: { _ in pantryController.errorMessage = nil }
        )) {
            Alert(title: Text("Error"),
                  message: Text(pantryController.errorMessage ?? "Unknown error"),
                  dismissButton: .default(Text("OK")))
        }
    }
}

struct AllIngredientsPage_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AllIngredientsPage(userSession: UserSession())
                .environmentObject(UserSession())
        }
    }
}
