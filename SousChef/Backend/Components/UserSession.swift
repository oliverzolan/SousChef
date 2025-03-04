import Foundation
import FirebaseAuth

class UserSession: ObservableObject {
    @Published var token: String?
    @Published var isGuest: Bool = false
    @Published var fullName: String?
    @Published var awsUserId: String?  // AWS user id

    private var authListener: AuthStateDidChangeListenerHandle?

    init() {
        self.token = KeychainHelper.shared.retrieve(for: "authToken")
        self.fullName = KeychainHelper.shared.retrieve(for: "userFullName")
        
        authListener = Auth.auth().addStateDidChangeListener { [weak self] auth, user in
            guard let self = self, let user = user else {
                self?.token = nil
                self?.fullName = nil
                self?.awsUserId = nil
                return
            }
            
            user.getIDTokenForcingRefresh(true) { idToken, error in
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
                    
                    self.fetchAWSUserId { awsUserId in
                        DispatchQueue.main.async {
                            self.awsUserId = awsUserId
                            print("AWS User ID: \(awsUserId ?? "nil")")
                        }
                    }
                }
            }
        }
    }

    func fetchAWSUserId(completion: @escaping (String?) -> Void) {
        guard let token = self.token, let email = self.fullName else {
            print("Token or email not available for fetching AWS user id")
            completion(nil)
            return
        }
        
        guard let url = URL(string: "https://souschef.click/users/create") else {
            print("Invalid URL for AWS user mapping")
            completion(nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue(token, forHTTPHeaderField: "Authorization")
        request.addValue(email, forHTTPHeaderField: "Email")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error fetching AWS user id: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let data = data else {
                print("No data received from AWS user mapping endpoint")
                completion(nil)
                return
            }
            
            // for debugging, print the raw response
            if let rawResponse = String(data: data, encoding: .utf8) {
                print("Raw Response: \(rawResponse)")
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    if let awsUserId = json["user_id"] as? String {
                        completion(awsUserId)
                    } else if let awsUserIdInt = json["user_id"] as? Int {
                        completion(String(awsUserIdInt))
                    } else {
                        print("Failed to parse AWS user id from response: \(json)")
                        completion(nil)
                    }
                } else {
                    completion(nil)
                }
            } catch {
                print("JSON decoding error: \(error.localizedDescription)")
                completion(nil)
            }
        }.resume()
    }

    func updateFullName(_ name: String) {
        self.fullName = name
        KeychainHelper.shared.save(name, for: "userFullName")
    }

    func loginAsGuest() {
        isGuest = true
        fullName = "Guest"
    }

    func logout() {
        KeychainHelper.shared.delete(for: "authToken")
        KeychainHelper.shared.delete(for: "userFullName")
        self.token = nil
        self.fullName = nil
        self.isGuest = false
        self.awsUserId = nil
    }

    func refreshToken(completion: @escaping (String?) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion(nil)
            return
        }
        user.getIDTokenForcingRefresh(true) { [weak self] idToken, error in
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
                
                self?.fetchAWSUserId { awsUserId in
                    DispatchQueue.main.async {
                        self?.awsUserId = awsUserId
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
