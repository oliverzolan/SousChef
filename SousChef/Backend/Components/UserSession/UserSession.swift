import Foundation
import FirebaseAuth
import Combine

@MainActor
class UserSession: ObservableObject {
    static weak var shared: UserSession?
    @Published var token: String?
    @Published var fullName: String?
    @Published var isSignedIn: Bool = false
    @Published var isAuthResolved: Bool = false
    @Published var deviceToken: String? {
            didSet {
                registerDeviceTokenIfNeeded()
            }
        }

    @Published var shoppingLists: [ShoppingList] = [] {
        didSet {
            saveShoppingLists()
            subscribeToShoppingLists()
            saveCart()
            subscribeToCart()
        }
    }

    @Published var cart = ShoppingCart() {
        didSet {
            saveCart()
            subscribeToCart()
        }
    }

    private let shoppingListsKey = "shoppingListsKey"
    private let cartKey = "cartKey"
    private var authListener: AuthStateDidChangeListenerHandle?
    private var shoppingListCancellables = Set<AnyCancellable>()
    private var cartCancellables = Set<AnyCancellable>()

    init() {
        isSignedIn = false
        isAuthResolved = false

        token = KeychainHelper.shared.retrieve(for: "authToken")
        fullName = KeychainHelper.shared.retrieve(for: "userFullName")

        loadShoppingLists()
        subscribeToShoppingLists()
        loadCart()
        subscribeToCart()

        // Firebase listener
        authListener = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor in
                guard let self = self else { return }

                if let user = user {
                    self.handleAuthenticatedUser(user)
                } else {
                    self.clearSession()
                    self.isSignedIn = false
                }

                self.isAuthResolved = true
            }
        }
    }

    private func handleAuthenticatedUser(_ user: User) {
        user.getIDTokenForcingRefresh(false) { [weak self] idToken, error in
            guard let self = self else { return }

            DispatchQueue.main.async {
                if let error = error {
                    print("Token fetch error: \(error.localizedDescription)")
                    self.clearSession()
                    self.isSignedIn = false
                    return
                }

                guard let idToken = idToken else {
                    self.clearSession()
                    self.isSignedIn = false
                    return
                }

                self.token = idToken
                KeychainHelper.shared.save(idToken, for: "authToken")

                let name = user.displayName ?? "SousChef"
                self.fullName = name
                KeychainHelper.shared.save(name, for: "userFullName")
                self.isSignedIn = true
                
                self.registerDeviceTokenIfNeeded()
            }
        }
    }
    
    private func registerDeviceTokenIfNeeded() {
        guard let token = token, let deviceToken = deviceToken else { return }

        var request = URLRequest(url: URL(string: "https://your.api.domain/create")!)
        request.httpMethod = "POST"
        request.setValue(token, forHTTPHeaderField: "Authorization")
        request.setValue(fullName ?? "SousChef", forHTTPHeaderField: "Email")
        request.setValue(deviceToken, forHTTPHeaderField: "Device-Token")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Device token registration error: \(error.localizedDescription)")
                return
            }

            if let response = response as? HTTPURLResponse {
                print("Device token registered: HTTP \(response.statusCode)")
            }
        }.resume()
    }

    func loginAsGuest() {
        DispatchQueue.main.async {
            self.token = nil
            self.fullName = "Guest"
            self.isSignedIn = false // Still considered "not signed in"
        }
    }

    func logout() {
        do {
            try Auth.auth().signOut()
        } catch {
            print("Sign-out error: \(error)")
        }
        clearSession()
        isSignedIn = false
    }

    private func clearSession() {
        token = nil
        fullName = nil
        KeychainHelper.shared.delete(for: "authToken")
        KeychainHelper.shared.delete(for: "userFullName")
    }

    func refreshToken(completion: @escaping (String?) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion(nil)
            return
        }

        user.getIDTokenForcingRefresh(true) { [weak self] idToken, error in
            DispatchQueue.main.async {
                guard let self = self else { return }

                if let error = error {
                    print("Token refresh error: \(error.localizedDescription)")
                    self.token = nil
                    self.isSignedIn = false
                    completion(nil)
                } else if let idToken = idToken {
                    self.token = idToken
                    KeychainHelper.shared.save(idToken, for: "authToken")
                    self.isSignedIn = true
                    completion(idToken)

                    if let name = user.displayName {
                        self.fullName = name
                        KeychainHelper.shared.save(name, for: "userFullName")
                    }
                    
                    self.registerDeviceTokenIfNeeded()
                }
            }
        }
    }

    func updateFullName(_ name: String) {
        let displayName = name.isEmpty ? "SousChef" : name
        self.fullName = displayName
        KeychainHelper.shared.save(displayName, for: "userFullName")
    }

    // MARK: - Persistence

    private func saveShoppingLists() {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(shoppingLists)
            UserDefaults.standard.set(data, forKey: shoppingListsKey)
        } catch {
            print("Failed to save shopping lists: \(error)")
        }
    }

    private func loadShoppingLists() {
        let decoder = JSONDecoder()
        if let data = UserDefaults.standard.data(forKey: shoppingListsKey),
           let lists = try? decoder.decode([ShoppingList].self, from: data) {
            self.shoppingLists = lists
        }
    }

    private func saveCart() {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(cart)
            UserDefaults.standard.set(data, forKey: cartKey)
        } catch {
            print("Failed to save cart: \(error)")
        }
    }

    private func loadCart() {
        let decoder = JSONDecoder()
        if let data = UserDefaults.standard.data(forKey: cartKey),
           let loadedCart = try? decoder.decode(ShoppingCart.self, from: data) {
            self.cart = loadedCart
        }
    }

    private func subscribeToShoppingLists() {
        shoppingListCancellables.removeAll()
        for list in shoppingLists {
            list.objectWillChange
                .sink { [weak self] _ in self?.saveShoppingLists() }
                .store(in: &shoppingListCancellables)
        }
    }

    private func subscribeToCart() {
        cartCancellables.removeAll()
        cart.objectWillChange
            .sink { [weak self] _ in self?.saveCart() }
            .store(in: &cartCancellables)
    }

    deinit {
        if let authListener = authListener {
            Auth.auth().removeStateDidChangeListener(authListener)
        }
    }
}
