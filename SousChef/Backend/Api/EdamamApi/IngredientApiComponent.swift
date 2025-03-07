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
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            completion(.failure(NSError(domain: "Invalid Query", code: 0, userInfo: nil)))
            return
        }
        
        var urlComponents = URLComponents(string: baseURL + INGREDIENTS_ENDPOINT)
        urlComponents?.queryItems = [
            URLQueryItem(name: "app_id", value: appId),
            URLQueryItem(name: "app_key", value: appKey),
            URLQueryItem(name: "ingr", value: encodedQuery)
        ]
        
        guard let url = urlComponents?.url else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }
        
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
                let decodedResponse = try JSONDecoder().decode(EdamamIngredientResponse.self, from: data)
                DispatchQueue.main.async { completion(.success(decodedResponse)) }
            } catch {
                DispatchQueue.main.async { completion(.failure(error)) }
            }
        }.resume()
    }
}

