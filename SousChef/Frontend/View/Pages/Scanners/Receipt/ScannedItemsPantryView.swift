import SwiftUI

struct ScannedItemsPantryView: View {
    @EnvironmentObject var userSession: UserSession
    @Environment(\.presentationMode) var presentationMode
    
    var validatedItems: [AWSIngredientModel]
    var userSessionParam: UserSession?
    
    @State private var selectedItems: [AWSIngredientModel] = []
    @State private var isAddingToPantry = false
    @State private var showSuccessAlert = false
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    
    let columns = [
        GridItem(.adaptive(minimum: 110, maximum: 130), spacing: 20),
    ]
    
    var body: some View {
        NavigationView {
            VStack {
                // Top section
                HStack {
                    Button(action: dismiss) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.primary)
                            .padding()
                            .background(Color(.systemGray6))
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    Text("Scanned Ingredients")
                        .font(.headline)
                        .bold()
                    
                    Spacer()
                    
                    Text("\(selectedItems.count)/\(validatedItems.count)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.trailing)
                }
                .padding(.horizontal)
                
                if validatedItems.isEmpty {
                    Spacer()
                    emptyStateView
                    Spacer()
                } else {
                    // Ingredient grid
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(validatedItems, id: \.edamamFoodId) { ingredient in
                                SelectableIngredientWrapper(
                                    ingredient: ingredient,
                                    isSelected: selectedItems.contains(where: { $0.edamamFoodId == ingredient.edamamFoodId }),
                                    onToggle: { toggleSelection(ingredient) }
                                )
                            }
                        }
                        .padding(20)
                        .padding(.bottom, 80)
                    }
                }
            }
            .navigationBarHidden(true)
            .overlay(
                VStack {
                    Spacer()
                    
                    Button(action: addToPantry) {
                        HStack {
                            if isAddingToPantry {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .padding(.trailing, 5)
                            }
                            
                            Text(isAddingToPantry ? "Adding..." : "Add to Pantry")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(selectedItems.isEmpty ? Color.gray : AppColors.primary2)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal)
                    }
                    .disabled(selectedItems.isEmpty || isAddingToPantry)
                    .padding(.bottom)
                }
            )
            .alert(isPresented: $showSuccessAlert) {
                Alert(
                    title: Text("Success"),
                    message: Text("Items added to your pantry!"),
                    dismissButton: .default(Text("OK")) {
                        dismiss()
                    }
                )
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No ingredients found")
                .font(.title2)
                .bold()
                .foregroundColor(.gray)
            
            Text("We couldn't identify any ingredients from your receipt. Try scanning again or add items manually.")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
                .padding(.horizontal, 40)
            
            Button(action: dismiss) {
                Text("Return to Pantry")
                    .font(.headline)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.top)
        }
    }
    
    private func toggleSelection(_ ingredient: AWSIngredientModel) {
        if let index = selectedItems.firstIndex(where: { $0.edamamFoodId == ingredient.edamamFoodId }) {
            selectedItems.remove(at: index)
        } else {
            selectedItems.append(ingredient)
        }
    }
    
    private func addToPantry() {
        guard !selectedItems.isEmpty else { return }
        
        isAddingToPantry = true
        
        // Use the AWS service to add ingredients
        let api = AWSUserIngredientsComponent(userSession: userSessionParam ?? userSession)
        
        api.addIngredients(ingredients: selectedItems) { result in
            DispatchQueue.main.async {
                isAddingToPantry = false
                
                switch result {
                case .success:
                    showSuccessAlert = true
                    // Post notification to refresh pantry contents
                    NotificationCenter.default.post(name: NSNotification.Name("RefreshPantryContents"), object: nil)
                    
                case .failure(let error):
                    errorMessage = error.localizedDescription
                    showErrorAlert = true
                }
            }
        }
    }
    
    private func dismiss() {
        presentationMode.wrappedValue.dismiss()
    }
}

// A wrapper that adds selection functionality to the standard IngredientCard
struct SelectableIngredientWrapper: View {
    let ingredient: AWSIngredientModel
    let isSelected: Bool
    let onToggle: () -> Void
    
    // Determine the ingredient category
    private var ingredientCategory: IngredientCategory {
        let category = ingredient.foodCategory.lowercased()
        
        if category.contains("vegetable") {
            return .vegetable
        } else if category.contains("fruit") {
            return .fruit
        } else if category.contains("grain") || category.contains("bread") || category.contains("pasta") {
            return .grain
        } else if category.contains("meat") || category.contains("poultry") || category.contains("seafood") || category.contains("fish") {
            return .protein
        } else if category.contains("dairy") || category.contains("milk") || category.contains("cheese") {
            return .dairy
        } else if category.contains("condiment") || category.contains("sauce") {
            return .condiment
        } else if category.contains("canned") {
            return .canned
        } else if category.contains("spice") || category.contains("herb") {
            return .spice
        } else if category.contains("drink") || category.contains("beverage") {
            return .drink
        } else {
            // Default to vegetable if no match
            return .vegetable
        }
    }
    
    var body: some View {
        Button(action: onToggle) {
            ZStack(alignment: .topTrailing) {
                // Use the existing IngredientCard component
                IngredientCard(ingredient: ingredient, category: ingredientCategory)
                
                // Selection indicator
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 22))
                        .foregroundColor(.white)
                        .background(Color.green)
                        .clipShape(Circle())
                        .padding(8)
                        .shadow(color: Color.black.opacity(0.3), radius: 2, x: 0, y: 1)
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? Color.green : Color.clear, lineWidth: 3)
            )
        }
    }
}

// Preview provider
struct ScannedItemsPantryView_Previews: PreviewProvider {
    static var previews: some View {
        let mockItems = [
            AWSIngredientModel(
                edamamFoodId: "mock_apple",
                foodCategory: "Fruit",
                name: "Apple",
                quantityType: "5",
                experiationDuration: 7,
                imageURL: "https://d2al2iwesviy8h.cloudfront.net/ingredients/thumbs/Fruits/apple.webp"
            ),
            AWSIngredientModel(
                edamamFoodId: "mock_banana",
                foodCategory: "Fruit",
                name: "Banana",
                quantityType: "4",
                experiationDuration: 5,
                imageURL: "https://d2al2iwesviy8h.cloudfront.net/ingredients/thumbs/Fruits/banana.webp"
            ),
            AWSIngredientModel(
                edamamFoodId: "mock_chicken",
                foodCategory: "Meat",
                name: "Chicken",
                quantityType: "2",
                experiationDuration: 3,
                imageURL: "https://d2al2iwesviy8h.cloudfront.net/ingredients/thumbs/meats/chicken.webp"
            )
        ]
        
        return ScannedItemsPantryView(validatedItems: mockItems, userSessionParam: UserSession())
            .environmentObject(UserSession())
    }
} 