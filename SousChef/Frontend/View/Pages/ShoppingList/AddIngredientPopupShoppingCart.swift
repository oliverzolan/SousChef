import SwiftUI

struct AddIngredientPopupShoppingCart: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var userSession: UserSession
    @ObservedObject private var viewModel: IngredientController
    @Binding var items: [CartItem]
    var scannedIngredient: BarcodeModel?
    @State private var selectedIngredient: IngredientResult? = nil
    @State private var quantityText: String = ""
    @State private var priceText: String = ""
    
    init(items: Binding<[CartItem]>, scannedIngredient: BarcodeModel?, userSession: UserSession) {
        self._items = items
        self.scannedIngredient = scannedIngredient
        self.viewModel = IngredientController(userSession: userSession)
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if let scanned = scannedIngredient {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Scanned Ingredient:")
                            .font(.headline)
                        Text(scanned.label)
                            .font(.title2)
                            .fontWeight(.bold)
                        if let brand = scanned.brand {
                            Text("Brand: \(brand)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        if let category = scanned.category {
                            Text("Category: \(category)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        Button(action: {
                            let newItem = CartItem(name: scanned.label, price: 0.0, quantity: 1)
                            items.append(newItem)
                            dismiss()
                        }) {
                            Text("Add to Shopping List")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .padding(.top, 10)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(.systemBackground))
                            .shadow(radius: 2)
                    )
                    .padding(.horizontal)
                } else {
                    TextField("Search for ingredient...", text: $viewModel.searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                        .onChange(of: viewModel.searchText) { _, _ in
                            viewModel.performSearch()
                        }
                    
                    if let selected = selectedIngredient {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Selected Ingredient:")
                                .font(.headline)
                            Text(selected.label)
                                .font(.title2)
                                .fontWeight(.bold)
                            if let category = selected.category {
                                Text("Category: \(category)")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            TextField("Quantity", text: $quantityText)
                                .keyboardType(.numberPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            TextField("Price", text: $priceText)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            Button(action: {
                                guard let qty = Int(quantityText),
                                      let pr = Double(priceText) else { return }
                                let newItem = CartItem(name: selected.label, price: pr, quantity: qty)
                                items.append(newItem)
                                dismiss()
                            }) {
                                Text("Add to Shopping List")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(.systemBackground))
                                .shadow(radius: 2)
                        )
                        .padding(.horizontal)
                    } else {
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
                                    selectedIngredient = IngredientResult(foodId: ingredient.foodId, label: ingredient.label, category: ingredient.category)
                                    quantityText = ""
                                    priceText = ""
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
                        }
                    }
                }
                Spacer()
            }
            .navigationTitle("Add Ingredient")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct EditItemPopup: View {
    let item: CartItem
    @Binding var quantity: String
    var onSave: (String) -> Void
    var onDelete: () -> Void

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Edit Quantity")) {
                    Text(item.name)
                        .font(.headline)
                    Text("Price: $\(item.price, specifier: "%.2f")")
                        .foregroundColor(.gray)
                    TextField("Quantity", text: $quantity)
                        .keyboardType(.numberPad)
                }

                Section {
                    Button("Save Changes") {
                        onSave(quantity)
                    }
                    .foregroundColor(.blue)

                    Button("Delete Item", role: .destructive) {
                        onDelete()
                    }
                }
            }
            .navigationTitle("Edit Ingredient")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
