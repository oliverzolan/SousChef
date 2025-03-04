//
//  EdamamApiComponent.swift
//  SousChef
//
//  Created by Sutter Reynolds on 3/3/25.
//

import Foundation

class BaseAPIComponent<T: Decodable>: ObservableObject {
    private(set) var appId: String
    private(set) var appKey: String
    private(set) var baseURL: String

    init(appId: String = "YOUR_APP_ID", appKey: String = "YOUR_APP_KEY") {
        self.appId = appId
        self.appKey = appKey
        self.baseURL = "https://api.edamam.com"
    }
    
    /// Subclasses must override this method to perform a search.
    func search(query: String, completion: @escaping (Result<T, Error>) -> Void) {
        fatalError("search(query:completion:) must be overridden by subclasses")
    }
}
