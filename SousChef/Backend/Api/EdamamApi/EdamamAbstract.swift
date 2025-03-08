//
//  EdamamApiComponent.swift
//  SousChef
//
//  Created by Sutter Reynolds on 3/3/25.
//

import Foundation

class EdamamAbstract: ObservableObject {
    private(set) var appId: String
    private(set) var appKey: String
    private(set) var baseURL: String

    init(appId: String = "YOUR_APP_ID", appKey: String = "YOUR_APP_KEY") {
        self.appId = appId
        self.appKey = appKey
        self.baseURL = "https://api.edamam.com"
    }
    
    func search(query: String, completion: @escaping (Result<Data, Error>) -> Void) {
        
    }
}


