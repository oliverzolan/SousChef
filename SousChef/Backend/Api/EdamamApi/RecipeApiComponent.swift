//
//  RecipeApiComponent.swift
//  SousChef
//
//  Created by Sutter Reynolds on 2/23/25.
//

import Foundation

class EdamamRecipeComponent: EdamamAbstract {
    private let RECIPE_ENDPOINT: String
    private let user: String
    private let type: String
    
    var cuisineType: EdamamRecipeCuisineType?
    var mealType: EdamamRecipeMealType?
    var diet: EdamamRecipeDiet?
    var health: EdamamRecipeHealth?
    var calorieNum: Int?
    var searchInput: String?

    override init(appId: String = "5732a059", appKey: String = "58090f7f2c16659ae520bd0f3a7f51d2") {
        self.RECIPE_ENDPOINT = "/api/recipes/v2"
        self.user = "SousChef2950"
        self.type = "public"
        super.init(appId: appId, appKey: appKey)
    }

    func searchRecipes(query: String, completion: @escaping (Result<EdamamRecipeResponse, Error>) -> Void) {
        var urlComponents = URLComponents(string: baseURL + RECIPE_ENDPOINT)
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "app_id", value: appId),
            URLQueryItem(name: "app_key", value: appKey),
            URLQueryItem(name: "type", value: type),
            URLQueryItem(name: "q", value: query)
        ]
        
        if let cuisineType = cuisineType {
            queryItems.append(URLQueryItem(name: "cuisineType", value: cuisineType.rawValue))
        }
        if let mealType = mealType {
            queryItems.append(URLQueryItem(name: "mealType", value: mealType.rawValue))
        }
        if let diet = diet {
            queryItems.append(URLQueryItem(name: "diet", value: diet.rawValue))
        }
        if let health = health {
            queryItems.append(URLQueryItem(name: "health", value: health.rawValue))
        }
        if let calorieNum = calorieNum {
            queryItems.append(URLQueryItem(name: "calories", value: "0-\(calorieNum)"))
        }
        
        urlComponents?.queryItems = queryItems
        
        guard let url = urlComponents?.url else {
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
                DispatchQueue.main.async { completion(.success(decodedResponse)) }
            } catch {
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
