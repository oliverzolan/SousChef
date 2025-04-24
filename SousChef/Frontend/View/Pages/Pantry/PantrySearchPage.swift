import SwiftUI
import Combine

struct PantrySearchPage: View {
    @EnvironmentObject var userSession: UserSession
    @StateObject private var pantryController: PantryController
    @State private var searchText: String
    @State private var filteredIngredients: [AWSIngredientModel] = []
    @State private var cancellables = Set<AnyCancellable>()
    @Environment(\.presentationMode) var presentationMode
    
    // Grid layout for ingredient cards - same as BaseIngredientsPage
    private let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]
    
    init(searchQuery: String, userSession: UserSession) {
        self._searchText = State(initialValue: searchQuery)
        _pantryController = StateObject(wrappedValue: PantryController(userSession: userSession))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Search bar for adjusting the search
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray.opacity(0.7))
                    .padding(.leading, 8)
                
                TextField("Search your pantry...", text: $searchText)
                    .padding(.vertical, 8)
                    .onChange(of: searchText) { newValue in
                        updateFilteredIngredients()
                    }
                
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                            .padding(.trailing, 8)
                    }
                }
            }
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
            .padding(.horizontal)
            .padding(.top, 10)
            
            if pantryController.isLoading {
                Spacer()
                ProgressView()
                    .scaleEffect(1.5)
                Spacer()
            } else if filteredIngredients.isEmpty {
                Spacer()
                VStack {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                        .padding()
                    
                    Text("No results found for \"\(searchText)\"")
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    Text("Try searching for a different ingredient")
                        .font(.subheadline)
                        .foregroundColor(.gray.opacity(0.8))
                }
                .padding(.bottom, 40)
                Spacer()
            } else {
                // Display filtered ingredients in a grid
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 10) {
                        ForEach(filteredIngredients, id: \.edamamFoodId) { ingredient in
                            IngredientCard(
                                ingredient: ingredient,
                                category: getCategoryForIngredient(ingredient)
                            )
                        }
                    }
                    .padding()
                    .padding(.bottom, 80)
                }
            }
        }
        .navigationTitle("Search Results: \(filteredIngredients.count)")
        .navigationBarItems(
            trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            }
        )
        .onAppear {
            // Setup the pantry controller with the user session
            if let token = userSession.token {
                pantryController.userSession = userSession
            }
            
            // Fetch pantry ingredients
            pantryController.fetchIngredients()
            
            // Setup observer for pantry changes
            setupPantryObserver()
            
            // Setup notification observer for refreshing
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
            pantryController.fetchIngredients()
        }
    }
    
    // Subscribe to pantry data changes
    private func setupPantryObserver() {
        pantryController.$pantryItems
            .sink { items in
                self.updateFilteredIngredients()
            }
            .store(in: &cancellables)
    }
    
    // Filter ingredients based on search text
    private func updateFilteredIngredients() {
        if searchText.isEmpty {
            filteredIngredients = pantryController.pantryItems
        } else {
            filteredIngredients = pantryController.pantryItems.filter { ingredient in
                ingredient.name.lowercased().contains(searchText.lowercased())
            }
        }
    }
    
    // Determine category for an ingredient
    private func getCategoryForIngredient(_ ingredient: AWSIngredientModel) -> IngredientCategory {
        let category = ingredient.foodCategory.lowercased()
        
        if category.contains("vegetable") { return .vegetable }
        if category.contains("fruit") { return .fruit }
        if category.contains("grain") { return .grain }
        if category.contains("meat") || category.contains("protein") { return .protein }
        if category.contains("dairy") { return .dairy }
        if category.contains("condiment") { return .condiment }
        if category.contains("canned") { return .canned }
        if category.contains("spice") { return .spice }
        if category.contains("drink") || category.contains("beverage") { return .drink }
        
        // Default category
        return .vegetable
    }
} 