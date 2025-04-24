import SwiftUI

struct AllIngredientsPage: View {
    @EnvironmentObject var userSession: UserSession
    @StateObject private var pantryController: PantryController
    
    init() {
        _pantryController = StateObject(wrappedValue: PantryController(userSession: UserSession()))
    }
    
    var body: some View {
        BaseIngredientsPage(
            title: "All Ingredients",
            ingredients: pantryController.pantryItems,
            category: .vegetable 
        )
        .onAppear {
            pantryController.fetchIngredients()
            
            // Setup notification observer for refreshing contents
            setupNotificationObserver()
        }
        .onDisappear {
            // Remove notification observer when view disappears
            NotificationCenter.default.removeObserver(self)
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
    
    // Setup notification observer for pantry refresh events
    private func setupNotificationObserver() {
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("RefreshPantryContents"),
            object: nil,
            queue: .main
        ) { _ in
            pantryController.fetchIngredients()
        }
    }
}

struct AllIngredientsPage_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AllIngredientsPage()
                .environmentObject(UserSession())
        }
    }
}
