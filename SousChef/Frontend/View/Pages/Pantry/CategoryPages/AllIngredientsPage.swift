import SwiftUI

struct AllIngredientsPage: View {
    @EnvironmentObject var userSession: UserSession
    @StateObject private var pantryController: PantryController
    @State private var collapsedCategories: Set<String> = []
    
    init() {
        _pantryController = StateObject(wrappedValue: PantryController(userSession: UserSession()))
    }
    
    // Group ingredients by category
    private func groupedIngredients() -> [String: [AWSIngredientModel]] {
        Dictionary(grouping: pantryController.pantryItems) { item in
            item.foodCategory
        }
    }
    
    // Map food category string to IngredientCategory enum
    private func mapToCategory(_ categoryString: String) -> IngredientCategory {
        let category = categoryString.lowercased()
        
        if category.contains("vegetable") { return .vegetable }
        if category.contains("fruit") { return .fruit }
        if category.contains("grain") || category.contains("bread") || category.contains("pasta") { return .grain }
        if category.contains("meat") || category.contains("protein") || category.contains("poultry") || category.contains("seafood") || category.contains("fish") { return .protein }
        if category.contains("dairy") || category.contains("milk") || category.contains("cheese") { return .dairy }
        if category.contains("condiment") || category.contains("sauce") { return .condiment }
        if category.contains("canned") || category.contains("canned goods") || category.contains("canned_goods") { return .canned }
        if category.contains("spice") || category.contains("herb") { return .spice }
        if category.contains("drink") || category.contains("beverage") { return .drink }
        
        // Default to vegetable if no match
        return .vegetable
    }
    
    // Toggle category collapse state
    private func toggleCategory(_ category: String) {
        withAnimation(nil) {
            if collapsedCategories.contains(category) {
                collapsedCategories.remove(category)
            } else {
                collapsedCategories.insert(category)
            }
        }
    }
    
    // Check if a category is collapsed
    private func isCategoryCollapsed(_ category: String) -> Bool {
        collapsedCategories.contains(category)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray.opacity(0.7))
                    .padding(.leading, 8)
                
                TextField("Search...", text: .constant(""))
                    .padding(.vertical, 8)
                
                Button(action: {}) {
                    Image(systemName: "slider.horizontal.3")
                        .foregroundColor(.gray)
                        .padding(.trailing, 8)
                }
            }
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
            .padding(.horizontal)
            .padding(.top, 10)
            
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    // Add space at the top
                    Spacer()
                        .frame(height: 20)
                    
                    ForEach(groupedIngredients().keys.sorted(), id: \.self) { category in
                        if let items = groupedIngredients()[category], !items.isEmpty {
                            // Category header with collapse button
                            Button(action: { toggleCategory(category) }) {
                                VStack(spacing: 0) {
                                    Divider()
                                        .padding(.horizontal, -20)
                                    
                                    HStack {
                                        Text(category.capitalized)
                                            .font(.headline)
                                            .fontWeight(.bold)
                                            .foregroundColor(.primary)
                                        
                                        Spacer()
                                        
                                        Image(systemName: isCategoryCollapsed(category) ? "chevron.down" : "chevron.up")
                                            .foregroundColor(.gray)
                                            .font(.system(size: 14))
                                    }
                                    .padding(.horizontal)
                                    .padding(.vertical, 10)
                                    
                                    if isCategoryCollapsed(category) {
                                        Divider()
                                            .padding(.horizontal, -20)
                                    }
                                }
                                .background(Color.white)
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            // Ingredients grid - only show if not collapsed
                            if !isCategoryCollapsed(category) {
                                let columns = [
                                    GridItem(.flexible(), spacing: 10),
                                    GridItem(.flexible(), spacing: 10),
                                    GridItem(.flexible(), spacing: 10)
                                ]
                                
                                LazyVGrid(columns: columns, spacing: 10) {
                                    ForEach(items, id: \.edamamFoodId) { ingredient in
                                        IngredientCard(
                                            ingredient: ingredient, 
                                            category: mapToCategory(category)
                                        )
                                    }
                                }
                                .padding(.horizontal)
                                .padding(.top, 4)
                                .padding(.bottom, 16)
                                
                                Divider()
                                    .padding(.horizontal, -20)
                            }
                        }
                    }
                }
                .padding(.bottom, 80)
            }
        }
        .navigationTitle("All Ingredients")
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            Button(action: { 
                NotificationCenter.default.post(name: NSNotification.Name("ShowAddIngredientSheet"), object: nil)
            }) {
                Text("Add Ingredient")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppColors.primary2)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .padding(.vertical, 10)
            }
            .background(Color(.systemBackground))
        }
        .onAppear {
            pantryController.fetchIngredients()
            setupNotificationObserver()
        }
        .onDisappear {
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
        .sheet(isPresented: .constant(false)) {
            AddIngredientPopup()
                .environmentObject(userSession)
        }
    }
    
    private func setupNotificationObserver() {
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("RefreshPantryContents"),
            object: nil,
            queue: .main
        ) { _ in
            pantryController.fetchIngredients()
        }
        
        // Add observer for showing add ingredient sheet
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("ShowAddIngredientSheet"),
            object: nil,
            queue: .main
        ) { _ in
            // This will be handled by the parent view
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
