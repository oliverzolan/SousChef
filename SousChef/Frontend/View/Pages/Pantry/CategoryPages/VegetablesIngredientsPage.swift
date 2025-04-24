import SwiftUI
import Combine

struct VegetablesIngredientsPage: View {
    @EnvironmentObject var userSession: UserSession
    @StateObject private var pantryController = PantryController(userSession: UserSession())
    @State private var filteredIngredients: [AWSIngredientModel] = []
    @State private var cancellables = Set<AnyCancellable>()
    
    var body: some View {
        BaseIngredientsPage(
            title: "Vegetables",
            ingredients: filteredIngredients,
            category: .vegetable
        )
        .onAppear {
            if let token = userSession.token {
                pantryController.userSession = userSession
            }
            setupPantryObserver()
            refreshIngredients()
            
            // Setup notification observer for refreshing contents
            setupNotificationObserver()
        }
        .onDisappear {
            // Remove notification observer when view disappears
            NotificationCenter.default.removeObserver(self)
        }
    }
    
    // Setup notification observer for pantry refresh events
    private func setupNotificationObserver() {
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("RefreshPantryContents"),
            object: nil,
            queue: .main
        ) { _ in
            refreshIngredients()
        }
    }
    
    // Handle updates to pantry inventory
    private func setupPantryObserver() {
        pantryController.$pantryItems
            .sink { items in
                self.updateFilteredIngredients(from: items)
            }
            .store(in: &cancellables)
    }
    
    private func updateFilteredIngredients(from ingredients: [AWSIngredientModel]) {
        filteredIngredients = ingredients.filter { ingredient in
            let category = ingredient.foodCategory.lowercased()
            return category == "vegetable" || category == "vegetables"
        }
    }
    
    private func refreshIngredients() {
        pantryController.fetchIngredients()
    }
}

struct VegetablesIngredientsPage_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            VegetablesIngredientsPage()
                .environmentObject(UserSession())
        }
    }
}
