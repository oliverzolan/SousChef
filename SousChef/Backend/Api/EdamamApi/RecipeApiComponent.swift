//
//  RecipeApiComponent.swift
//  SousChef
//
//  Created by Sutter Reynolds on 2/23/25.
//

import Foundation

// Component for handling querying recipes from Edamam API
class EdamamRecipeComponent: EdamamAbstract {
    
    // Properties
    private let RECIPE_ENDPOINT: String
    private let user: String
    private let type: String
    
    // Optional Filters
    var cuisineType: EdamamRecipeCuisineType?
    var mealType: EdamamRecipeMealType?
    var diet: EdamamRecipeDiet?
    var health: EdamamRecipeHealth?
    var calorieNum: Int?
    var searchInput: String?

    // Initialize the recipe component
    override init(appId: String = "5732a059", appKey: String = "58090f7f2c16659ae520bd0f3a7f51d2") {
        self.RECIPE_ENDPOINT = "/api/recipes/v2"
        self.user = "SousChef2950"
        self.type = "public"
        super.init(appId: appId, appKey: appKey)
    }

    // Search for recipes using filters and search parameters
    func searchRecipes(query: String,
                       cuisineType: String? = nil, 
                       mealType: String? = nil,
                       dietType: String? = nil,
                       healthType: String? = nil,
                       maxTime: Int? = nil,
                       page: Int = 0,
                       completion: @escaping (Result<EdamamRecipeResponse, Error>) -> Void) {
        
        // URL Builder
        var urlComponents = URLComponents(string: baseURL + RECIPE_ENDPOINT)
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "app_id", value: appId),
            URLQueryItem(name: "app_key", value: appKey),
            URLQueryItem(name: "type", value: type),
        ]
        
        // Query if not empty
        if !query.isEmpty {
            queryItems.append(URLQueryItem(name: "q", value: query))
        }
        
        // Pagination - 20 results
        if page > 0 {
            queryItems.append(URLQueryItem(name: "from", value: "\(page * 20)"))
            queryItems.append(URLQueryItem(name: "to", value: "\((page + 1) * 20)"))
        }
        
        // Optional cuisine type filter
        if let cuisineType = cuisineType {
            queryItems.append(URLQueryItem(name: "cuisineType", value: cuisineType.lowercased()))
        } else if let cuisineType = self.cuisineType {
            queryItems.append(URLQueryItem(name: "cuisineType", value: cuisineType.rawValue))
        }
        
        // Optional meal type filter
        if let mealType = mealType {
            queryItems.append(URLQueryItem(name: "mealType", value: mealType.lowercased()))
        } else if let mealType = self.mealType {
            queryItems.append(URLQueryItem(name: "mealType", value: mealType.rawValue))
        }
        
        // Optional diet filter
        if let dietType = dietType {
            queryItems.append(URLQueryItem(name: "diet", value: dietType.lowercased()))
        } else if let diet = self.diet {
            queryItems.append(URLQueryItem(name: "diet", value: diet.rawValue))
        }
        
        // Optional health filter
        if let healthType = healthType {
            queryItems.append(URLQueryItem(name: "health", value: healthType.lowercased()))
        } else if let health = self.health {
            queryItems.append(URLQueryItem(name: "health", value: health.rawValue))
        }
        
        // Optional time filter
        if let maxTime = maxTime {
            queryItems.append(URLQueryItem(name: "time", value: "1-\(maxTime)"))
        }
        
        // Optional calories filter
//        if let calorieNum = calorieNum {
//            queryItems.append(URLQueryItem(name: "calories", value: "0-\(calorieNum)"))
//        }
        
        urlComponents?.queryItems = queryItems
        
        // URL Validator and unwrapper
        guard let url = urlComponents?.url else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }
        
        // HTTP request builder
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue(user, forHTTPHeaderField: "Edamam-Account-User")
        
        // API request handler
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            // Handles network error
            if let error = error {
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }
            
            // Handles empty response
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "No Data", code: 0, userInfo: nil)))
                }
                return
            }

            do {
                // Decode the json
                let decodedResponse = try JSONDecoder().decode(EdamamRecipeResponse.self, from: data)
                
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("API Response Structure: \(jsonString.prefix(500))...")
                }
                
                DispatchQueue.main.async { completion(.success(decodedResponse)) }
            } catch {
                print("Decoding Error: \(error)")
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Failed to decode JSON: \(jsonString.prefix(500))...")
                }
                DispatchQueue.main.async { completion(.failure(error)) }
            }
        }.resume()
    }
    
    // Fetch next page of recipes
    func continueSearch(url: String, completion: @escaping (Result<EdamamRecipeResponse, Error>) -> Void) {
        guard let url = URL(string: url) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue(user, forHTTPHeaderField: "Edamam-Account-User")
        
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
                let decodedResponse = try JSONDecoder().decode(EdamamRecipeResponse.self, from: data)
                
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Pagination API Response Structure: \(jsonString.prefix(500))...")
                }
                
                DispatchQueue.main.async { completion(.success(decodedResponse)) }
            } catch {
                print("Pagination Decoding Error: \(error)")
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Failed to decode pagination JSON: \(jsonString.prefix(500))...")
                }
                DispatchQueue.main.async { completion(.failure(error)) }
            }
        }.resume()
    }
    
    func compareRecipeIngredientsWithPantry(recipeIngredients: [EdamamIngredientModel], completion: @escaping (Result<Set<String>, Error>) -> Void) {
        let awsComponent = AWSIngredientsComponent(userSession: UserSession()) // Create UserSession appropriately

        awsComponent.fetchIngredients { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let pantryIngredients):
                let pantryKeywords = Set(pantryIngredients.flatMap { self.simplifyIngredientName($0.food).split(separator: " ").map { String($0) } })

                let matchedIngredients = Set(recipeIngredients.filter { recipeIngredient in
                    let simplifiedRecipeName = self.simplifyIngredientName(recipeIngredient.label)
                    let recipeKeywords = Set(simplifiedRecipeName.split(separator: " ").map { String($0) })

                    return !pantryKeywords.isDisjoint(with: recipeKeywords)
                }.map { $0.foodId })
                
                DispatchQueue.main.async {
                    print("Matched Ingredients: \(matchedIngredients)")
                    completion(.success(matchedIngredients))
                }

            case .failure(let error):
                print("Error fetching pantry ingredients: \(error)")
                completion(.failure(error))
            }
        }
    }



    private func simplifyIngredientName(_ name: String) -> String {
        let lowercasedName = name.lowercased()
        
        let wordsToRemove = ["breast", "thigh", "boneless", "skinless", "organic", "fresh", "ground", "cooked", "raw", "diced", "sliced"]
        var simplifiedName = lowercasedName

        for word in wordsToRemove {
            simplifiedName = simplifiedName.replacingOccurrences(of: word, with: "")
        }

        return simplifiedName.trimmingCharacters(in: .whitespacesAndNewlines)
    }


}
