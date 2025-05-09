//
//  IngredientsComponent.swift
//  SousChef
//
//  Created by Oliver Zolan on 3/5/25.
//

import Foundation
import FirebaseAuth

class AWSUserIngredientsComponent: AWSAbstract {
    
    init(userSession: UserSession) {
        super.init(userSession: userSession, route: "/user_ingredients")
    }
    
    /// Fetch all ingredients
    @MainActor
    func fetchIngredients(completion: @escaping (Result<[AWSIngredientModel], Error>) -> Void) {
        guard let token = userSession.token else {
            completion(.failure(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "User is not authenticated"])))
            return
        }

        let urlComponents = URLComponents(string: baseURL + route + "/all")
        guard let url = urlComponents?.url else {
            completion(.failure(NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(token, forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "", code: 500, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }

            if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let _ = json["error"] as? String {
                completion(.success([]))
                return
            }

            do {
                let decoder = JSONDecoder()
                let ingredients = try decoder.decode([AWSIngredientModel].self, from: data)
                completion(.success(ingredients))
            } catch {
                completion(.success([]))
            }
        }.resume()
    }

    /// Add new ingredients
    @MainActor
    func addIngredients(ingredients: [AWSIngredientModel], completion: @escaping (Result<Void, Error>) -> Void) {
        guard let token = userSession.token else {
            completion(.failure(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "User is not authenticated"])))
            return
        }

        let urlComponents = URLComponents(string: baseURL + route + "/update")
        guard let url = urlComponents?.url else {
            completion(.failure(NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(token, forHTTPHeaderField: "Authorization")

        let requestBody: [String: Any] = [
            "ingredients": ingredients.map { ingredient in
                var quantity = 1
                if let quantityNum = Int(ingredient.quantityType) {
                    quantity = quantityNum
                }
                return [
                    "edamam_food_id": ingredient.edamamFoodId,
                    "quantity": quantity
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

    /// Delete a specific ingredient (quantity = 0)
    @MainActor
    func deleteIngredient(ingredient: AWSIngredientModel, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let token = userSession.token else {
            completion(.failure(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "User is not authenticated"])))
            return
        }

        let urlComponents = URLComponents(string: baseURL + route + "/update")
        guard let url = urlComponents?.url else {
            completion(.failure(NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(token, forHTTPHeaderField: "Authorization")

        let requestBody: [String: Any] = [
            "ingredients": [
                [
                    "edamam_food_id": ingredient.edamamFoodId,
                    "quantity": 0
                ]
            ]
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: [])
        } catch {
            completion(.failure(NSError(domain: "", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to encode ingredient data"])))
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            if let data = data,
               let responseBody = String(data: data, encoding: .utf8) {
                print("🔁 Server Response Body: \(responseBody)")
            }

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                completion(.failure(NSError(domain: "", code: 500, userInfo: [NSLocalizedDescriptionKey: "Server error"])))
                return
            }

            completion(.success(()))
        }.resume()
    }

    /// Fetch ingredients that are expiring
    @MainActor
    func getExpiringIngredients(completion: @escaping (Result<[AWSIngredientModel], Error>) -> Void) {
        guard let token = userSession.token else {
            completion(.failure(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "User is not authenticated"])))
            return
        }

        let urlComponents = URLComponents(string: baseURL + route + "/get_expiring")
        guard let url = urlComponents?.url else {
            completion(.failure(NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(token, forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "", code: 500, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }

            if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let _ = json["error"] as? String {
                completion(.success([]))
                return
            }

            do {
                let decoder = JSONDecoder()
                let ingredients = try decoder.decode([AWSIngredientModel].self, from: data)
                completion(.success(ingredients))
            } catch {
                completion(.success([]))
            }
        }.resume()
    }
}
