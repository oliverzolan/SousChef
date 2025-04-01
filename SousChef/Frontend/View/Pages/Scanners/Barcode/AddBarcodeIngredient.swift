//
//  AddBarcodeIngredient.swift
//  SousChef
//
//  Created by Oliver Zolan on 3/13/25.
//

import SwiftUI

struct AddIngredientBarcodePage: View {
    @EnvironmentObject var userSession: UserSession
    @ObservedObject private var viewModel: IngredientController
    @Environment(\.dismiss) private var dismiss

    @State private var searchText: String = ""
    @State private var isSearching: Bool = false
    @State private var selectedIngredients: [EditableIngredient] = []
    @State private var showToast: Bool = false
    @State private var toastMessage: String = ""

    var scannedIngredient: BarcodeModel?

    init(scannedIngredient: BarcodeModel?, userSession: UserSession) {
        self.scannedIngredient = scannedIngredient
        self.viewModel = IngredientController(userSession: userSession)
    }

    var body: some View {
        NavigationStack {
            VStack {
                TextField("Search for ingredient...", text: $searchText, onEditingChanged: { editing in
                    isSearching = editing
                })
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .onChange(of: searchText) { newValue, _ in
                    viewModel.searchText = newValue
                    viewModel.performSearch()
                }

                ScrollViewReader { proxy in
                    ScrollView {
                        VStack {
                            if isSearching || !searchText.isEmpty {
                                if viewModel.isLoading {
                                    ProgressView("Searching...")
                                        .padding()
                                } else if let errorMessage = viewModel.errorMessage {
                                    Text(errorMessage)
                                        .foregroundColor(.red)
                                        .padding()
                                } else {
                                    List(viewModel.searchResults, id: \.foodId) { ingredient in
                                        Button {
                                            addIngredientToList(ingredient)
                                        } label: {
                                            VStack(alignment: .leading) {
                                                Text(ingredient.label)
                                                    .font(.headline)
                                                if let category = ingredient.category {
                                                    Text(category)
                                                        .font(.subheadline)
                                                        .foregroundColor(.secondary)
                                                }
                                            }
                                        }
                                    }
                                    .frame(height: 250)
                                }
                            }

                            Spacer().frame(height: isSearching ? 0 : 10)

                            if !selectedIngredients.isEmpty {
                                Text("Selected Ingredients:")
                                    .font(.headline)
                                    .padding(.top)

                                List {
                                    ForEach($selectedIngredients) { $ingredient in
                                        HStack {
                                            VStack(alignment: .leading) {
                                                Text(ingredient.label)
                                                    .font(.headline)
                                                Text("Quantity: \(ingredient.quantity, specifier: "%.1f")")
                                                    .font(.subheadline)
                                                    .foregroundColor(.gray)
                                            }

                                            Spacer()

                                            Stepper("", value: $ingredient.quantity, in: 1...100, step: 1)

                                            Button(action: {
                                                removeIngredientFromList(ingredient)
                                            }) {
                                                Image(systemName: "trash")
                                                    .foregroundColor(.red)
                                            }
                                        }
                                    }
                                }
                                .frame(height: isSearching ? 150 : 250)
                            }
                        }
                    }
                }

                // Submit ingredients
                if !selectedIngredients.isEmpty {
                    Button(action: submitIngredientsFromList) {
                        Text("Add Ingredients to Pantry")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding()
                }
            }
            .padding()
            .navigationTitle("Add Ingredient")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Back") {
                        dismissAndRestartScanner()
                    }
                }
            }
            .onAppear {
                if let ingredient = scannedIngredient {
                    addIngredientToList(ingredient)
                }
            }
            .onDisappear {
                dismissAndRestartScanner()
            }
            .toast(isPresented: $showToast, message: toastMessage)
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
                    quantity: 1
                )
            } else if let barcodeIngredient = ingredient as? BarcodeModel {
                newIngredient = EditableIngredient(
                    id: UUID(),
                    foodId: barcodeIngredient.foodId,
                    label: barcodeIngredient.label,
                    quantity: 1
                )
            } else {
                print("Error: Unsupported ingredient type")
                return
            }

            if !selectedIngredients.contains(where: { $0.foodId == newIngredient.foodId }) {
                selectedIngredients.append(newIngredient)
                
                toastMessage = "Food Added!"
                showToast = true

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
                brand: nil,
                category: nil,
                image: nil,
                nutrients: nil
            )
            viewModel.addIngredientToDatabase(barcodeModel) {
                print("Added \(ingredient.label) to pantry.")
            }
        }

        // Clear the list and restart scanner
        selectedIngredients.removeAll()
        dismissAndRestartScanner()
    }

    private func dismissAndRestartScanner() {
        DispatchQueue.main.async {
            if let rootVC = UIApplication.shared.windows.first?.rootViewController {
                rootVC.dismiss(animated: true) {
                    NotificationCenter.default.post(name: NSNotification.Name("RestartScanner"), object: nil)
                }
            }
        }
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
