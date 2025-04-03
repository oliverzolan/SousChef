//
//  AddBarcodeIngredient.swift
//  SousChef
//
//  Created by Oliver Zolan on 3/13/25.
//

import SwiftUI

struct IngredientSearchResultView: View {
    let ingredient: EdamamIngredientModel
    let onSelect: () -> Void
    let isSelected: Bool
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(ingredient.label)
                        .font(.headline)
                        .lineLimit(1)
                    
                    if let category = ingredient.category {
                        HStack(spacing: 4) {
                            Text(category)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.title3)
                } else {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.green)
                        .font(.title3)
                }
            }
            .contentShape(Rectangle())
            .padding(.vertical, 6)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct QuantityInputView: View {
    @Binding var quantity: Double
    @State private var showQuantityInput = false
    @State private var tempQuantity: String = ""
    let onQuantityChanged: ((Double) -> Void)?
    
    init(quantity: Binding<Double>, onQuantityChanged: ((Double) -> Void)? = nil) {
        self._quantity = quantity
        self.onQuantityChanged = onQuantityChanged
        self._tempQuantity = State(initialValue: String(Int(quantity.wrappedValue)))
    }
    
    var body: some View {
        Button(action: {
            tempQuantity = String(Int(quantity))
            showQuantityInput = true
        }) {
            HStack(spacing: 4) {
                Text("\(Int(quantity))")
                    .font(.headline)
                    .frame(minWidth: 30, alignment: .trailing)
                
                Image(systemName: "chevron.down")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(6)
            .background(Color(.systemGray6))
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showQuantityInput) {
            SimpleNumberInputView(
                value: $tempQuantity,
                onDone: { inputValue in
                    if let newValue = Double(inputValue), newValue > 0 {
                        quantity = newValue
                        if let callback = onQuantityChanged {
                            callback(newValue)
                        }
                    }
                },
                onCancel: {
                    // Do nothing on cancel
                }
            )
            .presentationDetents([.height(150)])
        }
    }
}

struct SimpleNumberInputView: View {
    @Binding var value: String
    let onDone: (String) -> Void
    let onCancel: () -> Void
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isInputFocused: Bool
    
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                Text("Enter Quantity")
                    .font(.headline)
                    .padding(.top, 10)
                
                // Input field
                TextField("", text: $value)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.center)
                    .font(.system(size: 36, weight: .bold))
                    .frame(width: 100)
                    .padding(.vertical, 10)
                    .background(Color(.secondarySystemGroupedBackground))
                    .cornerRadius(8)
                    .padding(.top, 10)
                    .focused($isInputFocused)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            isInputFocused = true
                        }
                    }
                
                Spacer(minLength: 0)
            }
            
            VStack {
                HStack {
                    Button("Cancel") {
                        onCancel()
                        dismiss()
                    }
                    .foregroundColor(.red)
                    .padding(.horizontal)
                    .padding(.top, 10)
                    
                    Spacer()
                    
                    Button("Done") {
                        onDone(value)
                        dismiss()
                    }
                    .foregroundColor(.blue)
                    .fontWeight(.bold)
                    .padding(.horizontal)
                    .padding(.top, 10)
                }
                Spacer()
            }
        }
        .presentationDetents([.height(150)])
    }
}

struct SelectedIngredientItemView: View {
    let ingredient: EditableIngredient
    @Binding var selectedIngredients: [EditableIngredient]
    let removeAction: (EditableIngredient) -> Void
    @State private var displayQuantity: Double
    
    init(ingredient: EditableIngredient, selectedIngredients: Binding<[EditableIngredient]>, removeAction: @escaping (EditableIngredient) -> Void) {
        self.ingredient = ingredient
        self._selectedIngredients = selectedIngredients
        self.removeAction = removeAction
        self._displayQuantity = State(initialValue: ingredient.quantity)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(ingredient.label)
                        .font(.headline)
                    if let category = ingredient.category {
                        Text(category)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                HStack(spacing: 16) {
                    // Find index of current ingredient to update quantity
                    if let index = selectedIngredients.firstIndex(where: { $0.id == ingredient.id }) {
                        QuantityInputView(
                            quantity: Binding(
                                get: { self.displayQuantity },
                                set: { newValue in
                                    self.displayQuantity = newValue
                                    selectedIngredients[index].quantity = newValue
                                }
                            ),
                            onQuantityChanged: { newQuantity in
                                // Explicitly update when quantity changes
                                selectedIngredients[index].quantity = newQuantity
                                self.displayQuantity = newQuantity // Update local display
                                print("Updated quantity for \(ingredient.label) to \(newQuantity)")
                            }
                        )
                    }
                    
                    Button(action: {
                        removeAction(ingredient)
                    }) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                            .padding(8)
                            .background(Color(.systemGray6).opacity(0.5))
                            .cornerRadius(8)
                    }
                }
            }
            .padding()
            .onChange(of: ingredient.quantity) { _, newValue in
                // Update local display when ingredient quantity changes
                displayQuantity = newValue
            }
            
            Divider()
        }
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .padding(.horizontal)
    }
}

struct AddIngredientBarcodePage: View {
    @EnvironmentObject var userSession: UserSession
    @ObservedObject private var viewModel: IngredientController
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isSearching: Bool

    @State private var searchText: String = ""
    @State private var selectedIngredients: [EditableIngredient] = []
    @State private var showToast: Bool = false
    @State private var toastMessage: String = ""
    @State private var showQuantitySheet: Bool = false
    @State private var currentIngredient: EdamamIngredientModel?
    @State private var tempQuantity: Double = 1.0

    var scannedIngredient: BarcodeModel?
    var preloadedIngredients: [BarcodeModel]
    
    init(scannedIngredient: BarcodeModel?, userSession: UserSession, preloadedIngredients: [BarcodeModel] = []) {
        self.scannedIngredient = scannedIngredient
        self.preloadedIngredients = preloadedIngredients
        self.viewModel = IngredientController(userSession: userSession)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
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
                        }
                    
                    if !searchText.isEmpty {
                        Button(action: {
                            searchText = ""
                            viewModel.searchText = ""
                            viewModel.searchResults = []
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding(10)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
                .onChange(of: searchText) { _, newValue in
                    DispatchQueue.main.async {
                        viewModel.searchText = newValue
                        viewModel.performSearch()
                    }
                }
                
                // Main Content
                ScrollView {
                    VStack(alignment: .leading, spacing: 8) {
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
                                    
                                    LazyVStack(spacing: 0) {
                                        ForEach(viewModel.searchResults.prefix(5)) { ingredient in
                                            VStack(spacing: 0) {
                                                IngredientSearchResultView(
                                                    ingredient: ingredient,
                                                    onSelect: {
                                                        currentIngredient = ingredient
                                                        tempQuantity = 1.0
                                                        showQuantitySheet = true
                                                    },
                                                    isSelected: isIngredientSelected(ingredient)
                                                )
                                                
                                                Divider()
                                            }
                                            .padding(.horizontal)
                                        }
                                    }
                                    
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
                                
                                ForEach(selectedIngredients) { ingredient in
                                    SelectedIngredientItemView(
                                        ingredient: ingredient,
                                        selectedIngredients: $selectedIngredients,
                                        removeAction: removeIngredientFromList
                                    )
                                }
                            }
                        } else if viewModel.searchResults.isEmpty && !viewModel.isLoading && searchText.isEmpty {
                            VStack(spacing: 20) {
                                Image(systemName: "magnifyingglass")
                                    .font(.system(size: 50))
                                    .foregroundColor(.gray)
                                
                                Text("Search for ingredients or scan barcodes to add to your pantry")
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
                    .padding(.bottom, 100) // Space for the bottom button
                }
            }
            .overlay(
                // Add to Pantry Button
                VStack {
                    Spacer()
                    
                    if !selectedIngredients.isEmpty {
                        Button(action: submitIngredientsFromList) {
                            Text("Add \(selectedIngredients.count) Ingredient\(selectedIngredients.count > 1 ? "s" : "") to Pantry")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .cornerRadius(10)
                                .padding(.horizontal)
                                .padding(.bottom, 8)
                        }
                        .background(
                            Rectangle()
                                .fill(Color(.systemBackground))
                                .edgesIgnoringSafeArea(.bottom)
                                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: -5)
                        )
                    }
                }
            )
            .navigationTitle("Add Ingredients")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Back") {
                        dismiss()
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
                // Add single scanned ingredient if available
                if let ingredient = scannedIngredient {
                    addIngredientToList(ingredient)
                }
                
                // Add all preloaded ingredients from batch scanning
                for ingredient in preloadedIngredients {
                    addIngredientToList(ingredient)
                }
            }
            .toast(isPresented: $showToast, message: toastMessage)
        }
    }

    // Check if ingredient is already selected
    private func isIngredientSelected(_ ingredient: EdamamIngredientModel) -> Bool {
        return selectedIngredients.contains(where: { $0.foodId == ingredient.foodId })
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

    // Add ingredients to list
    private func addIngredientToList(_ ingredient: Any) {
        let newIngredient: EditableIngredient

        if let edamamIngredient = ingredient as? EdamamIngredientModel {
            newIngredient = EditableIngredient(
                id: UUID(),
                foodId: edamamIngredient.foodId,
                label: edamamIngredient.label,
                category: edamamIngredient.category,
                brand: nil,
                image: edamamIngredient.image,
                quantity: 1
            )
        } else if let barcodeIngredient = ingredient as? BarcodeModel {
            newIngredient = EditableIngredient(
                id: UUID(),
                foodId: barcodeIngredient.foodId,
                label: barcodeIngredient.label,
                category: barcodeIngredient.category,
                brand: barcodeIngredient.brand,
                image: barcodeIngredient.image,
                quantity: 1
            )
        } else {
            print("Error: Unsupported ingredient type")
            return
        }

        if !selectedIngredients.contains(where: { $0.foodId == newIngredient.foodId }) {
            selectedIngredients.append(newIngredient)
            
            if searchText.isEmpty && scannedIngredient == nil && preloadedIngredients.isEmpty {
                toastMessage = "Food Added!"
                showToast = true
            }

            UIApplication.shared.endEditing()
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

        // Show success toast and dismiss instead of navigating (preventing crash)
        toastMessage = "\(selectedIngredients.count) Ingredient\(selectedIngredients.count > 1 ? "s" : "") Added to Pantry"
        showToast = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            dismiss() // Simply dismiss instead of navigating to avoid crash
        }
    }
}

struct QuantitySelectionSheet: View {
    let ingredient: EdamamIngredientModel
    @Binding var quantity: Double
    let onAdd: () -> Void
    let onCancel: () -> Void
    @State private var tempQuantity: String
    @FocusState private var isInputFocused: Bool
    
    init(ingredient: EdamamIngredientModel, quantity: Binding<Double>, onAdd: @escaping () -> Void, onCancel: @escaping () -> Void) {
        self.ingredient = ingredient
        self._quantity = quantity
        self.onAdd = onAdd
        self.onCancel = onCancel
        self._tempQuantity = State(initialValue: String(Int(quantity.wrappedValue)))
    }
    
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Ingredient info at top - more compact
                Text(ingredient.label)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .lineLimit(1)
                    .padding(.top, 10)
                
                // Enter Quantity title
                Text("Enter Quantity")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.top, 5)
                
                // Input field - smaller size
                TextField("", text: $tempQuantity)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.center)
                    .font(.system(size: 36, weight: .bold))
                    .frame(width: 100)
                    .padding(.vertical, 10)
                    .background(Color(.secondarySystemGroupedBackground))
                    .cornerRadius(8)
                    .padding(.top, 5)
                    .focused($isInputFocused)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            isInputFocused = true
                        }
                    }
                
                Spacer(minLength: 0)
            }
            
            // Top buttons
            VStack {
                HStack {
                    // Cancel button - top left
                    Button("Cancel") {
                        onCancel()
                    }
                    .foregroundColor(.red)
                    .padding(.horizontal)
                    .padding(.top, 10)
                    
                    Spacer()
                    
                    // Done button - top right
                    Button("Done") {
                        saveAndContinue()
                    }
                    .foregroundColor(.blue)
                    .fontWeight(.bold)
                    .padding(.horizontal)
                    .padding(.top, 10)
                }
                Spacer()
            }
        }
        .presentationDetents([.height(150)])
    }
    
    private func saveAndContinue() {
        if let newQuantity = Double(tempQuantity), newQuantity > 0 {
            quantity = newQuantity
        } else {
            // Default to 1 if invalid input
            quantity = 1
        }
        onAdd()
    }
}

// Toast popup notification
extension View {
    func toast(isPresented: Binding<Bool>, message: String, duration: Double = 2.0) -> some View {
        ZStack {
            self
            if isPresented.wrappedValue {
                VStack {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.title2)

                        Text(message)
                            .foregroundColor(.white)
                            .font(.headline)
                            .padding(.leading, 5)
                    }
                    .padding()
                    .background(Color.black.opacity(0.8))
                    .cornerRadius(10)
                    .shadow(radius: 5)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .padding(.top, 50)
                    Spacer()
                }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                        withAnimation {
                            isPresented.wrappedValue = false
                        }
                    }
                }
            }
        }
        .animation(.easeInOut, value: isPresented.wrappedValue)
    }
}

// Close Keyboard Helper
extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// Canvas preview
struct AddIngredientPage_Previews: PreviewProvider {
    static var previews: some View {
        let mockUserSession = UserSession()
        let sampleScannedIngredient = BarcodeModel(
            foodId: "12345",
            label: "Sample Scanned Ingredient",
            brand: "Sample Brand",
            category: "Vegetables",
            image: nil,
            nutrients: nil
        )

        NavigationStack {
            AddIngredientBarcodePage(
                scannedIngredient: sampleScannedIngredient,
                userSession: mockUserSession
            )
            .environmentObject(mockUserSession)
        }
    }
}


