//
//  APIRequest.swift
//  SousChef
//
//  Created by Zachary Waiksnoris on 12/6/24.
//

import Foundation

struct APIRequest {
    let endpoint: String
    let method: String
    let body: [String: Any]?

    func send(completion: @escaping (Result<Data, Error>) -> Void) {
        guard let url = URL(string: endpoint) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 400, userInfo: nil)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        if let body = body {
            request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "No Data", code: 500, userInfo: nil)))
                return
            }

            completion(.success(data))
        }
        task.resume()
    }
}
