import Foundation

class PantryController: ObservableObject {
    @Published var pantryItems: [String] = []
    @Published var isLoading: Bool = true
    @Published var errorMessage: String? = nil

    private let pantryURL = "https://souschef.click/pantry/user"
    private var userSession: UserSession

    init(userSession: UserSession) {
        self.userSession = userSession
    }

    func fetchPantryItems() {
        guard let url = URL(string: pantryURL) else {
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

                do {
                    let items = try JSONDecoder().decode([PantryItem].self, from: data)
                    self.pantryItems = items.map { $0.ingredient_name }
                } catch {
                    self.errorMessage = "Failed to decode server response: \(error.localizedDescription)"
                }
            }
        }.resume()
    }

    private func handleTokenExpiration() {
        userSession.refreshToken { newToken in
            guard let newToken = newToken else {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to refresh token. Please log in again."
                    self.isLoading = false
                }
                return
            }

            self.fetchPantryItems()
        }
    }
}
