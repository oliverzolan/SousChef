//
//  FatSecretAuth.swift
//  SousChef
//
//  Created by Oliver Zolan on 3/8/25.
//

import Foundation

class FatSecretAuth {
    static let shared = FatSecretAuth()

    private let clientID = "f56e3449dcef4268a5285d8ce7c55c8d"
    private let clientSecret = "e11753c2eeed45aa9a0a1caf5d80522b"
    
    func fetchAccessToken(completion: @escaping (String?) -> Void) {
        let url = URL(string: "https://oauth.fatsecret.com/connect/token")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let credentials = "\(clientID):\(clientSecret)"
        guard let encodedCredentials = credentials.data(using: .utf8)?.base64EncodedString() else {
            print("Error: Failed to encode credentials")
            completion(nil)
            return
        }

        request.setValue("Basic \(encodedCredentials)", forHTTPHeaderField: "Authorization")
        let bodyString = "grant_type=client_credentials"
        request.httpBody = bodyString.data(using: .utf8)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error fetching token: \(error.localizedDescription)")
                completion(nil)
                return
            }

            if let rawResponse = String(data: data ?? Data(), encoding: .utf8) {
                print("Raw FatSecret Auth Response: \(rawResponse)")
            }

            do {
                let jsonResponse = try JSONSerialization.jsonObject(with: data ?? Data(), options: []) as? [String: Any]
                let accessToken = jsonResponse?["access_token"] as? String
                completion(accessToken)
            } catch {
                print("Failed to decode token response: \(error)")
                completion(nil)
            }
        }.resume()
    }
}
