//
//  IngredientApiComponent.swift
//  SousChef
//
//  Created by Oliver Zolan on 3/3/25.
//

import Foundation

class EdamamIngredientsComponent: EdamamAbstract {
    private let INGREDIENTS_ENDPOINT: String

    override init(appId: String = "d76328ea", appKey: String = "011912e96073eeb8e2088ecb41b78676") {
        self.INGREDIENTS_ENDPOINT = "/api/food-database/v2/parser"
        super.init(appId: appId, appKey: appKey)
    }
    
    func searchIngredients(query: String, completion: @escaping (Result<EdamamIngredientResponse, Error>) -> Void) {
        // Ensure query is not empty and properly formatted
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else {
            completion(.failure(NSError(domain: "Empty Query", code: 0, userInfo: nil)))
            return
        }
        
        // Use percentEncoding for proper URL encoding
        guard let encodedQuery = trimmedQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            completion(.failure(NSError(domain: "Invalid Query", code: 0, userInfo: nil)))
            return
        }
        
        // Log the actual query being sent for debugging
        print("Searching for term: '\(trimmedQuery)'")
        
        var urlComponents = URLComponents(string: baseURL + INGREDIENTS_ENDPOINT)
        urlComponents?.queryItems = [
            URLQueryItem(name: "app_id", value: appId),
            URLQueryItem(name: "app_key", value: appKey),
            URLQueryItem(name: "ingr", value: encodedQuery),
            URLQueryItem(name: "category", value: "generic-foods"),
            URLQueryItem(name: "categoryLabel", value: "food"),
            URLQueryItem(name: "pageSize", value: "50")  // Request more results
        ]
        
        guard let url = urlComponents?.url else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }
        
        print("Search URL: \(url.absoluteString)")
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "No Data", code: 0, userInfo: nil)))
                }
                return
            }
            
            do {
                // Print the raw JSON for debugging purposes
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Raw JSON response: \(jsonString.prefix(200))...") // Log first 200 chars for debugging
                }
                
                let decodedResponse = try JSONDecoder().decode(EdamamIngredientResponse.self, from: data)
                DispatchQueue.main.async { completion(.success(decodedResponse)) }
            } catch {
                print("JSON Decoding Error: \(error)")
                DispatchQueue.main.async { completion(.failure(error)) }
            }
        }.resume()
    }
}

