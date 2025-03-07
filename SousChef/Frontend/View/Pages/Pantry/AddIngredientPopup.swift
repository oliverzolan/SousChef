import SwiftUI

struct AddIngredientPopup: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var userSession: UserSession

    private let ingredientsAPI = EdamamIngredientsComponent()

    @Binding var ingredients: [String]

    @State private var searchText: String = ""
    @State private var searchResults: [EdamamIngredientModel] = []
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationView {
            VStack {
                TextField("Search for ingredient...", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .onChange(of: searchText) { newValue in
                        performSearch(query: newValue)
                    }

                if isLoading {
                    ProgressView("Searching...")
                        .padding()
                } else if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                } else {
                    List(searchResults, id: \.foodId) { ingredient in
                        Button {
                            addIngredientToDatabase(ingredient)
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
                Spacer()
            }
            .navigationTitle("Add Ingredient")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }

    // MARK: - Search Logic
    private func performSearch(query: String) {
        guard !query.isEmpty else {
            searchResults = []
            return
        }
        isLoading = true
        errorMessage = nil

        ingredientsAPI.searchIngredients(query: query) { result in
            print(result)
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let response):
                    let uniqueIngredients = Array(Set(response.hints.map { $0.food })).sorted { $0.label < $1.label }
                    self.searchResults = uniqueIngredients
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }

    private func addIngredientToDatabase(_ ingredient: EdamamIngredientModel) {
        guard let token = userSession.token else {
            print("User token not available")
            return
        }

        let awsIngredient = AWSIngredientModel(
            food: ingredient.label,
            foodCategory: ingredient.category ?? "Unknown",
            foodId: ingredient.foodId,
            measure: ingredient.nutrients != nil ? "Serving" : "",
            quantity: 1,
            text: ingredient.label,
            weight: ingredient.nutrients?.energy ?? 0
        )

        let ingredients = [awsIngredient]

        let ingredientsAPI = AWSIngredientsComponent(userSession: userSession)

        ingredientsAPI.addIngredients(ingredients: ingredients) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    print("Ingredient added successfully")
                    self.ingredients.append(awsIngredient.text)
                    self.presentationMode.wrappedValue.dismiss()
                case .failure(let error):
                    print("Failed to add ingredient: \(error.localizedDescription)")
                }
            }
        }
    }
}

struct AddIngredientPopup_Previews: PreviewProvider {
    static var previews: some View {
        // Create a mock user session
        let mockSession = UserSession()
        mockSession.token = "mock_token"

        @State var mockIngredients: [String] = ["Tomato", "Onion", "Garlic"]

        return AddIngredientPopup(ingredients: $mockIngredients)
            .environmentObject(mockSession)
            .previewDevice("iPhone 16 Pro")
    }
}
