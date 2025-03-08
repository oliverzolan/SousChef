//
//  AWSAbstract.swift
//  SousChef
//
//  Created by Sutter Reynolds on 3/5/25.
//

import Foundation
import FirebaseAuth

class AWSAbstract {
    let baseURL: String
    let route: String
    let userSession: UserSession

    init(userSession: UserSession, route: String) {
        self.baseURL = "https://souschef.click"
        self.userSession = userSession
        self.route = route
    }

    func fetchData<T: Decodable>(endpoint: String, completion: @escaping (Result<T, Error>) -> Void) {
    }

    func sendData<T: Encodable>(endpoint: String, payload: T, completion: @escaping (Result<Void, Error>) -> Void) {
    }
}
