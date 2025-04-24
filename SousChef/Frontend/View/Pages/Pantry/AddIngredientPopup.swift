import SwiftUI

struct AddIngredientPopup: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var userSession: UserSession
    @StateObject private var ingredientController: IngredientController
    @StateObject private var pantryController: PantryController
    @State private var searchText = ""
    @State private var showQuantityPicker = false
    @State private var selectedQuantity = 1
    @State private var selectedUnit = "unit"
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var isAdding = false
    @State private var selectedIngredient: AWSIngredientModel?
    
    // Grid layout for ingredient cards
    private let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]
    
    init() {
        let session = UserSession()
        _ingredientController = StateObject(wrappedValue: IngredientController(userSession: session))
        _pantryController = StateObject(wrappedValue: PantryController(userSession: session))
    }
    
    // Helper function to determine ingredient category
    private func determineCategory(for ingredient: AWSIngredientModel) -> IngredientCategory {
        let category = ingredient.foodCategory.lowercased()
        
        if category.contains("vegetable") { return .vegetable }
        if category.contains("fruit") { return .fruit }
        if category.contains("grain") { return .grain }
        if category.contains("meat") || category.contains("protein") { return .protein }
        if category.contains("dairy") { return .dairy }
        if category.contains("condiment") { return .condiment }
        if category.contains("canned") { return .canned }
        if category.contains("spice") { return .spice }
        if category.contains("drink") { return .drink }
        
        // Default category based on first letter
        let firstChar = ingredient.name.prefix(1).lowercased()
        switch firstChar {
        case "a", "b", "c", "d": return .vegetable
        case "e", "f", "g", "h": return .fruit
        case "i", "j", "k", "l": return .grain
        case "m", "n", "o", "p": return .protein
        case "q", "r", "s", "t": return .dairy
        case "u", "v", "w", "x", "y", "z": return .condiment
        default: return .vegetable
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 10) {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray.opacity(0.7))
                        .padding(.leading, 8)
                    
                    TextField("Search ingredients...", text: $searchText)
                        .padding(.vertical, 8)
                        .onChange(of: searchText) { newValue in
                            ingredientController.searchText = newValue
                            ingredientController.performSearch()
                        }
                    
                    if !searchText.isEmpty {
                        Button(action: { 
                            searchText = ""
                            ingredientController.searchText = ""
                            ingredientController.performSearch()
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                                .padding(.trailing, 8)
                        }
                    }
                }
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                .padding(.horizontal)
                
                // Search Results as Ingredient Cards
                if ingredientController.isLoading {
                    Spacer()
                    ProgressView()
                        .scaleEffect(1.5)
                    Spacer()
                } else if !ingredientController.searchResults.isEmpty {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 15) {
                            ForEach(ingredientController.searchResults, id: \.edamamFoodId) { ingredient in
                                IngredientCardSelectable(
                                    ingredient: ingredient,
                                    category: determineCategory(for: ingredient),
                                    isSelected: selectedIngredient?.edamamFoodId == ingredient.edamamFoodId,
                                    onTap: {
                                        selectedIngredient = ingredient
                                        showQuantityPicker = true
                                    }
                                )
                            }
                        }
                        .padding()
                        .padding(.bottom, 80)
                    }
                } else if !searchText.isEmpty {
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
                    Spacer()
                    VStack {
                        Image(systemName: "list.bullet")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                            .padding()
                        
                        Text("Search for ingredients to add to your pantry")
                            .font(.headline)
                            .foregroundColor(.gray)
                        
                        Text("Try searching for common ingredients like 'apple', 'chicken', or 'rice'")
                            .font(.subheadline)
                            .foregroundColor(.gray.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    Spacer()
                }
            }
            .navigationTitle("Add Ingredient")
            .navigationBarItems(trailing: Button("Cancel") {
                dismiss()
            })
            .sheet(isPresented: $showQuantityPicker) {
                if let ingredient = selectedIngredient {
                    QuantityPickerView(
                        ingredient: ingredient,
                        quantity: $selectedQuantity,
                        unit: $selectedUnit,
                        onAdd: { quantity, unit in
                            addIngredient(ingredient, quantity: quantity, unit: unit)
                        }
                    )
                }
            }
            .alert(isPresented: $showError) {
                Alert(
                    title: Text("Error"),
                    message: Text(errorMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
    
    private func addIngredient(_ ingredient: AWSIngredientModel, quantity: Int, unit: String) {
        isAdding = true
        
        // Ensure the image URL is properly formatted
        let imageURL = IngredientImageService.shared.getImageURL(
            for: ingredient.name, 
            category: ingredient.foodCategory,
            existingURL: ingredient.imageURL
        )
        
        let newIngredient = AWSIngredientModel(
            edamamFoodId: ingredient.edamamFoodId,
            foodCategory: ingredient.foodCategory,
            name: ingredient.name,
            quantityType: String(quantity), // Store the quantity as string
            experiationDuration: 7, // Default expiration duration
            imageURL: imageURL
        )
        
        // Use the AWSUserIngredientsComponent directly
        let ingredientsComponent = AWSUserIngredientsComponent(userSession: userSession)
        ingredientsComponent.addIngredients(ingredients: [newIngredient]) { result in
            isAdding = false
            switch result {
            case .success:
                // Refresh the pantry immediately - without delay
                self.pantryController.fetchIngredients()
                
                // Post a notification to refresh all pantry pages
                NotificationCenter.default.post(name: NSNotification.Name("RefreshPantryContents"), object: nil)
                
                // Dismiss immediately after adding
                dismiss()
                
            case .failure(let error):
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }
}

// Selectable version of the IngredientCard for the AddIngredientPopup
struct IngredientCardSelectable: View {
    let ingredient: AWSIngredientModel
    let category: IngredientCategory
    let isSelected: Bool
    let onTap: () -> Void
    
    private func fontSizeForText(_ text: String) -> CGFloat {
        if text.count > 15 { return 14 }
        else if text.count > 10 { return 16 }
        else { return 18 }
    }
    
    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .top) {
                RoundedRectangle(cornerRadius: 20)
                    .fill(category.color)
                    .frame(width: 110, height: 150)
                
                VStack(spacing: 0) {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white)
                        .frame(width: 110, height: 100)
                        .overlay {
                            // Use the ingredient's imageURL via IngredientImageService
                            VStack {
                                ZStack {
                                    let imageUrl = IngredientImageService.shared.getImageURL(
                                        for: ingredient.name,
                                        category: ingredient.foodCategory,
                                        existingURL: ingredient.imageURL
                                    )
                                    
                                    AsyncImage(url: URL(string: imageUrl)) { phase in
                                        switch phase {
                                        case .empty:
                                            ProgressView()
                                                .frame(width: 80, height: 80)
                                        case .success(let image):
                                            image
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: 80, height: 80)
                                                .clipShape(Circle())
                                        case .failure:
                                            // Fall back to emoji if image fails to load
                                            Text(emojiForIngredient(ingredient.name, in: category))
                                                .font(.system(size: 60))
                                                .frame(width: 80, height: 80)
                                        @unknown default:
                                            Text(emojiForIngredient(ingredient.name, in: category))
                                                .font(.system(size: 60))
                                                .frame(width: 80, height: 80)
                                        }
                                    }
                                    .frame(width: 80, height: 80)
                                    
                                    // Selected indicator
                                    if isSelected {
                                        Circle()
                                            .fill(Color.blue.opacity(0.8))
                                            .frame(width: 30, height: 30)
                                            .overlay(
                                                Image(systemName: "checkmark")
                                                    .foregroundColor(.white)
                                                    .font(.system(size: 16, weight: .bold))
                                            )
                                            .offset(x: 30, y: -30)
                                    }
                                    
                                    // Add button indicator
                                    if !isSelected {
                                        Circle()
                                            .fill(Color.white.opacity(0.9))
                                            .frame(width: 26, height: 26)
                                            .overlay(
                                                Image(systemName: "plus")
                                                    .foregroundColor(.blue)
                                                    .font(.system(size: 14, weight: .bold))
                                            )
                                            .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 2)
                                            .offset(x: 30, y: -30)
                                    }
                                }
                            }
                            .padding(10)
                        }
                    Spacer()
                }
                .frame(height: 150)
                
                VStack {
                    Spacer()
                    Text(ingredient.name.capitalized)
                        .font(.system(size: fontSizeForText(ingredient.name), weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 4)
                        .padding(.top, 5)
                        .padding(.bottom, 15)
                        .frame(height: 50)
                }
                .frame(height: 150)
            }
            .frame(width: 110, height: 150)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 3)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct QuantityPickerView: View {
    let ingredient: AWSIngredientModel
    @Binding var quantity: Int
    @Binding var unit: String
    let onAdd: (Int, String) -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Quantity")) {
                    Stepper("Quantity: \(quantity)", value: $quantity, in: 1...100)
                }
                
                Section(header: Text("Unit")) {
                    Picker("Unit", selection: $unit) {
                        Text("unit").tag("unit")
                        Text("g").tag("g")
                        Text("kg").tag("kg")
                        Text("ml").tag("ml")
                        Text("l").tag("l")
                    }
                }
                
                Section {
                    Button("Add to Pantry") {
                        onAdd(quantity, unit)
                        dismiss()
                    }
                }
            }
            .navigationTitle(ingredient.name)
            .navigationBarItems(trailing: Button("Cancel") {
                dismiss()
            })
        }
    }
}

struct AddIngredientPopup_Previews: PreviewProvider {
    static var previews: some View {
        AddIngredientPopup()
            .environmentObject(UserSession())
    }
}
