import SwiftUI

struct AddIngredientPopup: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var userSession: UserSession
    @ObservedObject private var viewModel: IngredientController

    @Binding var ingredients: [String]
    var scannedIngredient: BarcodeModel?

    init(ingredients: Binding<[String]>, scannedIngredient: BarcodeModel?, userSession: UserSession) {
        self._ingredients = ingredients
        self.scannedIngredient = scannedIngredient
        self.viewModel = IngredientController(userSession: userSession)
    }

    var body: some View {
        NavigationView {
            VStack {
                if scannedIngredient == nil {
                    TextField("Search for ingredient...", text: $viewModel.searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                        .onChange(of: viewModel.searchText) { newValue, _ in
                            viewModel.performSearch()
                        }
                }

                if let ingredient = scannedIngredient {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Scanned Ingredient:")
                            .font(.headline)

                        Text(ingredient.label)
                            .font(.title2)
                            .fontWeight(.bold)

                        if let brand = ingredient.brand {
                            Text("Brand: \(brand)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }

                        if let category = ingredient.category {
                            Text("Category: \(category)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }

                        Button(action: {
                            viewModel.addScannedIngredientToDatabase(ingredient) {
                                dismiss()
                            }
                        }) {
                            Text("Add to Pantry")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .padding(.top, 10)
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemBackground)).shadow(radius: 2))
                    .padding(.horizontal)
                }

                if scannedIngredient == nil {
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
                                viewModel.addIngredientToDatabase(ingredient) {
                                    dismiss()
                                }
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

