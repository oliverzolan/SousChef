import SwiftUI
import Combine

struct MeatsIngredientsPage: View {
    @EnvironmentObject var userSession: UserSession
    @StateObject private var pantryController: PantryController
    @State private var filteredIngredients: [AWSIngredientModel] = []
    @State private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Initialize with a temporary UserSession that will be replaced
        _pantryController = StateObject(wrappedValue: PantryController(userSession: UserSession()))
    }
    
    var body: some View {
        BaseIngredientsPage(
            title: "Meats",
            ingredients: filteredIngredients,
            category: .protein
        )
        .onAppear {
            // Use the environment's userSession
            pantryController.userSession = userSession
            
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
    
    // Process pantry inventory updates
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
            return category == "meat" || category == "meats" || category == "protein" || category == "seafood"
        }
    }
    
    private func refreshIngredients() {
        pantryController.fetchIngredients()
    }
}
