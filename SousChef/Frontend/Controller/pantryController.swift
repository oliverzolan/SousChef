import Foundation
import FirebaseAuth

class PantryController: ObservableObject {
    @Published var pantryItems: [String] = []
    @Published var fullPantryItems: [Ingredient] = []
    @Published var isLoading: Bool = true
    @Published var errorMessage: String? = nil
    @Published var showAddIngredientPopup: Bool = false
    @Published var quantities: [Int: Int] = [:]
    
    private let basePantryURL = "https://souschef.click/ingredients/all"
    var userSession: UserSession

    init(userSession: UserSession) {
        self.userSession = userSession
    }
        
    // Fetch all ingredients from aws user
    func fetchIngredients() {
        // check for aws id
        guard let userId = userSession.awsUserId else {
            DispatchQueue.main.async {
                self.errorMessage = "AWS User ID not available"
                self.isLoading = false
            }
            return
        }
        let fullURLString = "\(basePantryURL)/\(userId)"
        guard let url = URL(string: fullURLString) else {
            DispatchQueue.main.async {
                self.errorMessage = "Invalid URL"
                self.isLoading = false
            }
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        guard let token = userSession.token else {
            DispatchQueue.main.async {
                self.errorMessage = "User is not authenticated"
                self.isLoading = false
            }
            return
        }
        request.addValue(token, forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
                if let httpResponse = response as? HTTPURLResponse {
                    switch httpResponse.statusCode {
                    case 200:
                        break
                    case 401:
                        self.handleTokenExpiration()
                        return
                    default:
                        self.errorMessage = "Error: Server returned status code \(httpResponse.statusCode)"
                        return
                    }
                }
                if let error = error {
                    self.errorMessage = "Failed to load pantry items: \(error.localizedDescription)"
                    return
                }
                guard let data = data else {
                    self.errorMessage = "No data received from server"
                    return
                }
                // for debugging, prints raw json
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Raw JSON: \(jsonString)")
                }
                do {
                    let items = try JSONDecoder().decode([Ingredient].self, from: data)
                    self.fullPantryItems = items
                    self.pantryItems = items.map { $0.text }
                } catch {
                    self.errorMessage = "Failed to decode server response: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
        
    func increaseQuantity(for ingredientID: Int) {
        quantities[ingredientID, default: 0] += 1
    }
    
    func decreaseQuantity(for ingredientID: Int) {
        let currentQuantity = quantities[ingredientID, default: 0]
        if currentQuantity > 0 {
            quantities[ingredientID] = currentQuantity - 1
        }
    }
    
    func addSelectedIngredientsToPantry(completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "https://souschef.click/pantry/user/add-ingredients") else {
            self.errorMessage = "Invalid URL"
            completion(false)
            return
        }
        
        // Refresh firebase token
        Auth.auth().currentUser?.getIDTokenForcingRefresh(true) { idToken, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to refresh token: \(error.localizedDescription)"
                    completion(false)
                }
                return
            }
            guard let idToken = idToken else {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to retrieve Firebase token"
                    completion(false)
                }
                return
            }
            
            // Change this, no longer need selected
            let selectedIngredients = self.quantities.compactMap { (ingredientID, quantity) -> [String: Any]? in
                guard quantity > 0 else { return nil }
                return ["ingredient_id": ingredientID, "quantity": quantity]
            }
            
            guard !selectedIngredients.isEmpty else {
                DispatchQueue.main.async {
                    self.errorMessage = "No ingredients selected"
                    completion(false)
                }
                return
            }
            
            let payload: [String: Any] = ["ingredients": selectedIngredients]
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue(idToken, forHTTPHeaderField: "Authorization")
            
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: payload, options: [])
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to encode request payload: \(error.localizedDescription)"
                    completion(false)
                }
                return
            }
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                DispatchQueue.main.async {
                    if let error = error {
                        self.errorMessage = "Failed to add ingredients: \(error.localizedDescription)"
                        completion(false)
                        return
                    }
                    guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 else {
                        self.errorMessage = "Failed to add ingredients: Invalid server response"
                        completion(false)
                        return
                    }
                    print("Ingredients successfully added to pantry")
                    completion(true)
                }
            }.resume()
        }
    }
        
    private func handleTokenExpiration() {
        userSession.refreshToken { newToken in
            guard let _ = newToken else {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to refresh token. Please log in again."
                    self.isLoading = false
                }
                return
            }
            self.fetchIngredients()
        }
    }
}
