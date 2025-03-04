import Foundation

class FoodDatabaseAPI {
    private let appId: String
    private let appKey: String
    private let baseURL: String
    private let parserEndpoint: String

    init(
        appId: String = "d76328ea",
        appKey: String = "011912e96073eeb8e2088ecb41b78676"
    ) {
        self.appId = appId
        self.appKey = appKey
        self.baseURL = "https://api.edamam.com"
        self.parserEndpoint = "/api/food-database/v2/parser"
    }

    func searchFoods(query: String, completion: @escaping (Result<[FoodModel], Error>) -> Void) {
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            completion(.failure(NSError(domain: "Invalid Query", code: 0, userInfo: nil)))
            return
        }
        let urlString = "\(baseURL)\(parserEndpoint)?app_id=\(appId)&app_key=\(appKey)&ingr=\(encodedQuery)"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "No Data", code: 0, userInfo: nil)))
                }
                return
            }
            do {
                let decoder = JSONDecoder()
                let searchResponse = try decoder.decode(FoodSearchResponse.self, from: data)
                let foods = searchResponse.hints.map { $0.food }
                DispatchQueue.main.async {
                    completion(.success(foods))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
}
