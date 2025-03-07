//
//  IngredientsComponent.swift
//  SousChef
//
//  Created by Sutter Reynolds on 3/5/25.
//

import Foundation
import FirebaseAuth

class AWSIngredientsComponent: AWSAbstract {
    
    init(userSession: UserSession) {
        super.init(userSession: userSession, route: "/ingredients") // Setting route for this component
    }
    
    /// Fetch all ingredients
    func fetchIngredients(completion: @escaping (Result<[AWSIngredientModel], Error>) -> Void) {
        guard let token = userSession.token else {
            completion(.failure(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "User is not authenticated"])))
            return
        }

        var urlComponents = URLComponents(string: baseURL + route + "/all")
        
        guard let url = urlComponents?.url else {
            completion(.failure(NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue((token), forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, let data = data, httpResponse.statusCode == 200 else {
                completion(.failure(NSError(domain: "", code: 500, userInfo: [NSLocalizedDescriptionKey: "Server error"])))
                return
            }

            do {
                let ingredients = try JSONDecoder().decode([AWSIngredientModel].self, from: data)
                completion(.success(ingredients))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    /// Add new ingredients
    func addIngredients(ingredients: [AWSIngredientModel], completion: @escaping (Result<Void, Error>) -> Void) {
        guard let token = userSession.token else {
            completion(.failure(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "User is not authenticated"])))
            return
        }
        
        print(token)

        let urlComponents = URLComponents(string: baseURL + route + "/add")
        
        guard let url = urlComponents?.url else {
            completion(.failure(NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue((token), forHTTPHeaderField: "Authorization")

        let requestBody: [String: Any] = [
            "ingredients": ingredients.map { ingredient in
                [
                    "foodId": ingredient.foodId,
                    "text": ingredient.text,
                    "quantity": ingredient.quantity,
                    "measure": ingredient.measure,
                    "food": ingredient.food,
                    "weight": ingredient.weight,
                    "foodCategory": ingredient.foodCategory
                ]
            }
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: [])
        } catch {
            completion(.failure(NSError(domain: "", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to encode ingredients data"])))
            return
        }

        URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                completion(.failure(NSError(domain: "", code: 500, userInfo: [NSLocalizedDescriptionKey: "Server error"])))
                return
            }

            completion(.success(()))
        }.resume()
    }
}
