import SwiftUI
import FirebaseAuth

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
        // Ensure the user is authenticated
        guard let user = Auth.auth().currentUser else {
            print("User not authenticated")
            return
        }

        // Retrieve the latest Firebase token
        user.getIDTokenForcingRefresh(true) { idToken, error in
            if let error = error {
                print("Failed to retrieve authentication token: \(error.localizedDescription)")
                return
            }

            guard let token = idToken else {
                print("Authentication token is missing")
                return
            }

            // Construct the request URL for adding ingredients
            guard let url = URL(string: "https://souschef.click/ingredients/add") else {
                print("Invalid URL for adding ingredients")
                return
            }
            
            print("DEBUG: Firebase Auth Token -> \(token)")

            // Construct request payload based on backend expectations
            let ingredientPayload: [String: Any] = [
                "foodId": food.foodId,
                "text": food.label,
                "quantity": 1,         // Default quantity = 1
                "measure": "",         // Optional
                "food": food.label,    // Optional
                "weight": 0,
                "foodCategory": food.category ?? ""
            ]

            let payload: [String: Any] = [
                "ingredients": [ingredientPayload]  // No need for user_id; backend gets it from Firebase token
            ]

            do {
                let jsonData = try JSONSerialization.data(withJSONObject: payload, options: [])
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                request.addValue(token, forHTTPHeaderField: "Authorization") // Firebase token for authentication
                request.httpBody = jsonData

                // Perform the request
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
            } catch {
                print("Failed to encode payload: \(error.localizedDescription)")
            }
        }
    }
}
