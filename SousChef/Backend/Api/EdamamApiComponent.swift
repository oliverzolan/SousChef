//
//  EdamamApiComponent.swift
//  SousChef
//
//  Created by Sutter Reynolds on 3/3/25.
//

import Foundation

class BaseAPIComponent<T: Decodable>: ObservableObject {
    let appId: String
    let appKey: String
    let baseURL: String
    let type: String
    let user: String

    init() {
        self.appId = ProcessInfo.processInfo.environment["RECIPEAPI_BASEURL"] ?? "YOUR_APP_ID"
        self.appKey = ProcessInfo.processInfo.environment["RECIPEAPI_KEY"] ?? "YOUR_APP_KEY"
        self.baseURL = ProcessInfo.processInfo.environment["RECIPEAPI_ID"] ?? "https://api.edamam.com"
        self.type = ProcessInfo.processInfo.environment["RECIPEAPI_TYPE"] ?? "public"
        self.user = ProcessInfo.processInfo.environment["RECIPEAPI_USER"] ?? "user"
    }
    
    func search(query: String, completion: @escaping (Result<T, Error>) -> Void) {
        fatalError("search(query:completion:) must be overridden by subclasses")
    }
    
}
