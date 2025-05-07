//
//  Untitled.swift
//  SousChef
//
//  Created by Bennet Rau on 4/23/25.
//


import Foundation
import FirebaseAuth

class AWSInternalIngredientsComponent: AWSAbstract {
    init(userSession: UserSession) {
        super.init(userSession: userSession, route: "/internal_ingredients") // Setting route for this component
    }

    // Search ingredients by name
    @MainActor func searchIngredients(query: String, limit: Int = 50, completion: @escaping (Result<[AWSIngredientModel], Error>) -> Void) {
        var urlComponents = URLComponents(string: baseURL + route + "/search")
        urlComponents?.queryItems = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "limit", value: String(limit))
        ]
        
        guard let url = urlComponents?.url else {
            completion(.failure(NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Add authorization header if token is available
        if let token = userSession.token, !token.isEmpty {
            request.addValue(token, forHTTPHeaderField: "Authorization")
        }
        
        print("Requesting URL: \(url.absoluteString)")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Network error: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])))
                return
            }
            
            print("Response status code: \(httpResponse.statusCode)")
            
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            // Check for error status code
            guard (200...299).contains(httpResponse.statusCode) else {
                // Try to parse error message if available
                if let errorResponse = try? JSONDecoder().decode([String: String].self, from: data),
                   let errorMessage = errorResponse["message"] {
                    completion(.failure(NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMessage])))
                } else {
                    completion(.failure(NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Server error with status code: \(httpResponse.statusCode)"])))
                }
                return
            }
            
            // Handle empty response (valid but empty)
            if data.isEmpty || data.count == 2 {
                completion(.success([]))
                return
            }
            
            do {
                let ingredients = try JSONDecoder().decode([AWSIngredientModel].self, from: data)
                completion(.success(ingredients))
            } catch {
                print("Decoding error: \(error.localizedDescription)")
                
                // Attempt to decode single object if array decoding fails
                do {
                    let singleIngredient = try JSONDecoder().decode(AWSIngredientModel.self, from: data)
                    completion(.success([singleIngredient]))
                } catch {
                    print("Single object decoding also failed: \(error)")
                    completion(.failure(error))
                }
            }
        }.resume()
    }
    
    @MainActor func getIngredientNutrtion(id: String, completion: @escaping (Result<[AWSIngredientModel], Error>) -> Void) {
        var urlComponents = URLComponents(string: baseURL + route + "/get_nutirtion_by_id")
        urlComponents?.queryItems = [
            URLQueryItem(name: "edamam_food_id", value: id),
        ]
        
        guard let url = urlComponents?.url else {
            completion(.failure(NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Add authorization header if token is available
        if let token = userSession.token, !token.isEmpty {
            request.addValue(token, forHTTPHeaderField: "Authorization")
        }
        
        print("Requesting URL: \(url.absoluteString)")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Network error: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])))
                return
            }
            
            print("Response status code: \(httpResponse.statusCode)")
            
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            // Debug: Print the raw response data
            if let responseString = String(data: data, encoding: .utf8) {
                print("Raw response: \(responseString)")
            }
            
            // Check for error status code
            guard (200...299).contains(httpResponse.statusCode) else {
                // Try to parse error message if available
                if let errorResponse = try? JSONDecoder().decode([String: String].self, from: data),
                   let errorMessage = errorResponse["message"] {
                    completion(.failure(NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMessage])))
                } else {
                    completion(.failure(NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Server error with status code: \(httpResponse.statusCode)"])))
                }
                return
            }
            
            // Handle empty response (valid but empty)
            if data.isEmpty || data.count == 2 {
                completion(.success([]))
                return
            }
            
            do {
                let ingredients = try JSONDecoder().decode([AWSIngredientModel].self, from: data)
                completion(.success(ingredients))
            } catch {
                print("Decoding error: \(error.localizedDescription)")
                
                // Attempt to decode single object if array decoding fails
                do {
                    let singleIngredient = try JSONDecoder().decode(AWSIngredientModel.self, from: data)
                    completion(.success([singleIngredient]))
                } catch {
                    print("Single object decoding also failed: \(error)")
                    completion(.failure(error))
                }
            }
        }.resume()
    }

    // Check if an ingredient exists by name
    func checkIngredientExists(name: String, completion: @escaping (Bool) -> Void) {
        Task {
            await MainActor.run {
                searchIngredients(query: name, limit: 1) { result in
                    switch result {
                    case .success(let ingredients):
                        completion(!ingredients.isEmpty)
                    case .failure:
                        completion(false)
                    }
                }
            }
        }
    }
}
