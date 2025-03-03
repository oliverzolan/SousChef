//
//  RecipeApiComponent.swift
//  SousChef
//
//  Created by Garry Gomes on 2/23/25.
//
import Foundation

// Endpoints
let RECIPE_API_ENDPOINT = "/api/recipes/v2"

// API Componenet
class RecipeAPI {
    private let appId: String
    private let appKey: String
    private let baseURL: String
    private let type: String
    private let user: String
    
    var searchInput: String?
    var cuisineType: CuisineType?
    var mealType: MealType?
    var diet: Diet?
    var health: Health?
    var calorieNum: Int?


    init(searchInput: String? = nil, cuisineType: CuisineType? = nil, mealType: MealType? = nil, diet: Diet? = nil, health: Health? = nil, calorieNum: Int? = nil) {
        self.appId = "5732a059"
        self.appKey = "58090f7f2c16659ae520bd0f3a7f51d2"
        self.baseURL = "https://api.edamam.com"
        self.type = "public"
        self.user = "SousChef2950"
        
        self.searchInput = searchInput
        self.cuisineType = cuisineType
        self.mealType = mealType
        self.diet = diet
        self.health = health
        self.calorieNum = calorieNum
    }

    func searchRecipes(query: String, completion: @escaping (Result<[RecipeModel], Error>) -> Void) {
        var urlComponents = URLComponents(string: baseURL + RECIPE_API_ENDPOINT)
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "app_id", value: appId),
            URLQueryItem(name: "app_key", value: appKey),
            URLQueryItem(name: "type", value: type)
        ]
        
        
        if let searchInput = searchInput {
            queryItems.append(URLQueryItem(name: "q", value: searchInput))
        } else {
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
        }
        
        urlComponents?.queryItems = queryItems
        
        guard let url = urlComponents?.url else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue(user, forHTTPHeaderField: "Edamam-Account-User")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No Data", code: 0, userInfo: nil)))
                return
            }

            do {
                let decodedResponse = try JSONDecoder().decode(RecipeResponse.self, from: data)
                print(decodedResponse)
                let recipes = decodedResponse.hits.map { $0.recipe }
    
                completion(.success(recipes))
            } catch {
                completion(.failure(error))
            }
        }

        task.resume()
    }
}
