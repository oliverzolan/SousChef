import SwiftUI

struct AddIngredientPopup: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var userSession: UserSession

    private let ingredientsAPI = IngredientsAPI()

    @Binding var ingredients: [String]

    @State private var searchText: String = ""
    @State private var searchResults: [IngredientModel] = []
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

        ingredientsAPI.search(query: query) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let response):
                    // Extract unique ingredients
                    let uniqueIngredients = Array(Set(response.hints.map { $0.food })).sorted { $0.label < $1.label }
                    self.searchResults = uniqueIngredients
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }

    // MARK: - Adding Ingredients
    private func addIngredientToDatabase(_ ingredient: IngredientModel) {
        guard let awsUserId = userSession.awsUserId, let token = userSession.token else {
            print("AWS User ID or token not available")
            return
        }
        
        let ingredientPayload: [String: Any] = [
            "foodId": ingredient.foodId,
            "text": ingredient.label,
            "quantity": 1,
            "measure": "",
            "food": ingredient.label,
            "weight": 0,
            "foodCategory": ingredient.category ?? ""
        ]
        
        let payload: [String: Any] = [
            "user_id": awsUserId,
            "ingredients": [ingredientPayload]
        ]
        
        guard let url = URL(string: "https://souschef.click/ingredients/add") else {
            print("Invalid URL for add ingredients endpoint")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(token, forHTTPHeaderField: "Authorization")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload, options: [])
        } catch {
            print("Failed to encode payload: \(error.localizedDescription)")
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error adding ingredient: \(error.localizedDescription)")
                    return
                }
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("No valid response from server")
                    return
                }
                if httpResponse.statusCode == 200 {
                    print("Ingredient added successfully")
                    self.ingredients.append(ingredient.label)
                    self.presentationMode.wrappedValue.dismiss()
                } else {
                    print("Failed to add ingredient. Server returned status code: \(httpResponse.statusCode)")
                    if let data = data, let errorResponse = String(data: data, encoding: .utf8) {
                        print("Server error response: \(errorResponse)")
                    }
                }
            }
        }.resume()
    }
}
