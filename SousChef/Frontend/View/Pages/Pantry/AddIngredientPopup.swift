import SwiftUI

struct AddIngredientPopup: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var userSession: UserSession

    private let foodDatabaseAPI = FoodDatabaseAPI()

    @Binding var ingredients: [String]

    @State private var searchText: String = ""
    @State private var searchResults: [FoodModel] = []
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

                // Loading, error, or results
                if isLoading {
                    ProgressView("Searching...")
                        .padding()
                } else if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                } else {
                    List(searchResults) { food in
                        Button {
                            addIngredientToDatabase(food)
                        } label: {
                            VStack(alignment: .leading) {
                                Text(food.label)
                                    .font(.headline)
                                if let category = food.category {
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


    // Search helper
    private func performSearch(query: String) {
        guard !query.isEmpty else {
            searchResults = []
            return
        }
        isLoading = true
        errorMessage = nil

        foodDatabaseAPI.searchFoods(query: query) { result in
            isLoading = false
            switch result {
            case .success(let foods):
                // Filter duplicates by foodId
                let uniqueFoods = foods.reduce(into: [FoodModel]()) { result, food in
                    if !result.contains(where: { $0.foodId == food.foodId }) {
                        result.append(food)
                    }
                }
                self.searchResults = uniqueFoods
            case .failure(let error):
                self.errorMessage = error.localizedDescription
            }
        }
    }

    private func addIngredientToDatabase(_ food: FoodModel) {
        guard let awsUserId = userSession.awsUserId, let token = userSession.token else {
            print("AWS User ID or token not available")
            return
        }
        
        let ingredientPayload: [String: Any] = [
            "foodId": food.foodId,
            "text": food.label,
            "quantity": 1,         // Default quantity = 1
            "measure": "",         // optional
            "food": food.label,    // optional
            "weight": 0,
            "foodCategory": food.category ?? ""
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
                    self.ingredients.append(food.label)
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
