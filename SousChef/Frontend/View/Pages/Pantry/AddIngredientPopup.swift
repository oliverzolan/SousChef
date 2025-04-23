import SwiftUI

struct AddIngredientPopup: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var userSession: UserSession
    @ObservedObject private var viewModel: IngredientController
    @FocusState private var isSearching: Bool

    @Binding var ingredients: [String]
    var scannedIngredient: BarcodeModel?
    @State private var selectedIngredients: [EditableIngredient] = []
    @State private var showToast: Bool = false
    @State private var toastMessage: String = ""
    @State private var showQuantitySheet: Bool = false
    @State private var currentIngredient: EdamamIngredientModel?
    @State private var tempQuantity: Double = 1.0
    @State private var searchText: String = ""

    init(ingredients: Binding<[String]>, scannedIngredient: BarcodeModel?, userSession: UserSession) {
        self._ingredients = ingredients
        self.scannedIngredient = scannedIngredient
        self.viewModel = IngredientController(userSession: userSession)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray.opacity(0.7))
                        .padding(.leading, 8)
                    
                    TextField("Search for ingredient...", text: $searchText)
                        .focused($isSearching)
                        .autocorrectionDisabled(true)
                        .autocapitalization(.none)
                        .submitLabel(.search)
                        .onSubmit {
                            let finalText = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
                            if !finalText.isEmpty {
                                viewModel.searchText = finalText
                                viewModel.performSearch()
                            }
                            isSearching = false
                        }
                    
                    if !searchText.isEmpty {
                        Button(action: {
                            searchText = ""
                            viewModel.searchText = ""
                            viewModel.searchResults = []
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                                .padding(.trailing, 8)
                        }
                    }
                }
                .padding(10)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                .padding(.horizontal)
                .padding(.top, 10)
                .onChange(of: searchText) { _, newValue in
                    DispatchQueue.main.async {
                        viewModel.searchText = newValue
                        viewModel.performSearch()
                    }
                }
                
                // Main Content
                ScrollView {
                    VStack(spacing: 0) {
                        // Scanned ingredient if available
                        if let ingredient = scannedIngredient {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Scanned Ingredient:")
                                    .font(.headline)
                                    .padding(.horizontal)
                                    .padding(.top, 8)

                                IngredientCard(
                                    name: ingredient.label,
                                    category: categoryForIngredient(ingredient)
                                )
                                .padding(.horizontal)
                                
                                Divider()
                            }
                        }
                        
                        // Search Results
                        if (isSearching || !searchText.isEmpty) && !viewModel.searchResults.isEmpty {
                            VStack(alignment: .leading, spacing: 10) {
                                if viewModel.isLoading {
                                    HStack {
                                        Spacer()
                                        ProgressView("Searching...")
                                        Spacer()
                                    }
                                    .padding()
                                } else if let errorMessage = viewModel.errorMessage {
                                    Text(errorMessage)
                                        .foregroundColor(.red)
                                        .padding()
                                } else {
                                    HStack {
                                        Text("Search Results")
                                            .font(.headline)
                                        
                                        Spacer()
                                        
                                        Text("\(min(5, viewModel.searchResults.count)) of \(viewModel.searchResults.count)")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(.horizontal)
                                    .padding(.top, 8)
                                    
                                    LazyVGrid(columns: [
                                        GridItem(.flexible(), spacing: 10),
                                        GridItem(.flexible(), spacing: 10),
                                        GridItem(.flexible(), spacing: 10)
                                    ], spacing: 10) {
                                        ForEach(viewModel.searchResults.prefix(5)) { ingredient in
                                            Button(action: {
                                                currentIngredient = ingredient
                                                tempQuantity = 1.0
                                                showQuantitySheet = true
                                            }) {
                                                IngredientCard(
                                                    name: ingredient.label,
                                                    category: categoryForIngredient(ingredient)
                                                )
                                            }
                                        }
                                    }
                                    .padding()
                                    
                                    if viewModel.searchResults.count > 5 {
                                        Button(action: {
                                            isSearching = true // Keep keyboard active
                                        }) {
                                            Text("Type more to refine search...")
                                                .font(.subheadline)
                                                .foregroundColor(.blue)
                                                .padding(.vertical, 8)
                                                .frame(maxWidth: .infinity)
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Selected Ingredients
                        if !selectedIngredients.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Selected Ingredients")
                                    .font(.headline)
                                    .padding(.horizontal)
                                    .padding(.top, 16)
                                
                                LazyVGrid(columns: [
                                    GridItem(.flexible(), spacing: 10),
                                    GridItem(.flexible(), spacing: 10),
                                    GridItem(.flexible(), spacing: 10)
                                ], spacing: 10) {
                                    ForEach(selectedIngredients) { ingredient in
                                        IngredientCard(
                                            name: ingredient.label,
                                            category: categoryForIngredient(ingredient)
                                        )
                                        .overlay(
                                            Button(action: {
                                                removeIngredientFromList(ingredient)
                                            }) {
                                                Image(systemName: "xmark.circle.fill")
                                                    .foregroundColor(.red)
                                                    .background(Color.white)
                                                    .clipShape(Circle())
                                            }
                                            .padding(5),
                                            alignment: .topTrailing
                                        )
                                    }
                                }
                                .padding()
                            }
                        } else if viewModel.searchResults.isEmpty && !viewModel.isLoading && searchText.isEmpty && scannedIngredient == nil {
                            VStack(spacing: 20) {
                                Image(systemName: "magnifyingglass")
                                    .font(.system(size: 50))
                                    .foregroundColor(.gray)
                                
                                Text("Search for ingredients to add to your pantry")
                                    .font(.headline)
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.gray)
                                    .padding()
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.top, 80)
                        }
                        
                        Spacer()
                    }
                    .padding(.bottom, 100)
                }
            }
            .navigationTitle("Add Ingredients")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !selectedIngredients.isEmpty {
                        Button(action: submitIngredientsFromList) {
                            Text("Add")
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.green)
                                .cornerRadius(8)
                        }
                    }
                }
            }
            .sheet(isPresented: $showQuantitySheet) {
                if let ingredient = currentIngredient {
                    QuantitySelectionSheet(
                        ingredient: ingredient,
                        quantity: $tempQuantity,
                        onAdd: {
                            addIngredientWithQuantity(ingredient, quantity: tempQuantity)
                            showQuantitySheet = false
                            // Clear search if the user has chosen an item
                            searchText = ""
                            viewModel.searchText = ""
                            viewModel.searchResults = []
                            UIApplication.shared.endEditing()
                        },
                        onCancel: {
                            showQuantitySheet = false
                        }
                    )
                }
            }
            .onAppear {
                // Add scanned ingredient if available
                if let ingredient = scannedIngredient {
                    addScannedIngredientToList(ingredient)
                }
            }
            .toast(isPresented: $showToast, message: toastMessage)
        }
    }
    
    // Helper function to determine category for ingredient
    private func categoryForIngredient(_ ingredient: Any) -> IngredientCategory {
        if let edamamIngredient = ingredient as? EdamamIngredientModel {
            return categoryFromString(edamamIngredient.category ?? "")
        } else if let barcodeIngredient = ingredient as? BarcodeModel {
            return categoryFromString(barcodeIngredient.category ?? "")
        } else if let editableIngredient = ingredient as? EditableIngredient {
            return categoryFromString(editableIngredient.category ?? "")
        }
        return .vegetable // Default category
    }
    
    private func categoryFromString(_ category: String) -> IngredientCategory {
        switch category.lowercased() {
        case "vegetable", "vegetables": return .vegetable
        case "fruit", "fruits": return .fruit
        case "grain", "grains": return .grain
        case "protein", "meat", "meats": return .protein
        case "dairy": return .dairy
        case "condiment", "spice", "spices": return .condiment
        default: return .vegetable
        }
    }
    
    // Check if ingredient is already selected
    private func isIngredientSelected(_ ingredient: Any) -> Bool {
        if let edamamIngredient = ingredient as? EdamamIngredientModel {
            return selectedIngredients.contains(where: { $0.foodId == edamamIngredient.foodId })
        } else if let barcodeIngredient = ingredient as? BarcodeModel {
            return selectedIngredients.contains(where: { $0.foodId == barcodeIngredient.foodId })
        }
        return false
    }
    
    // Add ingredient with specific quantity
    private func addIngredientWithQuantity(_ ingredient: EdamamIngredientModel, quantity: Double) {
        let newIngredient = EditableIngredient(
            id: UUID(),
            foodId: ingredient.foodId,
            label: ingredient.label,
            category: ingredient.category,
            brand: nil,
            image: ingredient.image,
            quantity: quantity
        )
        
        if !selectedIngredients.contains(where: { $0.foodId == newIngredient.foodId }) {
            selectedIngredients.append(newIngredient)
            toastMessage = "\(ingredient.label) Added!"
            showToast = true
        }
    }
    
    // Add scanned ingredient to list
    private func addScannedIngredientToList(_ ingredient: BarcodeModel) {
        let newIngredient = EditableIngredient(
            id: UUID(),
            foodId: ingredient.foodId,
            label: ingredient.label,
            category: ingredient.category,
            brand: ingredient.brand,
            image: ingredient.image,
            quantity: 1
        )
        
        if !selectedIngredients.contains(where: { $0.foodId == newIngredient.foodId }) {
            selectedIngredients.append(newIngredient)
            toastMessage = "\(ingredient.label) Added!"
            showToast = true
        }
    }
    
    // Remove ingredients
    private func removeIngredientFromList(_ ingredient: EditableIngredient) {
        selectedIngredients.removeAll { $0.id == ingredient.id }
    }
    
    // Submit all ingredients
    private func submitIngredientsFromList() {
        for ingredient in selectedIngredients {
            let barcodeModel = BarcodeModel(
                foodId: ingredient.foodId,
                label: ingredient.label,
                brand: ingredient.brand,
                category: ingredient.category,
                image: ingredient.image,
                nutrients: nil
            )
            viewModel.addIngredientToDatabase(barcodeModel) {
                print("Added \(ingredient.label) to pantry.")
            }
        }
        
        // Show success toast and dismiss
        toastMessage = "\(selectedIngredients.count) Ingredient\(selectedIngredients.count > 1 ? "s" : "") Added to Pantry"
        showToast = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            dismiss()
        }
    }
}
