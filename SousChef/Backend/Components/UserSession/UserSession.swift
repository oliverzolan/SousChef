import Foundation
import FirebaseAuth
import Combine

class UserSession: ObservableObject {
    @Published var token: String?
    @Published var isGuest: Bool = false
    @Published var fullName: String?
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
        self.token = KeychainHelper.shared.retrieve(for: "authToken")
        self.fullName = KeychainHelper.shared.retrieve(for: "userFullName")
        loadShoppingLists()
        subscribeToShoppingLists()
        loadCart()
        subscribeToCart()
        
        authListener = Auth.auth().addStateDidChangeListener { [weak self] auth, user in
            guard let self = self else { return }
            guard let user = user else {
                DispatchQueue.main.async {
                    self.token = nil
                    self.fullName = nil
                }
                return
            }
            
            user.getIDTokenForcingRefresh(true) { idToken, error in
                DispatchQueue.main.async {
                    if let error = error {
                        print("Error refreshing token: \(error.localizedDescription)")
                        self.token = nil
                        self.fullName = nil
                    } else if let idToken = idToken {
                        self.token = idToken
                        KeychainHelper.shared.save(idToken, for: "authToken")
                        if let displayName = user.displayName {
                            self.fullName = displayName
                            KeychainHelper.shared.save(displayName, for: "userFullName")
                        }
                    }
                }
            }
        }
    }
    
    private func subscribeToShoppingLists() {
        shoppingListCancellables.removeAll()
        for list in shoppingLists {
            list.objectWillChange
                .sink { [weak self] _ in
                    self?.saveShoppingLists()
                }
                .store(in: &shoppingListCancellables)
        }
    }
    
    private func subscribeToCart() {
        cartCancellables.removeAll()
        cart.objectWillChange
            .sink { [weak self] _ in
                self?.saveCart()
            }
            .store(in: &cartCancellables)
    }
    
    func saveShoppingLists() {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(shoppingLists)
            UserDefaults.standard.set(data, forKey: shoppingListsKey)
            print("Saved shopping lists: \(shoppingLists)")
        } catch {
            print("Error saving shopping lists: \(error)")
        }
    }
    
    func loadShoppingLists() {
        let decoder = JSONDecoder()
        if let data = UserDefaults.standard.data(forKey: shoppingListsKey),
           let lists = try? decoder.decode([ShoppingList].self, from: data) {
            self.shoppingLists = lists
            print("Loaded shopping lists: \(lists)")
        } else {
            print("No shopping lists found in UserDefaults")
        }
    }
    
    func saveCart() {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(cart)
            UserDefaults.standard.set(data, forKey: cartKey)
            print("Saved cart: \(cart)")
        } catch {
            print("Error saving cart: \(error)")
        }
    }
    
    func loadCart() {
        let decoder = JSONDecoder()
        if let data = UserDefaults.standard.data(forKey: cartKey),
           let loadedCart = try? decoder.decode(ShoppingCart.self, from: data) {
            self.cart = loadedCart
            print("Loaded cart: \(loadedCart)")
        } else {
            print("No cart found in UserDefaults")
        }
    }
    
    func updateFullName(_ name: String) {
        DispatchQueue.main.async {
            self.fullName = name
            KeychainHelper.shared.save(name, for: "userFullName")
        }
    }
    
    func loginAsGuest() {
        DispatchQueue.main.async {
            self.isGuest = true
            self.fullName = "Guest"
        }
    }
    
    func logout() {
        KeychainHelper.shared.delete(for: "authToken")
        KeychainHelper.shared.delete(for: "userFullName")
        DispatchQueue.main.async {
            self.token = nil
            self.fullName = nil
            self.isGuest = false
        }
    }
    
    func refreshToken(completion: @escaping (String?) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion(nil)
            return
        }
        user.getIDTokenForcingRefresh(true) { [weak self] idToken, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error refreshing token: \(error.localizedDescription)")
                    self?.token = nil
                    completion(nil)
                } else if let idToken = idToken {
                    self?.token = idToken
                    KeychainHelper.shared.save(idToken, for: "authToken")
                    completion(idToken)
                    if let displayName = user.displayName {
                        self?.fullName = displayName
                        KeychainHelper.shared.save(displayName, for: "userFullName")
                    }
                }
            }
        }
    }
    
    deinit {
        if let authListener = authListener {
            Auth.auth().removeStateDidChangeListener(authListener)
        }
    }
}
