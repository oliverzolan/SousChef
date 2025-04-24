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
    
    @MainActor func compareRecipeIngredientsWithPantry(recipeIngredients: [EdamamIngredientModel], completion: @escaping (Result<Set<String>, Error>) -> Void) {
        let awsComponent = AWSUserIngredientsComponent(userSession: UserSession())

        awsComponent.fetchIngredients { [weak self] (result: Result<[AWSIngredientModel], Error>) in
            guard let self = self else {
                return
            }

            switch result {
            case .success(let pantryIngredients):
                pantryIngredients.forEach { ingredient in
                    print("Pantry Ingredient: \(ingredient.name)")
                }

                // Extract pantry ingredients as full items for exact matching
                let pantryFullNames = Set(pantryIngredients.map { $0.name.lowercased() })
                
                // Extract all keywords from pantry ingredients for partial matching
                let pantryKeywords = Set(pantryIngredients.flatMap { ingredient in
                    self.extractKeywords(from: ingredient.name)
                })

                // Compare each recipe ingredient with pantry
                var matchedIngredients = Set<String>()
                for recipeIngredient in recipeIngredients {
                    let recipeText = recipeIngredient.label.lowercased()
                    let recipeKeywords = self.extractKeywords(from: recipeText)
                    
                    if pantryFullNames.contains(recipeText) {
                        matchedIngredients.insert(recipeIngredient.foodId)
                        continue
                    }
                    
                    let specialCompoundIngredients = [
                        "broth", "stock", "sauce", "paste", "oil", "milk", "cream", "yogurt", "butter",
                        "juice", "vinegar", "wine", "beer", "liquor", "extract"
                    ]
                    
                    let isCompoundIngredient = specialCompoundIngredients.contains { recipeText.contains($0) }
                    
                    if isCompoundIngredient {
                        let hasMatchingCompoundInPantry = pantryFullNames.contains { pantryName in
                            return recipeText == pantryName || 
                                   specialCompoundIngredients.contains { compound in
                                       recipeText.contains(compound) && pantryName.contains(compound)
                                   }
                        }
                        
                        if hasMatchingCompoundInPantry {
                            matchedIngredients.insert(recipeIngredient.foodId)
                        }
                        continue
                    }
                    
                    // For regular ingredients, use keyword matching
                    var foundMatch = false
                    for recipeWord in recipeKeywords {
                        for pantryWord in pantryKeywords {
                            // Only match if the pantry word fully contains the recipe word
                            // or they are exactly the same
                            if recipeWord == pantryWord || 
                               (pantryWord.contains(recipeWord) && 
                                Double(recipeWord.count) / Double(pantryWord.count) > 0.7) {
                                matchedIngredients.insert(recipeIngredient.foodId)
                                foundMatch = true
                                break
                            }
                        }
                        if foundMatch { break }
                    }
                }

                DispatchQueue.main.async {
                    completion(.success(matchedIngredients))
                }

            case .failure(let error):
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }

    private func extractKeywords(from name: String) -> Set<String> {
        // Convert to lowercase to ensure case-insensitive matching
        let lowercasedName = name.lowercased()
        
        let specialCompoundIngredients = [
            "broth", "stock", "sauce", "paste", "oil", "milk", "cream", "yogurt", "butter",
            "juice", "vinegar", "wine", "beer", "liquor", "extract"
        ]
        
        for compound in specialCompoundIngredients {
            if lowercasedName.contains(compound) {
                return [lowercasedName]
            }
        }
        
        // List of words to ignore in ingredient names
        let wordsToRemove = [
            "breast", "thigh", "boneless", "skinless", "organic", "fresh", "ground", "cooked", "raw", "diced",
            "sliced", "whole", "fillet", "pieces", "chunks", "strips", "steak", "loin", "chopped", "minced",
            "grilled", "roasted", "boiled", "fried", "baked", "smoked", "shredded", "frozen", "canned",
            "powdered", "dry", "dehydrated", "salted", "unsalted", "low-fat", "fat-free", "crushed",
            "finely", "coarse", "freshly", "thinly", "thick", "lean", "light", "free-range",
            "farm-raised", "wild-caught", "large", "small", "medium", "whole", "fillets", "pieces", "slices",
            "packed", "jarred", "bottled", "dried", "fresh", "can", "package", "container", "bag", "box"
        ]
        
        let words = lowercasedName.split(separator: " ").map { String($0) }
        let filteredWords = words.filter { !wordsToRemove.contains($0) }

        return Set(filteredWords)
    }
}
