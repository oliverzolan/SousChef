//
//  RecipeApiComponent.swift
//  SousChef
//
//  Created by Sutter Reynolds on 2/23/25.
//
import Foundation

class RecipeAPI: BaseAPIComponent<RecipeResponse> {
    private var RECIPE_API_ENDPOINT: String
    private var user: String
    private var type: String
    
    var cuisineType: CuisineType?
    var mealType: MealType?
    var diet: Diet?
    var health: Health?
    var calorieNum: Int?
    var searchInput: String?

    override init(appId: String = "5732a059", appKey: String = "58090f7f2c16659ae520bd0f3a7f51d2") {
        self.RECIPE_API_ENDPOINT = "/api/recipes/v2"
        self.user = "SousChef2950"
        self.type = "public"
        super.init(appId: appId, appKey: appKey)
    }

    override func search(query: String, completion: @escaping (Result<RecipeResponse, Error>) -> Void) {
        var urlComponents = URLComponents(string: baseURL + RECIPE_API_ENDPOINT)
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
                let decodedResponse = try JSONDecoder().decode(RecipeResponse.self, from: data)
                DispatchQueue.main.async { completion(.success(decodedResponse)) }
            } catch {
                DispatchQueue.main.async { completion(.failure(error)) }
            }
        }.resume()
    }
}
