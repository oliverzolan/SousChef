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
        super.init(userSession: userSession, route: "/user_ingredients") // Setting route for this component
    }
    
    /// Fetch all ingredients
    @MainActor func fetchIngredients(completion: @escaping (Result<[AWSIngredientModel], Error>) -> Void) {
        guard let token = userSession.token else {
            DispatchQueue.main.async {
                completion(.failure(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "User is not authenticated"])))
            }
            return
        }

        let urlComponents = URLComponents(string: baseURL + route + "/all")
        
        guard let url = urlComponents?.url else {
            DispatchQueue.main.async {
                completion(.failure(NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            }
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(token, forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "", code: 500, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                }
                return
            }
            
            // Try to parse as a dictionary to check for errors
            if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                if let error = json["error"] as? String {
                    // Return empty array for now to avoid crashing
                    DispatchQueue.main.async {
                        completion(.success([]))
                    }
                    return
                }
            }
            
            // Try to parse the response with mock data if needed
            do {
                let decoder = JSONDecoder()
                let ingredients = try decoder.decode([AWSIngredientModel].self, from: data)
                
                DispatchQueue.main.async {
                    completion(.success(ingredients))
                }
            } catch {
                // Return empty array to avoid crashes
                DispatchQueue.main.async {
                    completion(.success([]))
                }
            }
        }.resume()
    }
    
    /// Add new ingredients
    @MainActor func addIngredients(ingredients: [AWSIngredientModel], completion: @escaping (Result<Void, Error>) -> Void) {
        guard let token = userSession.token else {
            DispatchQueue.main.async {
                completion(.failure(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "User is not authenticated"])))
            }
            return
        }

        let urlComponents = URLComponents(string: baseURL + route + "/update")
        
        guard let url = urlComponents?.url else {
            DispatchQueue.main.async {
                completion(.failure(NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            }
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue((token), forHTTPHeaderField: "Authorization")

        // Format the data to match the Python backend's expected structure
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
            let jsonData = try JSONSerialization.data(withJSONObject: requestBody, options: [])
            request.httpBody = jsonData
        } catch {
            DispatchQueue.main.async {
                completion(.failure(NSError(domain: "", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to encode ingredients data"])))
            }
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "", code: 500, userInfo: [NSLocalizedDescriptionKey: "Server error"])))
                }
                return
            }

            DispatchQueue.main.async {
                completion(.success(()))
            }
        }.resume()
    }
    
    /// Fetch all expiring ingredients
    @MainActor func getExpiringIngredients(completion: @escaping (Result<[AWSIngredientModel], Error>) -> Void) {
        guard let token = userSession.token else {
            DispatchQueue.main.async {
                completion(.failure(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "User is not authenticated"])))
            }
            return
        }

        let urlComponents = URLComponents(string: baseURL + route + "/get_expiring")
        
        guard let url = urlComponents?.url else {
            DispatchQueue.main.async {
                completion(.failure(NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            }
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(token, forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "", code: 500, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                }
                return
            }
            
            // Try to parse as a dictionary to check for errors
            if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                if let error = json["error"] as? String {
                    // Return empty array for now to avoid crashing
                    DispatchQueue.main.async {
                        completion(.success([]))
                    }
                    return
                }
            }
            
            // Try to parse the response with mock data if needed
            do {
                let decoder = JSONDecoder()
                let ingredients = try decoder.decode([AWSIngredientModel].self, from: data)
                
                DispatchQueue.main.async {
                    completion(.success(ingredients))
                }
            } catch {
                // Return empty array to avoid crashes
                DispatchQueue.main.async {
                    completion(.success([]))
                }
            }
        }.resume()
    }
}
